# Claude Code Configuration for Homelab

This file contains configuration and context for using Claude Code with your homelab infrastructure.

## Homelab Context

### Infrastructure Overview
- **Platform**: Kubernetes (K3s) on Proxmox VE
- **IaC Tool**: Terraform
- **Configuration Management**: Ansible
- **GitOps**: ArgoCD
- **Service Mesh**: Cilium
- **Storage**: Longhorn, NFS, TrueNAS
- **Ingress**: Traefik
- **Load Balancer**: MetalLB
- **Secrets**: Vault + External Secrets
- **Monitoring**: Prometheus, Grafana, Loki

### Common Tasks
1. Terraform operations (plan, apply, validate)
2. Ansible playbook execution
3. Kubernetes manifest creation and deployment
4. Debugging services and pods
5. Network configuration and troubleshooting
6. Secret rotation and management
7. Backup and disaster recovery
8. Documentation updates

### File Locations
- Terraform: `/workspace/Homelab/infra/terraform/`
- Ansible: `/workspace/Homelab/infra/ansible/`
- Kubernetes: `/workspace/Homelab/infra/kubernetes/`
- Scripts: `/workspace/Homelab/infra/scripts/`
- Documentation: `/workspace/Homelab/docs/`

### Code Standards
- Terraform: HCL, modules-based, state in S3
- Ansible: YAML, role-based, inventory from Terraform
- Python: Black formatted, type hints, pytest tests
- Bash: ShellCheck compliant, error handling with `set -e`
- YAML: yamllint compliant, 2-space indentation
- All code: Pre-commit hooks enforced

### Useful Commands
```bash
# Terraform workflow
make tf-init
make tf-plan
make tf-apply

# Ansible workflow
make ansible-lint
make deploy-k3s
make deploy-platform

# Kubernetes
kubectl get pods -A
k9s  # Interactive K8s UI

# Testing
make test
make lint-all
```

## Claude Code Instructions

When working on homelab tasks:

1. **Always validate** before applying changes (Terraform plan, kubectl dry-run, ansible --check)
2. **Follow existing patterns** in the codebase
3. **Update documentation** when making infrastructure changes
4. **Run linters** before committing
5. **Test incrementally** - validate each component
6. **Consider dependencies** - check service dependencies before changes
7. **Security first** - never commit secrets, use Vault references
8. **Backup state** before major changes

## MCP (Model Context Protocol) Integration

The homelab has custom MCP servers for various services:
- mcp-proxmox: Proxmox VE management
- mcp-kubernetes: K8s operations
- mcp-grafana: Metrics and dashboards
- mcp-nextcloud: File operations
- mcp-postgres: Database queries
- mcp-redis: Cache operations
- mcp-mqtt: IoT messaging

Use these for deeper integrations when available.

## AI-Assisted Workflows

### 1. Infrastructure Changes
- Review current state
- Propose changes in Terraform/Ansible
- Validate syntax
- Run plan/dry-run
- Apply with approval

### 2. Debugging
- Gather logs (kubectl logs, journalctl)
- Analyze errors
- Propose fixes
- Test solutions

### 3. Documentation
- Update runbooks
- Generate diagrams (Mermaid)
- Create troubleshooting guides

### 4. Optimization
- Analyze resource usage
- Propose efficiency improvements
- Implement and test

## Custom Slash Commands

(These can be created in `.claude/commands/` if needed)

Example commands to create:
- `/deploy-service` - Deploy a new K8s service
- `/check-health` - Comprehensive health check
- `/rotate-certs` - Certificate rotation workflow
- `/scale-cluster` - Add/remove nodes
