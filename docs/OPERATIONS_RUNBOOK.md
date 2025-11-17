# Homelab Operations Runbook

Emergency procedures and operational tasks for maintaining your homelab infrastructure.

## Table of Contents

- [Emergency Procedures](#emergency-procedures)
- [Routine Maintenance](#routine-maintenance)
- [Backup & Recovery](#backup--recovery)
- [Security Operations](#security-operations)
- [Performance Troubleshooting](#performance-troubleshooting)
- [Disaster Recovery](#disaster-recovery)

## Emergency Procedures

### Kubernetes Cluster Down

**Symptoms**: Cannot reach services, `kubectl` commands fail

**Diagnosis**:

```bash
# Check K3s service status on all nodes
ssh homelab-node1 "sudo systemctl status k3s"

# Check node connectivity
ping homelab-node1
```

**Resolution**:

1. **Restart K3s on master node**:

   ```bash
   ssh homelab-node1 "sudo systemctl restart k3s"
   ```

2. **Wait 30 seconds**, then check:

   ```bash
   kubectl get nodes
   ```

3. **If nodes show NotReady**:

   ```bash
   # Restart K3s on worker nodes
   ssh homelab-node2 "sudo systemctl restart k3s-agent"
   ssh homelab-node3 "sudo systemctl restart k3s-agent"
   ```

4. **Verify pods are restarting**:

   ```bash
   watch kubectl get pods -A
   ```

**AI Help**: *"My Kubernetes cluster is down, walk me through recovery"*

### Pod CrashLoopBackOff

**Symptoms**: Pod continuously restarting

**Diagnosis**:

```bash
# Get pod status
kubectl get pods -A | grep -i crash

# Describe pod to see events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace> --tail=100
kubectl logs <pod-name> -n <namespace> --previous
```

**Common Causes & Fixes**:

1. **Missing ConfigMap/Secret**:

   ```bash
   # Check if referenced resources exist
   kubectl get configmap,secret -n <namespace>
   ```

2. **Image pull error**:

   ```bash
   # Check image name
   kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.spec.containers[0].image}'

   # Try pulling manually
   docker pull <image-name>
   ```

3. **Resource limits too low**:

   ```yaml
   # Edit deployment
   kubectl edit deployment <name> -n <namespace>

   # Increase limits:
   resources:
     limits:
       memory: "512Mi"  # Increase this
       cpu: "500m"
   ```

4. **Application error**:
   - Check logs for error message
   - Ask AI: *"This pod is crashing with error: [paste error]"*

### Out of Disk Space

**Symptoms**: Pods evicted, deployments failing, slow performance

**Diagnosis**:

```bash
# Check node disk usage
kubectl top nodes

# SSH to node and check
ssh homelab-node1 "df -h"
```

**Resolution**:

1. **Clean Docker images**:

   ```bash
   ssh homelab-node1 "sudo docker system prune -a -f"
   ```

2. **Clean containerd images** (if using containerd):

   ```bash
   ssh homelab-node1 "sudo k3s crictl rmi --prune"
   ```

3. **Check Longhorn volumes**:

   ```bash
   kubectl get pv,pvc -A
   kubectl get volumeattachments
   ```

4. **Delete old PVCs** (if safe):

   ```bash
   kubectl delete pvc <old-pvc> -n <namespace>
   ```

5. **Expand storage** (permanent fix):
   - Add more disk space to VMs
   - Or configure Longhorn to use additional disks

### Traefik Ingress Not Working

**Symptoms**: Cannot access services via HTTPS/domain names

**Diagnosis**:

```bash
# Check Traefik pods
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Check Traefik logs
kubectl logs -n kube-system -l app.kubernetes.io/name=traefik --tail=100

# Check ingress resources
kubectl get ingress -A
```

**Resolution**:

1. **Verify ingress configuration**:

   ```bash
   kubectl describe ingress <name> -n <namespace>
   ```

2. **Check cert-manager** (if using TLS):

   ```bash
   kubectl get certificates -A
   kubectl describe certificate <name> -n <namespace>
   ```

3. **Restart Traefik**:

   ```bash
   kubectl rollout restart deployment traefik -n kube-system
   ```

4. **Test from inside cluster**:

   ```bash
   kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
     curl http://your-service.namespace.svc.cluster.local
   ```

### Terraform State Locked

**Symptoms**: `terraform apply` fails with "state locked" error

**Diagnosis**:

```bash
cd ../Homelab/infra/terraform
terraform state list
```

**Resolution**:

1. **If you know no one else is running Terraform**:

   ```bash
   # Get lock ID from error message
   terraform force-unlock <LOCK-ID>
   ```

2. **If using S3/MinIO backend**:
   - Check if `.terraform.tfstate.lock.info` exists
   - Delete lock file from S3/MinIO console

3. **If state is corrupted**:

   ```bash
   # Backup current state
   terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

   # Restore from backup if needed
   terraform state push backup.tfstate
   ```

**Prevention**: Always use remote state with locking (S3, Consul, etc.)

## Routine Maintenance

### Weekly Tasks

**Every Monday morning**:

1. **Health check**: `Ctrl+Shift+B` → Health Check
2. **Update packages**:

   ```bash
   cd ../Homelab/infra/ansible
   ansible-playbook playbooks/update-packages.yml
   ```

3. **Check backup status**:

   ```bash
   # Check last backup time
   ssh backup-server "restic snapshots --last"
   ```

4. **Review logs** for errors:

   ```bash
   # K3s errors
   ssh homelab-node1 "sudo journalctl -u k3s --since '1 week ago' | grep -i error"
   ```

5. **Check disk usage**:

   ```bash
   kubectl top nodes
   ```

6. **Review security updates**:

   ```bash
   ssh homelab-node1 "apt list --upgradable"
   ```

### Monthly Tasks

**First of every month**:

1. **Rotate Kubernetes secrets**:

   ```bash
   cd ../Homelab/infra/ansible
   ansible-playbook playbooks/rotate-secrets.yml
   ```

2. **Update container images**:

   ```bash
   # Update all deployments to use latest tags
   kubectl set image deployment/<name> <container>=<image>:latest
   ```

3. **Test backup restoration**:

   ```bash
   # Restore to test environment
   restic -r /backup restore latest --target /restore-test
   ```

4. **Review Prometheus alerts**:
   - Check Grafana dashboards
   - Verify alerting is working

5. **SSL certificate check**:

   ```bash
   kubectl get certificates -A
   ```

6. **Audit access logs**:

   ```bash
   # Check who accessed cluster
   kubectl get events -A --field-selector type=Normal | grep -i auth
   ```

### Quarterly Tasks

**Every 3 months**:

1. **Major version updates**:

   - Kubernetes version upgrade
   - Terraform provider updates
   - Ansible version update

2. **Security audit**:

   ```bash
   # Run kube-bench
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/main/job.yaml
   kubectl logs -l app=kube-bench
   ```

3. **Capacity planning**:
   - Review resource usage trends
   - Plan for hardware upgrades

4. **Disaster recovery drill**:
   - Simulate node failure
   - Test full backup restoration

## Backup & Recovery

### Backup Kubernetes Resources

**Method 1: Manual backup**:

```bash
# All resources
kubectl get all --all-namespaces -o yaml > k8s-backup-$(date +%Y%m%d).yaml

# Specific namespace
kubectl get all -n production -o yaml > prod-backup-$(date +%Y%m%d).yaml

# Persistent volumes
kubectl get pv,pvc -A -o yaml > pv-backup-$(date +%Y%m%d).yaml
```

**Method 2: Using Velero** (recommended):

```bash
# Install Velero
kubectl apply -f ../Homelab/infra/kubernetes/velero/

# Create backup
velero backup create weekly-backup --include-namespaces=production,default

# Check status
velero backup describe weekly-backup
```

**Method 3: Automated with CronJob**:

```yaml
# Already configured in kubernetes/backup-cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: k8s-backup
spec:
  schedule: "0 2 * * *"  # 2 AM daily
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: bitnami/kubectl:latest
            command:
            - /bin/sh
            - -c
            - kubectl get all -A -o yaml | gzip > /backup/k8s-$(date +%Y%m%d).yaml.gz
```

### Restore from Backup

**Restore Kubernetes resources**:

```bash
# Restore from YAML
kubectl apply -f k8s-backup-20250115.yaml

# Restore with Velero
velero restore create --from-backup weekly-backup
```

**Restore Terraform state**:

```bash
cd ../Homelab/infra/terraform

# Restore from backup
terraform state push backup.tfstate

# Verify
terraform state list
```

**Restore data volumes**:

```bash
# Using Longhorn (if configured)
# Access Longhorn UI and restore from snapshot

# Or using restic
restic -r /backup restore latest --target /restore-location
```

### Backup Validation

**Test restore monthly**:

```bash
# Create test namespace
kubectl create namespace restore-test

# Restore backup to test namespace
kubectl apply -f k8s-backup-latest.yaml -n restore-test

# Verify services work
kubectl get pods -n restore-test

# Clean up
kubectl delete namespace restore-test
```

## Security Operations

### Rotate SSH Keys

**Using Ansible**:

```bash
cd ../Homelab/infra/ansible

# Generate new SSH key
ssh-keygen -t ed25519 -f ~/.ssh/homelab_new -N ""

# Deploy new key
ansible-playbook playbooks/rotate-ssh-keys.yml

# Test access with new key
ssh -i ~/.ssh/homelab_new homelab-node1

# Remove old key from servers
ansible-playbook playbooks/remove-old-ssh-keys.yml
```

### Update Kubernetes Secrets

**Rotate database passwords**:

```bash
# Create new secret
kubectl create secret generic db-secret-new \
  --from-literal=password=$(openssl rand -base64 32)

# Update deployment to use new secret
kubectl edit deployment <name> -n <namespace>

# Verify pods restarted
kubectl get pods -n <namespace>

# Delete old secret
kubectl delete secret db-secret-old -n <namespace>
```

**Rotate TLS certificates**:

```bash
# If using cert-manager, delete certificate to force renewal
kubectl delete certificate <name> -n <namespace>

# cert-manager will automatically recreate
kubectl get certificate <name> -n <namespace> -w
```

### Audit Log Review

**Check Kubernetes audit logs**:

```bash
# View recent API access
ssh homelab-node1 "sudo cat /var/log/kube-apiserver/audit.log | tail -100"

# Search for specific user
ssh homelab-node1 "sudo grep 'username' /var/log/kube-apiserver/audit.log"
```

**Review access attempts**:

```bash
# SSH attempts
ssh homelab-node1 "sudo journalctl -u sshd | grep -i fail"

# Failed sudo attempts
ssh homelab-node1 "sudo journalctl | grep 'sudo.*FAILED'"
```

## Performance Troubleshooting

### High CPU Usage

**Identify culprit**:

```bash
# Cluster-wide
kubectl top pods -A --sort-by=cpu

# Specific node
ssh homelab-node1 "htop"
```

**Resolution**:

1. **Scale down if possible**:

   ```bash
   kubectl scale deployment <name> --replicas=2
   ```

2. **Add resource limits**:

   ```yaml
   resources:
     limits:
       cpu: "500m"  # Prevent one pod from hogging CPU
   ```

3. **Check for CPU-intensive processes**:

   ```bash
   # Exec into pod
   kubectl exec -it <pod-name> -- top
   ```

### High Memory Usage

**Identify memory hog**:

```bash
kubectl top pods -A --sort-by=memory
```

**Resolution**:

1. **Check for memory leaks**:

   ```bash
   # Monitor memory over time
   watch kubectl top pod <pod-name>
   ```

2. **Restart pod**:

   ```bash
   kubectl delete pod <pod-name>
   # Or rolling restart deployment
   kubectl rollout restart deployment <name>
   ```

3. **Increase memory limits** (if legitimate):

   ```yaml
   resources:
     limits:
       memory: "1Gi"
   ```

### Slow Network Performance

**Diagnosis**:

```bash
# Test pod-to-pod communication
kubectl run -it --rm nettest --image=nicolaka/netshoot --restart=Never -- \
  iperf3 -c <target-pod-ip>

# Check network plugin
kubectl get pods -n kube-system -l app=flannel
```

**Common fixes**:

1. **Restart network plugin**:

   ```bash
   kubectl rollout restart daemonset flannel -n kube-system
   ```

2. **Check MTU settings**:

   ```bash
   ssh homelab-node1 "ip link show | grep mtu"
   ```

3. **Verify DNS is working**:

   ```bash
   kubectl run -it --rm dnstest --image=busybox --restart=Never -- \
     nslookup kubernetes.default
   ```

## Disaster Recovery

### Node Failure

**If one node fails**:

1. **Kubernetes will automatically reschedule pods** to healthy nodes
2. **Check if node can be recovered**:

   ```bash
   # Try to SSH
   ssh failed-node

   # If accessible, check services
   sudo systemctl status k3s
   ```

3. **If node is unrecoverable**:

   ```bash
   # Drain node
   kubectl drain failed-node --ignore-daemonsets --delete-emptydir-data

   # Remove from cluster
   kubectl delete node failed-node
   ```

4. **Add replacement node**:

   ```bash
   cd ../Homelab/infra/ansible
   ansible-playbook playbooks/add-k3s-node.yml -e "node=new-node"
   ```

### Complete Cluster Loss

**If entire cluster is down**:

1. **Rebuild K3s cluster**:

   ```bash
   cd ../Homelab/infra/ansible
   ansible-playbook playbooks/deploy-k3s.yml
   ```

2. **Restore from backup**:

   ```bash
   # Apply saved manifests
   kubectl apply -f k8s-backup-latest.yaml

   # Or use Velero
   velero restore create --from-backup latest
   ```

3. **Restore persistent data**:

   ```bash
   # Restore volumes using Longhorn or restic
   restic -r /backup restore latest
   ```

4. **Verify all services**:

   ```bash
   kubectl get pods -A
   kubectl get services -A
   ```

### Data Corruption

**If Terraform state is corrupted**:

1. **Restore from backup**:

   ```bash
   cd ../Homelab/infra/terraform
   terraform state push backup.tfstate
   ```

2. **Import existing resources** (if needed):

   ```bash
   terraform import proxmox_vm_qemu.vm <vm-id>
   ```

3. **Rebuild state from scratch** (last resort):
   - Manually import all resources
   - Use `terraform import` for each resource

**If Kubernetes data is corrupted**:

1. **Restore etcd from backup** (K3s):

   ```bash
   ssh homelab-node1 "sudo k3s server --cluster-reset \
     --cluster-reset-restore-path=/var/lib/rancher/k3s/server/db/snapshots/on-demand"
   ```

2. **Verify cluster state**:

   ```bash
   kubectl get all -A
   ```

## Monitoring Integration

### Prometheus Queries for Common Issues

**High memory pods**:

```promql
topk(10, container_memory_usage_bytes{pod!=""})
```

**High CPU pods**:

```promql
topk(10, rate(container_cpu_usage_seconds_total{pod!=""}[5m]))
```

**Pod restart count**:

```promql
kube_pod_container_status_restarts_total > 5
```

**Disk usage by node**:

```promql
node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"} < 0.1
```

### Grafana Dashboards

**Recommended dashboards** (import from grafana.com):

- 315 - Kubernetes cluster monitoring
- 12049 - Kubernetes cluster
- 13770 - Kubernetes monitoring
- 11074 - Node exporter

**Access**: `http://grafana.yourdomain.com`

### Alert Manager

**Configure alerts** for:

- Pod CrashLoopBackOff
- Node NotReady
- Disk usage > 90%
- Memory usage > 90%
- Certificate expiring in < 7 days

## Emergency Contacts

**When to escalate**:

- Complete cluster loss > 1 hour
- Data loss detected
- Security breach suspected
- Unable to resolve critical issue

**Resources**:

- K3s documentation: <https://docs.k3s.io>
- Kubernetes troubleshooting: <https://kubernetes.io/docs/tasks/debug/>
- Ask AI: Claude Code, GitHub Copilot, Continue.dev

**Homelab community**:

- r/homelab subreddit
- K8s at home Discord
- Self-hosted podcast Discord
