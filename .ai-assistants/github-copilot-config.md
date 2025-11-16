# GitHub Copilot Configuration for Homelab

## Overview
GitHub Copilot is configured to provide intelligent code suggestions for all homelab-related development tasks.

## Enabled Languages
- Terraform (HCL)
- Ansible (YAML)
- Python
- Bash/Shell
- Kubernetes YAML
- Markdown
- JSON

## Custom Instructions

### Infrastructure as Code
When writing Terraform:
- Use variables for reusable values
- Follow module-based architecture
- Include validation rules
- Add meaningful descriptions
- Tag all resources

When writing Ansible:
- Use roles for reusability
- Implement idempotency
- Add handlers for service restarts
- Use templates (Jinja2) for configs
- Include task names for clarity

### Kubernetes Manifests
- Always specify resource limits and requests
- Use namespaces for organization
- Implement health checks (liveness, readiness)
- Add labels for selection and organization
- Use secrets and configmaps for configuration

### Python Scripts
- Follow PEP 8 style guide
- Use type hints
- Include docstrings
- Implement error handling
- Write unit tests (pytest)

### Bash Scripts
- Start with `#!/bin/bash`
- Use `set -euo pipefail`
- Quote variables
- Check command existence
- Provide usage information

## Copilot Chat Instructions

### Common Queries
1. "How do I deploy a new service to K3s?"
2. "Write an Ansible role for [service]"
3. "Create a Terraform module for [resource]"
4. "Debug this Kubernetes deployment"
5. "Optimize this Python script"

### Context to Provide
When asking Copilot Chat for help:
- Mention the homelab context
- Specify versions (K3s 1.29, Terraform 1.7, Ansible 2.16)
- Include relevant error messages
- Share related configurations
- Describe the desired outcome

## VS Code Integration

### Inline Suggestions
Copilot is enabled for:
- Code completion
- Function/class generation
- Comment-to-code conversion
- Test generation
- Documentation writing

### Copilot Labs Features
- Explain code
- Translate between languages
- Test generation
- Code brushes (refactoring)

## Best Practices

1. **Review suggestions** - Always review Copilot's suggestions before accepting
2. **Security** - Verify no secrets are included in generated code
3. **Standards** - Ensure generated code follows homelab conventions
4. **Testing** - Test Copilot-generated code thoroughly
5. **Documentation** - Document complex Copilot-assisted implementations

## Homelab-Specific Patterns

### Service Deployment Pattern
```yaml
# Copilot knows to include these for homelab services
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-name
  namespace: apps
  labels:
    app: service-name
    environment: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: service-name
  template:
    metadata:
      labels:
        app: service-name
    spec:
      containers:
      - name: service-name
        image: image:tag
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8080
        readinessProbe:
          httpGet:
            path: /ready
            port: 8080
```

### Terraform Module Pattern
```hcl
# Standard homelab Terraform module structure
variable "name" {
  description = "Resource name"
  type        = string
  validation {
    condition     = length(var.name) > 0
    error_message = "Name must not be empty."
  }
}

resource "proxmox_vm_qemu" "vm" {
  name        = var.name
  target_node = var.node

  tags = "homelab,managed-by-terraform"

  lifecycle {
    prevent_destroy = false
  }
}
```

## Troubleshooting

If Copilot suggestions seem off:
1. Add more context in comments
2. Show examples in nearby files
3. Use more descriptive variable/function names
4. Leverage Copilot Chat for clarification
5. Provide the full file context

## Privacy & Security

- Copilot suggestions are based on public code patterns
- Never commit API keys, passwords, or tokens
- Use placeholders for sensitive values
- Review all suggestions for security implications
- Disable Copilot for files containing secrets
