# Google Gemini Configuration for Homelab

## Overview
Google Gemini integration for VS Code provides advanced AI assistance for homelab development and operations.

## Setup Instructions

### 1. Install Gemini Extension
```bash
# In VS Code, install:
# - Google Cloud Code extension
# - Gemini Code Assist extension (if available)
```

### 2. Authentication
```bash
# Authenticate with Google Cloud
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 3. VS Code Settings
Add to `.vscode/settings.json`:
```json
{
  "cloudcode.gemini.enabled": true,
  "cloudcode.gemini.model": "gemini-pro",
  "cloudcode.gemini.temperature": 0.7
}
```

## Homelab-Specific Use Cases

### 1. Infrastructure Design
**Prompt**: "Design a highly available Kubernetes deployment for [service] in my homelab with 3 nodes, including persistent storage, ingress, and monitoring."

**Context to provide**:
- Current cluster configuration
- Available resources
- Storage options (Longhorn, NFS)
- Networking setup (Traefik, MetalLB)

### 2. Troubleshooting
**Prompt**: "Analyze these logs and suggest fixes for the issue. My homelab is running K3s on Proxmox with Cilium networking."

**Include**:
- Error logs
- Pod/service descriptions
- Network configuration
- Recent changes

### 3. Code Generation
**Prompt**: "Generate a complete Terraform module for provisioning a VM on Proxmox VE with these specifications..."

**Specifications**:
- VM resources (CPU, RAM, disk)
- Network configuration
- Cloud-init setup
- Integration with existing infrastructure

### 4. Documentation
**Prompt**: "Create a comprehensive runbook for deploying and managing [service] in my homelab environment."

**Include**:
- Prerequisites
- Step-by-step procedures
- Troubleshooting steps
- Rollback procedures

### 5. Security Analysis
**Prompt**: "Review this Kubernetes manifest for security best practices in a homelab environment."

**Focus areas**:
- RBAC configurations
- Network policies
- Secret management
- Resource limits
- Security contexts

## Advanced Features

### Code Explanation
Use Gemini to:
- Explain complex Terraform configurations
- Break down Ansible playbooks
- Analyze Kubernetes operators
- Review Python automation scripts

### Code Transformation
- Convert Docker Compose to Kubernetes manifests
- Migrate Ansible tasks to Terraform
- Modernize legacy scripts
- Refactor for best practices

### Multi-file Analysis
Gemini can analyze:
- Entire Terraform modules
- Complete Ansible roles
- Kubernetes application stacks
- Related configuration files

## Homelab Context Template

When starting a new Gemini conversation about homelab:

```
I'm working on a homelab with the following setup:
- Infrastructure: Proxmox VE hypervisor
- Orchestration: K3s (Kubernetes v1.29)
- IaC: Terraform v1.7
- Config Management: Ansible v2.16
- Storage: Longhorn, TrueNAS, NFS
- Networking: Cilium, Traefik, MetalLB, Tailscale
- Monitoring: Prometheus, Grafana, Loki
- GitOps: ArgoCD
- Secrets: HashiCorp Vault + External Secrets

Current task: [describe your task]
```

## Integration with Other Tools

### With Terraform
```bash
# Use Gemini to explain Terraform plan
terraform plan -out=plan.tfplan
terraform show -json plan.tfplan > plan.json
# Ask Gemini: "Explain the changes in this Terraform plan and identify any risks"
```

### With Kubernetes
```bash
# Get resource info for Gemini analysis
kubectl get pods -n namespace -o yaml > pods.yaml
# Ask Gemini: "Analyze why these pods are CrashLooping"
```

### With Ansible
```bash
# Dry run for analysis
ansible-playbook playbook.yml --check --diff > output.txt
# Ask Gemini: "Review this Ansible dry-run output for potential issues"
```

## Best Practices

### 1. Provide Complete Context
- Share relevant configuration files
- Include error messages in full
- Describe the desired end state
- Mention constraints (resources, network, etc.)

### 2. Iterative Refinement
- Start with high-level questions
- Drill down into specifics
- Ask for alternatives
- Request explanations for suggestions

### 3. Validate Suggestions
- Test in development first
- Review for security implications
- Check compatibility with existing setup
- Verify resource requirements

### 4. Security Considerations
- Don't share actual secrets/credentials
- Use placeholders for sensitive data
- Review generated code for security issues
- Validate against security policies

## Common Homelab Prompts

### Infrastructure Deployment
```
Create a complete deployment for [service] including:
1. Terraform module for VM provisioning on Proxmox
2. Ansible playbook for service configuration
3. Kubernetes manifests (Deployment, Service, Ingress)
4. Monitoring configuration (Prometheus ServiceMonitor)
5. Backup procedures
```

### Migration Tasks
```
Help me migrate from Docker Compose to Kubernetes for this application.
Current setup: [paste docker-compose.yml]
Target: K3s cluster with Longhorn storage, Traefik ingress
Requirements: High availability, persistent storage, TLS
```

### Performance Optimization
```
Analyze my homelab resource usage and suggest optimizations:
- Cluster: [node specs and count]
- Current workloads: [list of services]
- Issues: [describe performance problems]
- Goals: [what you want to achieve]
```

### Disaster Recovery
```
Design a comprehensive backup and disaster recovery strategy for:
- Kubernetes etcd
- Persistent volumes (Longhorn)
- Terraform state (S3)
- Vault secrets
- Git repositories (Gitea)
Target: RPO of 24h, RTO of 2h
```

## Gemini Model Selection

### gemini-pro
- General purpose
- Good for code generation
- Fast responses
- Standard use cases

### gemini-pro-vision (if available)
- Can analyze diagrams
- Review network topology images
- Examine dashboard screenshots
- Useful for visual troubleshooting

### gemini-ultra (when available)
- Most capable model
- Complex reasoning tasks
- Large-scale refactoring
- Architectural design

## API Usage (for automation)

```python
# Example: Using Gemini API for automated analysis
import google.generativeai as genai

genai.configure(api_key='YOUR_API_KEY')
model = genai.GenerativeModel('gemini-pro')

# Analyze Kubernetes logs
with open('pod-logs.txt', 'r') as f:
    logs = f.read()

prompt = f"""
Analyze these Kubernetes pod logs from my homelab K3s cluster.
Identify errors, suggest fixes, and recommend preventive measures.

Logs:
{logs}
"""

response = model.generate_content(prompt)
print(response.text)
```

## Troubleshooting

### Connection Issues
```bash
# Verify gcloud authentication
gcloud auth list
gcloud config list

# Re-authenticate if needed
gcloud auth application-default login
```

### Rate Limits
- Implement request throttling
- Cache frequent queries
- Use appropriate model for task
- Consider API quotas

### Quality Issues
- Provide more context
- Use specific terminology
- Share example code
- Request step-by-step guidance

## Resources

- [Google Cloud Code Documentation](https://cloud.google.com/code)
- [Gemini API Documentation](https://ai.google.dev/docs)
- Homelab documentation: `/workspace/Homelab/docs/`
- Example prompts: `/workspace/.ai-assistants/example-prompts.md`
