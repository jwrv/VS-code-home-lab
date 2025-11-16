# ChatGPT / OpenAI Codex Configuration for Homelab

## Overview
Integration guide for using ChatGPT and OpenAI Codex with your homelab development workflow.

## Available Extensions

### 1. ChatGPT - Genie AI
Install from VS Code marketplace:
- Extension ID: `genieai.chatgpt-vscode`
- Provides inline ChatGPT integration

### 2. Code GPT
Alternative extension:
- Extension ID: `DanielSanMedium.dscodegpt`
- Supports multiple AI providers including OpenAI

### 3. Rubberduck
Comprehensive AI assistant:
- Extension ID: `Rubberduck.rubberduck-vscode`
- Code review, chat, diagnostics

## Setup Instructions

### Method 1: Using ChatGPT Extension

1. Install extension in VS Code
2. Get OpenAI API key from https://platform.openai.com/api-keys
3. Configure in VS Code settings:

```json
{
  "chatgpt.apiKey": "sk-...",
  "chatgpt.model": "gpt-4-turbo-preview",
  "chatgpt.temperature": 0.7,
  "chatgpt.maxTokens": 4000
}
```

### Method 2: Using Code GPT

```json
{
  "codegpt.apiKey": "sk-...",
  "codegpt.model": "gpt-4-turbo-preview",
  "codegpt.maxTokens": 4000,
  "codegpt.provider": "openai"
}
```

### Method 3: API Integration (for Scripts)

```python
# Install OpenAI Python library
pip install openai

# Use in automation scripts
import openai

openai.api_key = "sk-..."

response = openai.ChatCompletion.create(
    model="gpt-4-turbo-preview",
    messages=[
        {"role": "system", "content": "You are a homelab infrastructure expert."},
        {"role": "user", "content": "Help me optimize my K3s cluster"}
    ]
)
```

## Recommended Models

### GPT-4 Turbo
- Best for: Complex infrastructure design, troubleshooting
- Context: 128K tokens
- Use for: Large codebases, multi-file analysis
- Cost: Higher, but better quality

### GPT-4
- Best for: Code generation, refactoring
- Context: 8K tokens
- Use for: Standard development tasks
- Cost: Moderate

### GPT-3.5 Turbo
- Best for: Quick queries, simple tasks
- Context: 16K tokens
- Use for: Documentation, simple scripts
- Cost: Lower, faster responses

## Homelab-Specific System Prompts

### Infrastructure Expert Prompt
```
You are an expert in homelab infrastructure with deep knowledge of:
- Proxmox VE virtualization
- Kubernetes (K3s) orchestration
- Terraform infrastructure as code
- Ansible configuration management
- High availability systems
- Network design and security
- Storage solutions (Longhorn, NFS, TrueNAS)
- Service mesh (Cilium)
- Monitoring and observability (Prometheus, Grafana)

Provide detailed, production-ready solutions considering:
- Resource constraints of homelab hardware
- Cost-effectiveness
- Best practices for small-scale deployments
- Security hardening
- Backup and disaster recovery
```

### Code Review Prompt
```
You are a code reviewer for homelab infrastructure code.
Review code for:
- Security vulnerabilities
- Best practices compliance
- Resource efficiency
- Error handling
- Documentation quality
- Idempotency (for Ansible)
- State management (for Terraform)
- Kubernetes best practices
- Testing coverage
```

## Common Use Cases

### 1. Generate Infrastructure Code

**Prompt**:
```
Generate a Terraform module for provisioning a K3s cluster on Proxmox with:
- 1 control plane node (4 CPU, 8GB RAM)
- 3 worker nodes (2 CPU, 4GB RAM each)
- Network configuration with static IPs
- Cloud-init for automatic K3s installation
- Taints and labels for workload distribution
```

### 2. Debug Issues

**Prompt**:
```
I'm getting this error in my K3s cluster:
[paste error logs]

Context:
- Running K3s v1.29 on Proxmox VMs
- Using Cilium for CNI
- Longhorn for storage
- Error occurs when deploying new pods

Help me diagnose and fix this issue.
```

### 3. Optimize Configuration

**Prompt**:
```
Review and optimize this Kubernetes deployment manifest:
[paste manifest]

Optimize for:
- Resource utilization in a 3-node homelab cluster
- High availability
- Security best practices
- Monitoring integration
```

### 4. Create Documentation

**Prompt**:
```
Create a comprehensive runbook for deploying Nextcloud on my homelab K3s cluster.

Include:
- Prerequisites (storage, certificates, DNS)
- Step-by-step deployment instructions
- Configuration for Longhorn persistent storage
- Traefik ingress setup
- Backup procedures
- Troubleshooting common issues
- Upgrade procedures
```

### 5. Migration Planning

**Prompt**:
```
I need to migrate my Docker Compose applications to Kubernetes.
Current setup: [describe]
Target: K3s cluster with HA
Help me plan the migration including:
- Service-by-service migration strategy
- Storage migration (volumes to PVCs)
- Network configuration
- Secrets management
- Testing approach
```

## Advanced Integrations

### VS Code Snippets with GPT

Create custom snippets using ChatGPT:
```
Generate VS Code snippets for common Kubernetes manifests in my homelab:
1. Deployment with Longhorn PVC
2. Service with MetalLB LoadBalancer
3. Ingress with Traefik and cert-manager
4. ServiceMonitor for Prometheus
```

### Automated Code Review

```python
# Script to automatically review pull requests
import openai
import subprocess

def get_diff():
    result = subprocess.run(['git', 'diff', 'main'], capture_output=True, text=True)
    return result.stdout

diff = get_diff()

response = openai.ChatCompletion.create(
    model="gpt-4-turbo-preview",
    messages=[
        {"role": "system", "content": "You are a code reviewer for homelab infrastructure."},
        {"role": "user", "content": f"Review this diff:\n\n{diff}"}
    ]
)

print(response.choices[0].message.content)
```

### Infrastructure as Code Generation

```python
# Generate Terraform code from requirements
def generate_terraform(requirements):
    response = openai.ChatCompletion.create(
        model="gpt-4-turbo-preview",
        messages=[
            {"role": "system", "content": "You are a Terraform expert for Proxmox homelab."},
            {"role": "user", "content": f"Generate Terraform code for: {requirements}"}
        ]
    )
    return response.choices[0].message.content

# Example usage
requirements = "Create 3 Ubuntu VMs with 2 CPU, 4GB RAM each, on VLAN 10"
terraform_code = generate_terraform(requirements)
print(terraform_code)
```

## Best Practices

### 1. Context Management
- Start conversations with homelab context
- Reference specific versions (K3s 1.29, Terraform 1.7)
- Include relevant error messages in full
- Share complete configuration files when needed

### 2. Iterative Development
```
# Good workflow:
1. Ask for high-level design
2. Request detailed implementation
3. Ask for testing strategy
4. Request documentation
5. Query for optimization opportunities
```

### 3. Code Validation
- Always test generated code
- Run linters (terraform validate, ansible-lint)
- Check for security issues
- Verify against homelab constraints

### 4. Security
- Never share real API keys in prompts
- Use placeholders for secrets
- Review generated code for vulnerabilities
- Sanitize logs before sharing

## Example Workflows

### Deploying a New Service

1. **Design Phase**
```
Design a highly available PostgreSQL deployment for my K3s homelab:
- 3 replicas with streaming replication
- Longhorn for persistent storage
- Backup to MinIO S3
- Monitoring with Prometheus
- Resource limits for 3-node cluster
```

2. **Implementation Phase**
```
Generate the Kubernetes manifests for the PostgreSQL design.
Include:
- StatefulSet
- Service (ClusterIP and LoadBalancer)
- PersistentVolumeClaims
- ConfigMap for PostgreSQL config
- Secret placeholders
- ServiceMonitor
```

3. **Testing Phase**
```
Create a test plan for the PostgreSQL deployment:
- Health check verification
- Failover testing
- Backup and restore testing
- Performance benchmarks
- Monitoring validation
```

4. **Documentation Phase**
```
Generate deployment documentation for this PostgreSQL setup.
Include operations procedures for:
- Initial deployment
- Scaling
- Backup/restore
- Troubleshooting
- Upgrade procedures
```

## Cost Optimization

### Token Management
- Use GPT-3.5 for simple queries
- Reserve GPT-4 for complex tasks
- Implement caching for repeated queries
- Summarize context to reduce tokens

### Batch Processing
```python
# Process multiple files efficiently
files = ['file1.tf', 'file2.tf', 'file3.tf']
combined_content = "\n\n---\n\n".join([open(f).read() for f in files])

response = openai.ChatCompletion.create(
    model="gpt-4-turbo-preview",
    messages=[
        {"role": "system", "content": "Review these Terraform files"},
        {"role": "user", "content": combined_content}
    ]
)
```

## Troubleshooting

### API Errors
```python
# Handle rate limits and errors
import time
from openai.error import RateLimitError, APIError

def call_with_retry(func, max_retries=3):
    for i in range(max_retries):
        try:
            return func()
        except RateLimitError:
            time.sleep(2 ** i)  # Exponential backoff
        except APIError as e:
            print(f"API Error: {e}")
            return None
```

### Extension Issues
- Check API key configuration
- Verify internet connectivity
- Review VS Code extension logs
- Try alternative extensions
- Update to latest extension version

## Resources

- [OpenAI Platform](https://platform.openai.com/)
- [OpenAI API Documentation](https://platform.openai.com/docs/)
- [ChatGPT Best Practices](https://platform.openai.com/docs/guides/gpt-best-practices)
- [VS Code Extensions Marketplace](https://marketplace.visualstudio.com/)
- Homelab documentation: `/workspace/Homelab/docs/`

## Environment Variables

```bash
# Set in ~/.bashrc or ~/.zshrc
export OPENAI_API_KEY="sk-..."
export OPENAI_ORG_ID="org-..."

# Or in .env file
echo 'OPENAI_API_KEY=sk-...' >> /workspace/.env
```

## Example .vscode/settings.json

```json
{
  "chatgpt.apiKey": "${env:OPENAI_API_KEY}",
  "chatgpt.model": "gpt-4-turbo-preview",
  "chatgpt.systemPrompt": "You are a homelab infrastructure expert specializing in K3s, Terraform, and Ansible.",
  "chatgpt.temperature": 0.7,
  "chatgpt.maxTokens": 4000,
  "chatgpt.lang": "en"
}
```
