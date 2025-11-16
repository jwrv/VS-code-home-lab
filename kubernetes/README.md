# Kubernetes Deployment for VS Code Server

This directory contains Kubernetes manifests for deploying VS Code Server to your homelab K3s cluster.

## Prerequisites

- K3s cluster running (v1.28+)
- Longhorn or another storage class configured
- Traefik ingress controller
- Cert-manager for TLS certificates
- kubectl configured with cluster access

## Quick Deploy

### Option 1: Using kubectl

```bash
# Create all resources
kubectl apply -f kubernetes/

# Verify deployment
kubectl get pods -n development
kubectl get svc -n development
kubectl get ingress -n development
```

### Option 2: Using Kustomize

```bash
# Deploy with kustomize
kubectl apply -k kubernetes/

# Check status
kubectl get all -n development -l app=vscode-server
```

### Option 3: Using ArgoCD (GitOps)

```bash
# Create ArgoCD application
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: vscode-server
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/jwrv/VS-code-home-lab.git
    targetRevision: main
    path: kubernetes
  destination:
    server: https://kubernetes.default.svc
    namespace: development
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
```

## Configuration

### 1. Update Secret Values

Edit `secret.yaml` and change default passwords:

```bash
# Generate a strong password
PASSWORD=$(openssl rand -base64 32)

# Update secret
kubectl create secret generic vscode-secrets \
  --from-literal=PASSWORD="$PASSWORD" \
  --from-literal=SUDO_PASSWORD="$PASSWORD" \
  -n development \
  --dry-run=client -o yaml | kubectl apply -f -
```

### 2. Configure Ingress Hostname

Edit `ingress.yaml` and change the hostname:

```yaml
spec:
  rules:
  - host: vscode.your-domain.com  # Change this
```

### 3. Update Storage Class

Edit `pvc.yaml` if not using Longhorn:

```yaml
spec:
  storageClassName: your-storage-class  # Change this
```

### 4. Mount SSH Keys and Kubeconfig

Create secrets for SSH keys and kubeconfig:

```bash
# SSH keys
kubectl create secret generic ssh-keys \
  --from-file=id_rsa=$HOME/.ssh/id_rsa \
  --from-file=id_rsa.pub=$HOME/.ssh/id_rsa.pub \
  --from-file=known_hosts=$HOME/.ssh/known_hosts \
  -n development

# Kubeconfig
kubectl create secret generic kubeconfig \
  --from-file=config=$HOME/.kube/config \
  -n development
```

## Storage

The deployment creates three PVCs:

1. **vscode-workspace** (50Gi) - Main workspace for code
2. **vscode-extensions** (10Gi) - VS Code extensions
3. **vscode-config** (5Gi) - VS Code configuration

Adjust sizes in `pvc.yaml` based on your needs.

## Networking

### Ingress Access

After deployment, access VS Code at: https://vscode.homelab.local

Make sure DNS is configured:
```bash
# Add to /etc/hosts or configure in your DNS server
192.168.1.100  vscode.homelab.local
```

### LoadBalancer Access (Optional)

If you prefer direct access via LoadBalancer (MetalLB):

```bash
# Uncomment LoadBalancer service in service.yaml
kubectl apply -f kubernetes/service.yaml

# Get the external IP
kubectl get svc vscode-server-lb -n development
```

## Security

### RBAC

The deployment includes:
- ServiceAccount for the pod
- Role with full access in `development` namespace
- ClusterRole with read-only access cluster-wide

Adjust permissions in `serviceaccount.yaml` as needed.

### Network Policies (Optional)

Create network policies to restrict traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: vscode-server
  namespace: development
spec:
  podSelector:
    matchLabels:
      app: vscode-server
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: traefik
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 6443
```

### Additional Security with Middlewares

Enable basic auth in `ingress.yaml`:

```bash
# Create htpasswd file
htpasswd -c auth username

# Create secret
kubectl create secret generic vscode-basic-auth \
  --from-file=auth \
  -n development

# Uncomment basic-auth middleware in ingress.yaml
```

## Monitoring

### ServiceMonitor for Prometheus

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: vscode-server
  namespace: development
spec:
  selector:
    matchLabels:
      app: vscode-server
  endpoints:
  - port: http
    path: /healthz
    interval: 30s
```

### Health Checks

The deployment includes:
- Liveness probe - restarts unhealthy containers
- Readiness probe - controls traffic routing
- Startup probe - handles slow container startup

## Backup

### Backup PVCs with Longhorn

If using Longhorn, create recurring backups:

```yaml
apiVersion: longhorn.io/v1beta2
kind: RecurringJob
metadata:
  name: vscode-backup
  namespace: longhorn-system
spec:
  cron: "0 2 * * *"  # Daily at 2 AM
  task: backup
  groups:
  - default
  retain: 7
  concurrency: 2
```

### Manual Backup

```bash
# Backup workspace data
kubectl exec -n development deployment/vscode-server -- \
  tar czf /tmp/workspace-backup.tar.gz /workspace

kubectl cp development/vscode-server-xxx:/tmp/workspace-backup.tar.gz \
  ./workspace-backup.tar.gz
```

## Scaling and HA

VS Code Server is designed for single-user, single-instance use. For team environments:

1. Deploy multiple instances with different users
2. Use separate namespaces or ingress paths
3. Consider code-server alternatives like Coder or Gitpod

## Troubleshooting

### Pod not starting

```bash
# Check pod status
kubectl describe pod -n development -l app=vscode-server

# View logs
kubectl logs -n development -l app=vscode-server --tail=100

# Check events
kubectl get events -n development --sort-by='.lastTimestamp'
```

### Cannot access via ingress

```bash
# Check ingress
kubectl describe ingress vscode-server -n development

# Check Traefik routes
kubectl get ingressroute -A

# Test service directly
kubectl port-forward -n development svc/vscode-server 8080:8080
# Then access http://localhost:8080
```

### Storage issues

```bash
# Check PVC status
kubectl get pvc -n development

# Check PV
kubectl get pv

# Describe PVC for events
kubectl describe pvc vscode-workspace -n development
```

### Permission issues

```bash
# Check security context
kubectl get pod -n development -o yaml | grep -A10 securityContext

# Fix ownership (if needed)
kubectl exec -n development deployment/vscode-server -- \
  chown -R 1000:1000 /workspace
```

## Updates

### Update VS Code Server image

```bash
# Edit deployment to use specific version
kubectl set image deployment/vscode-server \
  code-server=codercom/code-server:4.20.0 \
  -n development

# Or edit deployment.yaml and apply
kubectl apply -f kubernetes/deployment.yaml
```

### Rolling restart

```bash
kubectl rollout restart deployment/vscode-server -n development
kubectl rollout status deployment/vscode-server -n development
```

## Cleanup

```bash
# Delete all resources
kubectl delete -f kubernetes/

# Or with kustomize
kubectl delete -k kubernetes/

# Keep PVCs (data) but delete deployment
kubectl delete deployment,service,ingress -n development -l app=vscode-server
```

## Integration with Homelab

### Use with Existing Services

Mount homelab configurations:

```yaml
# Add to deployment.yaml volumes:
- name: homelab-configs
  configMap:
    name: homelab-global-config
```

### Access Homelab Services

The RBAC setup allows VS Code to interact with:
- Kubernetes API for deployments
- Prometheus for monitoring
- Grafana for dashboards
- ArgoCD for GitOps
- Other services via ingress

## Tips

1. **Persistence**: All work is stored in PVCs - pod restarts won't lose data
2. **Extensions**: Install extensions once, they persist in `vscode-extensions` PVC
3. **Git**: Configure git credentials in a secret and mount
4. **Terminal**: Full shell access with all CLI tools
5. **Customization**: Add your dotfiles to workspace for personalization

## Resources

- [code-server Documentation](https://coder.com/docs/code-server)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [K3s Documentation](https://docs.k3s.io/)
- Homelab Repository: https://github.com/jwrv/Homelab
