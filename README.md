# VS Code Homelab Development Environment

A comprehensive, deployable VS Code environment specifically configured for building and maintaining your homelab infrastructure. This repository provides a complete development setup with all necessary CLI tools, extensions, and AI assistant integrations.

## Features

### Core Tools & Technologies
- **Terraform 1.7+** - Infrastructure as Code
- **Ansible 2.16+** - Configuration Management
- **Kubernetes (kubectl, helm, k9s)** - Container Orchestration
- **Docker & Docker Compose** - Containerization
- **Python 3.11+** - Automation & Scripting
- **Node.js 20+** - MCP workspace support

### Infrastructure Tools
- K3s/Kubernetes management tools
- ArgoCD CLI for GitOps
- Kustomize for manifest management
- Flux CLI for GitOps alternative
- Proxmox API clients

### Development Tools
- Pre-commit hooks framework
- Linting: ansible-lint, yamllint, shellcheck, hadolint
- Testing: pytest, molecule
- Formatting: black, prettier
- Documentation: mkdocs

### AI Assistant Integration
- **GitHub Copilot** - Code completion and chat
- **Claude Code** - Advanced AI assistance
- **Google Gemini** - Multi-modal AI support
- **ChatGPT/OpenAI** - Custom integrations

## ⚙️ Before You Start

**First-time setup** (do this once):

1. **Clone the repository**:

   ```bash
   git clone https://github.com/jwrv/VS-code-home-lab.git
   cd VS-code-home-lab
   ```

2. **Configure environment variables**:

   ```bash
   # Copy template and edit with your values
   cp .env.example .env
   nano .env  # or vim, code, etc.
   ```

   See [.env.example](.env.example) for all configuration options.

3. **Set up code quality hooks** (optional but recommended):

   ```bash
   # Install pre-commit framework
   pip install pre-commit

   # Install git hooks
   pre-commit install

   # Test (optional)
   pre-commit run --all-files
   ```

4. **Verify Homelab repository location**:

   The workspace expects your Homelab repository at `../Homelab` (sibling directory).
   If yours is elsewhere, update `HOMELAB_PATH` in `.env` or adjust workspace folder paths.

## 🚀 Recommended: Use the Optimized Workspace!

**The fastest way to get started** is using the pre-configured workspace file:

1. **Open the workspace**:

   ```bash
   code homelab.code-workspace
   ```

**That's it!** The workspace automatically:
- ✅ Opens all homelab folders organized by purpose
- ✅ Configures AI assistants optimally
- ✅ Sets up terminals (WSL by default)
- ✅ Enables auto-formatting and linting
- ✅ Provides quick tasks (Ctrl+Shift+B)

**See the [Workspace Guide](docs/WORKSPACE_GUIDE.md) for full details!**

---

## Alternative Setup Options

### Option 1: Dev Container

1. **Prerequisites**:
   - VS Code with Remote - Containers extension
   - Docker Desktop or Docker Engine

2. **Clone and Open**:
   ```bash
   git clone https://github.com/jwrv/VS-code-home-lab.git
   cd VS-code-home-lab
   code .
   ```

3. **Reopen in Container**:
   - Press `F1` or `Ctrl+Shift+P`
   - Select: "Dev Containers: Reopen in Container"
   - Wait for container to build (first time takes 5-10 minutes)

4. **Start Working**:
   - All tools are pre-installed
   - Extensions are automatically installed
   - Terminal has all CLI tools available

### Option 2: Docker Compose

```bash
git clone https://github.com/jwrv/VS-code-home-lab.git
cd VS-code-home-lab
docker-compose up -d
```

Access VS Code at: http://localhost:8080 (code-server)

### Option 3: Kubernetes Deployment

Deploy VS Code Server to your homelab K3s cluster:

```bash
kubectl apply -f kubernetes/
```

Access via ingress (configure DNS/hosts file accordingly).

### Option 4: Local Installation

Install extensions and tools locally:

```bash
# Install VS Code extensions
cat .vscode/extensions.json | jq -r '.recommendations[]' | xargs -L 1 code --install-extension

# Install tools (requires manual setup based on your OS)
# See: docs/local-installation.md
```

## Project Structure

```
.
├── .vscode/                      # VS Code configuration
│   ├── extensions.json          # Recommended extensions
│   ├── settings.json            # Workspace settings
│   └── tasks.json               # Common tasks
├── .devcontainer/               # Dev container configuration
│   ├── devcontainer.json        # Container definition
│   ├── Dockerfile               # Container image
│   └── post-create.sh           # Post-creation script
├── .ai-assistants/              # AI assistant configurations
│   ├── claude-code-config.md    # Claude Code setup
│   ├── github-copilot-config.md # Copilot configuration
│   ├── gemini-config.md         # Gemini integration
│   └── chatgpt-codex-config.md  # ChatGPT/Codex setup
├── kubernetes/                   # K8s deployment manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   └── pvc.yaml
├── docker-compose.yml           # Docker Compose deployment
├── Makefile                     # Common operations
├── README.md                    # This file
└── docs/                        # Additional documentation
    ├── local-installation.md
    ├── kubernetes-deployment.md
    ├── ai-assistants-guide.md
    └── troubleshooting.md
```

## Configuration

### Important Path Requirements

**This workspace expects your main Homelab repository to exist at `../Homelab`** (as a sibling
directory to VS-code-home-lab).

If your Homelab repository is located elsewhere:

1. **Option A: Update `.env` file** (recommended):

   ```bash
   # In .env
   HOMELAB_PATH=/path/to/your/Homelab
   ```

2. **Option B: Adjust workspace folder paths**:
   Edit [homelab.code-workspace](homelab.code-workspace) and update folder paths:

   ```json
   "folders": [
     { "name": "🏠 Homelab Root", "path": "." },
     { "name": "☸️ Kubernetes", "path": "/your/path/to/Homelab/infra/kubernetes" },
     { "name": "🔧 Terraform", "path": "/your/path/to/Homelab/infra/terraform" },
     // etc...
   ]
   ```

3. **Option C: Use symbolic link**:

   ```bash
   # Create symlink to match expected location
   ln -s /path/to/your/Homelab ../Homelab
   ```

**Why this matters**: Tasks, launch configurations, and documentation all assume this structure.
Getting this right ensures commands run in the correct directories.

### Connecting to Your Homelab

#### 1. Environment Variables

All configuration is centralized in `.env`. **Copy `.env.example` to `.env` and customize**:

```bash
cp .env.example .env
```

Key variables to configure:

- `KUBECONFIG` - Path to your Kubernetes config
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` - For Terraform state (MinIO/S3)
- `PROXMOX_VE_ENDPOINT` - Proxmox API endpoint
- `ANSIBLE_VAULT_PASSWORD_FILE` - Path to Ansible vault password
- `SSH_KEY_PATH` - SSH key for homelab servers

See [.env.example](.env.example) for complete documentation.

#### 2. SSH Keys

```bash
# Dev container automatically mounts ~/.ssh
# For Docker Compose, add volume in docker-compose.yml:
volumes:
  - ~/.ssh:/root/.ssh:ro
```

Or set in `.env`:

```bash
SSH_KEY_PATH=/path/to/your/ssh/key
```

#### 3. Kubeconfig

Configure in `.env`:

```bash
KUBECONFIG=/path/to/your/kubeconfig
```

Or copy to standard location:

```bash
mkdir -p ~/.kube
cp /path/to/homelab/kubeconfig ~/.kube/config
```

#### 3. Terraform State
```bash
# Configure S3 backend (MinIO or AWS)
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

#### 4. Ansible Vault
```bash
# Store vault password
echo "your-vault-password" > .vault_pass
chmod 600 .vault_pass
```

### AI Assistant Setup

#### GitHub Copilot
1. Sign in to GitHub in VS Code
2. Copilot will activate automatically
3. See [.ai-assistants/github-copilot-config.md](.ai-assistants/github-copilot-config.md)

#### Claude Code
1. Already installed in extensions
2. Authenticate when prompted
3. See [.ai-assistants/claude-code-config.md](.ai-assistants/claude-code-config.md)

#### Google Gemini
1. Install Cloud Code extension
2. Authenticate: `gcloud auth login`
3. See [.ai-assistants/gemini-config.md](.ai-assistants/gemini-config.md)

#### ChatGPT/OpenAI
1. Install ChatGPT extension from marketplace
2. Configure API key in settings
3. See [.ai-assistants/chatgpt-codex-config.md](.ai-assistants/chatgpt-codex-config.md)

## Common Tasks

### Using VS Code Tasks

Press `Ctrl+Shift+B` or `F1` → "Tasks: Run Task"

Available tasks:
- **Terraform**: Init, Plan, Validate, Format
- **Ansible**: Lint, Syntax Check, Generate Inventory
- **Kubernetes**: Get Pods/Services, Apply Manifests, Validate
- **Docker**: Build, Compose Up/Down
- **Testing**: Run Tests, Lint All
- **Documentation**: Serve/Build MkDocs

### Using Makefile

```bash
# Initialize homelab environment
make init

# Validate all configurations
make validate

# Plan infrastructure changes
make plan

# Deploy platform services
make deploy-platform

# Run all tests
make test

# Generate documentation
make docs
```

### Command Line Examples

```bash
# Terraform workflow
cd /workspace/Homelab/infra/terraform
terraform init
terraform plan
terraform apply

# Ansible workflow
cd /workspace/Homelab/infra/ansible
ansible-playbook playbooks/deploy-k3s.yml

# Kubernetes operations
kubectl get pods -A
kubectl apply -f manifest.yaml
k9s  # Interactive UI

# Testing
cd /workspace/Homelab
pytest tests/
```

## AI-Assisted Workflows

### Example: Deploy New Service with AI

1. **Use Claude Code** to design the architecture:
   ```
   Design a highly available Redis deployment for my K3s homelab
   ```

2. **Use Copilot** to generate Kubernetes manifests:
   - Start typing and let Copilot suggest

3. **Use Gemini** to review for best practices:
   ```
   Review this manifest for security and efficiency
   ```

4. **Use ChatGPT** for documentation:
   ```
   Create a runbook for this Redis deployment
   ```

### Example: Troubleshooting with AI

1. Gather information:
   ```bash
   kubectl logs pod-name > logs.txt
   kubectl describe pod pod-name > describe.txt
   ```

2. Ask AI assistants:
   - Claude Code: Paste logs and ask for analysis
   - Copilot Chat: "What's wrong with this pod?"
   - Gemini: "Debug this Kubernetes issue"

## Customization

### Add Custom Extensions
Edit [.vscode/extensions.json](.vscode/extensions.json):
```json
{
  "recommendations": [
    "your.extension.id"
  ]
}
```

### Add Custom Tasks
Edit [.vscode/tasks.json](.vscode/tasks.json):
```json
{
  "label": "Your Task",
  "type": "shell",
  "command": "your-command"
}
```

### Modify Dev Container
Edit [.devcontainer/Dockerfile](.devcontainer/Dockerfile) to add tools:
```dockerfile
RUN apt-get install -y your-package
```

## Deployment Options

### 1. Local Dev Container
- **Pros**: Full IDE features, fast, offline capable
- **Cons**: Requires local Docker
- **Best for**: Primary development machine

### 2. Remote Container (SSH)
- **Pros**: Use homelab resources, persistent
- **Cons**: Requires SSH access
- **Best for**: Dedicated homelab dev VM

### 3. Kubernetes Deployment
- **Pros**: HA, scalable, homelab-native
- **Cons**: More complex setup
- **Best for**: Team environments, production-like

### 4. Docker Compose
- **Pros**: Simple, portable
- **Cons**: Less integration than dev container
- **Best for**: Quick testing, CI/CD

## Troubleshooting

### Dev Container Issues

**Container fails to build**:
```bash
# Rebuild without cache
docker-compose build --no-cache
```

**Extensions not installing**:
```bash
# Manually install inside container
code --install-extension extension.id
```

**Permission issues**:
```bash
# Fix SSH key permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
```

### Tool Issues

**kubectl not connecting**:
```bash
# Check kubeconfig
export KUBECONFIG=/workspace/.kube/config
kubectl config view
```

**Terraform state locked**:
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

**Ansible vault password**:
```bash
# Set vault password file
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
```

### AI Assistant Issues

See [docs/troubleshooting.md](docs/troubleshooting.md) for detailed AI troubleshooting.

## Security Considerations

### Secrets Management
- Never commit secrets to git
- Use environment variables
- Leverage Vault integration
- Use `.gitignore` for sensitive files

### Network Security
- Use SSH keys, not passwords
- Enable 2FA for GitHub/cloud providers
- Use VPN (Tailscale) for remote access
- Restrict kubeconfig permissions

### Container Security
- Regular image updates
- Scan for vulnerabilities
- Use minimal base images
- Run as non-root when possible

## Performance Tips

### Dev Container
- Use volume mounts for large datasets
- Enable BuildKit for faster builds
- Increase Docker resources in settings
- Use .dockerignore to exclude files

### AI Assistants
- Use appropriate model for task
- Cache frequent queries
- Manage token usage
- Use local inference when possible

## Resources

### Documentation
- [AI Assistants Guide](docs/ai-assistants-guide.md)
- [Local Installation](docs/local-installation.md)
- [Kubernetes Deployment](docs/kubernetes-deployment.md)
- [Troubleshooting](docs/troubleshooting.md)

### External Links
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [Homelab Repository](https://github.com/jwrv/Homelab)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

### Homelab Infrastructure
- Architecture: `/workspace/Homelab/docs/architecture/`
- Runbooks: `/workspace/Homelab/docs/runbooks/`
- Network Docs: `/workspace/Homelab/docs/network/`

## Contributing

This is a personal homelab configuration, but feel free to:
- Fork for your own use
- Submit issues for bugs
- Suggest improvements
- Share your customizations

## License

MIT License - See LICENSE file for details

## Support

- Issues: https://github.com/jwrv/VS-code-home-lab/issues
- Homelab Docs: `/workspace/Homelab/docs/`
- AI Assistant Configs: `.ai-assistants/`

## Changelog

### v1.0.0 - Initial Release
- Complete dev container setup
- All homelab CLI tools
- AI assistant integrations
- Kubernetes deployment option
- Comprehensive documentation

---

**Built for managing enterprise-grade homelab infrastructure with AI-powered development tools.**
