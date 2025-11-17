# Daily Homelab Workflow Guide

This guide shows you how to use the VS Code homelab environment for common daily tasks. Each section
includes the exact steps and VS Code features to use.

## Table of Contents

- [Starting Your Day](#starting-your-day)
- [Infrastructure Changes](#infrastructure-changes)
- [Service Deployments](#service-deployments)
- [Troubleshooting](#troubleshooting)
- [Monitoring & Health Checks](#monitoring--health-checks)
- [Secrets Management](#secrets-management)
- [Git Workflow](#git-workflow)
- [Using AI Assistants Effectively](#using-ai-assistants-effectively)

## Starting Your Day

### 1. Open the Workspace

```bash
# From terminal
code ~/VS-code-home-lab/homelab.code-workspace
```

**Or double-click** `homelab.code-workspace` in your file explorer.

### 2. Run Morning Health Check

Press `Ctrl+Shift+B` → Select **"🏥 Homelab Health Check"**

This shows:

- All Kubernetes nodes status
- Any pods not in Running state
- Quick overview of cluster health

**AI Tip**: Ask Claude Code: *"Check the health of my homelab and summarize any issues"*

### 3. Check for Git Updates

```bash
# In terminal (Ctrl+`)
git fetch --all
git status
```

**Or use GitLens**: Click Git icon in Activity Bar → See incoming changes

## Infrastructure Changes

### Deploying New Terraform Modules

**Workflow**:

1. **Navigate to Terraform folder**: Click `🔧 Terraform` in sidebar
2. **Create/Edit .tf files**: AI assistants will suggest as you type
3. **Validate syntax**: Press `Ctrl+Shift+B` → "Terraform: Validate"
4. **Format code**: Right-click → "Format Document" (or save, auto-formats)
5. **Run terraform plan**:

   ```bash
   cd ../Homelab/infra/terraform
   terraform plan -out=tfplan
   ```

6. **Review plan**: AI can explain: *"What does this terraform plan do?"*
7. **Apply changes**:

   ```bash
   terraform apply tfplan
   ```

8. **Commit to Git**:

   ```bash
   git add .
   git commit -m "Add [module name] infrastructure"
   git push
   ```

**VS Code Launch Config**: Press `F5` → Select **"Terraform: Plan Current Module"**

**AI Workflow**:

```
You: "Create a Terraform module for a Proxmox VM with 4GB RAM and 2 CPUs"
AI: [Generates module with proper structure]
You: "Run terraform plan to see what this will create"
AI: [Executes via MCP, shows plan output]
```

### Updating Ansible Playbooks

**Workflow**:

1. **Navigate to Ansible folder**: Click `⚙️ Ansible` in sidebar
2. **Edit playbooks**: Use `.yml` files, AI suggests tasks
3. **Check syntax**: Press `Ctrl+Shift+B` → "Ansible: Syntax Check"
4. **Lint playbook**:

   ```bash
   ansible-lint playbooks/your-playbook.yml
   ```

5. **Run playbook** (dry-run first):

   ```bash
   cd ../Homelab/infra/ansible
   ansible-playbook playbooks/your-playbook.yml --check
   ```

6. **Apply playbook**:

   ```bash
   ansible-playbook playbooks/your-playbook.yml
   ```

**VS Code Launch Config**: Press `F5` → Select **"Ansible: Run Playbook (Dry Run)"**

**Common Playbooks**:

- `deploy-k3s.yml` - Deploy/update K3s cluster
- `update-packages.yml` - Update all homelab servers
- `backup-configs.yml` - Backup configurations
- `rotate-secrets.yml` - Rotate credentials

## Service Deployments

### Deploying to Kubernetes

**Workflow**:

1. **Navigate to K8s folder**: Click `☸️ Kubernetes` in sidebar
2. **Create/edit manifests**: AI suggests Kubernetes YAML
3. **Validate YAML**:

   ```bash
   kubectl apply --dry-run=client -f deployment.yaml
   ```

4. **Apply to cluster**:

   ```bash
   kubectl apply -f deployment.yaml
   ```

5. **Watch deployment**:

   ```bash
   kubectl rollout status deployment/your-deployment
   ```

6. **Check pods**:

   ```bash
   kubectl get pods -l app=your-app
   ```

**AI Workflow**:

```
You: "Deploy nginx with 3 replicas, Longhorn storage, and Traefik ingress"
AI: [Generates complete deployment, service, PVC, and ingress manifests]
You: "Apply these to the cluster"
AI: [Executes kubectl apply via MCP]
You: "Check if pods are running"
AI: [Runs kubectl get pods, shows status]
```

**VS Code Kubernetes Extension**:

- Click Kubernetes icon in Activity Bar
- Right-click resource → "Describe"/"Logs"/"Delete"
- Visual cluster navigation

### Using Helm Charts

**Workflow**:

1. **Add Helm repo** (if needed):

   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   ```

2. **Create values file**: `values.yaml` in Kubernetes folder
3. **Install chart**:

   ```bash
   helm install my-release bitnami/postgresql -f values.yaml
   ```

4. **Check status**:

   ```bash
   helm status my-release
   ```

**AI Tip**: *"Create a Helm values file for PostgreSQL with persistent storage"*

## Troubleshooting

### When Pods Are Failing

**Step-by-step**:

1. **Find the failing pod**:

   ```bash
   kubectl get pods -A | grep -v Running
   ```

2. **Describe the pod**:

   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```

3. **Check logs**:

   ```bash
   kubectl logs <pod-name> -n <namespace> --tail=100
   ```

4. **Ask AI for help**:

   ```
   You: [Paste error logs]
   You: "What's causing this pod to fail?"
   AI: [Analyzes logs, suggests fixes]
   ```

5. **Check events**:

   ```bash
   kubectl get events -n <namespace> --sort-by='.lastTimestamp'
   ```

**VS Code Tip**: Right-click pod in Kubernetes sidebar → "Logs" opens in panel

### When Terraform Apply Fails

**Step-by-step**:

1. **Read the error carefully**: Terraform errors are usually clear
2. **Check state**:

   ```bash
   terraform state list
   ```

3. **Validate configuration**:

   ```bash
   terraform validate
   ```

4. **Ask AI**:

   ```
   You: [Paste terraform error]
   You: "How do I fix this?"
   AI: [Suggests solution]
   ```

5. **If state is corrupted**:

   ```bash
   terraform state pull > backup.tfstate
   # Fix manually or ask AI for help
   ```

### When Ansible Playbook Fails

**Step-by-step**:

1. **Run with verbose output**:

   ```bash
   ansible-playbook playbook.yml -vvv
   ```

2. **Check specific host**:

   ```bash
   ansible hostname -m ping
   ```

3. **Run single task**:

   ```bash
   ansible-playbook playbook.yml --start-at-task="Task Name"
   ```

4. **Ask AI**: *"This Ansible task failed with [error], how do I fix it?"*

## Monitoring & Health Checks

### Quick Cluster Status

**From terminal**:

```bash
# Node status
kubectl get nodes

# All pods
kubectl get pods -A

# Services
kubectl get services -A

# Persistent volumes
kubectl get pv,pvc -A
```

**Or press `Ctrl+Shift+B`** → "🏥 Homelab Health Check"

### Using K9s (Interactive TUI)

**Launch K9s**:

```bash
k9s
```

**Common K9s commands**:

- `:pods` - View all pods
- `:svc` - View services
- `:deploy` - View deployments
- `/` - Filter/search
- `d` - Describe resource
- `l` - View logs
- `Ctrl+a` - All namespaces

**AI Integration**: Ask Claude: *"Launch k9s and show me all failing pods"*

### Checking Logs

**Kubernetes logs**:

```bash
# Single pod
kubectl logs <pod-name> -n <namespace> --tail=100 -f

# All pods in deployment
kubectl logs -l app=myapp --tail=50

# Previous container (if crashed)
kubectl logs <pod-name> --previous
```

**System logs** (on homelab servers):

```bash
# Via SSH
journalctl -u k3s -f
journalctl -u docker -f
```

### Resource Usage

**Cluster resources**:

```bash
kubectl top nodes
kubectl top pods -A
```

**Node resources** (SSH to server):

```bash
htop
df -h
free -h
```

## Secrets Management

### Using Ansible Vault

**Create encrypted file**:

```bash
cd ../Homelab/infra/ansible
ansible-vault create secrets.yml
# Enter vault password (stored in .vault_pass)
```

**Edit encrypted file**:

```bash
ansible-vault edit secrets.yml
```

**Encrypt existing file**:

```bash
ansible-vault encrypt vars/sensitive.yml
```

**In playbooks**:

```yaml
- hosts: all
  vars_files:
    - secrets.yml
  tasks:
    - name: Use secret
      debug:
        msg: "{{ secret_password }}"
```

**Run with vault password**:

```bash
ansible-playbook playbook.yml --vault-password-file=.vault_pass
```

### Kubernetes Secrets

**Create from literal**:

```bash
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123
```

**Create from file**:

```bash
kubectl create secret generic tls-cert \
  --from-file=tls.crt=cert.pem \
  --from-file=tls.key=key.pem
```

**Use in deployment**:

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: my-secret
        key: password
```

### Rotating Secrets

**Best practice workflow**:

1. **Create new secret** (different name)
2. **Update deployments** to use new secret
3. **Apply changes**: `kubectl apply -f deployment.yaml`
4. **Verify** pods are running with new secret
5. **Delete old secret**: `kubectl delete secret old-secret`

**AI Tip**: *"Create an Ansible playbook to rotate SSH keys on all servers"*

## Git Workflow

### Making Changes

**Daily commit workflow**:

1. **Check status**:

   ```bash
   git status
   ```

2. **Stage changes**:

   ```bash
   git add .
   ```

3. **Commit** (AI can write message):

   ```bash
   git commit -m "Add PostgreSQL deployment"
   ```

4. **Push**:

   ```bash
   git push
   ```

**VS Code Git Integration**:

- Click Git icon in Activity Bar
- See all changes
- Stage files (click `+`)
- Write commit message
- Click ✓ to commit
- Click "..." → Push

### Branching for Experiments

**Create feature branch**:

```bash
git checkout -b feature/new-monitoring
```

**Make changes**, test, then:

```bash
git add .
git commit -m "Add Prometheus monitoring"
git push -u origin feature/new-monitoring
```

**Create pull request**: Use `gh` CLI or GitHub web UI

**Merge when ready**:

```bash
git checkout main
git pull
git merge feature/new-monitoring
git push
```

## Using AI Assistants Effectively

### GitHub Copilot

**Best for**:

- Auto-completing Kubernetes YAML
- Generating Terraform resources
- Writing Ansible tasks

**How to use**:

1. Start typing a comment: `# Create nginx deployment`
2. Press `Enter`
3. Copilot suggests code
4. Press `Tab` to accept, `Alt+]` for next suggestion

### Claude Code (via Chat)

**Best for**:

- Complex multi-step tasks
- Troubleshooting errors
- Explaining existing code

**How to use**:

1. Open Claude Code panel
2. Ask questions naturally
3. Claude can execute commands via MCP

**Example conversations**:

```
You: "My Traefik ingress isn't working, help me debug"
Claude: [Asks for logs, checks config, suggests fixes]

You: "Create a complete PostgreSQL deployment with backups"
Claude: [Generates deployment, service, PVC, backup CronJob]

You: "Optimize my Terraform code for readability"
Claude: [Refactors code, adds comments, improves structure]
```

### Continue.dev

**Best for**:

- Custom slash commands
- Codebase-aware suggestions
- Using local models

**Custom commands** (already configured):

- `/homelab-deploy` - Help deploy to K3s cluster
- `/terraform-module` - Create Terraform module
- `/ansible-role` - Generate Ansible role

**How to use**: Type `/` in chat to see all commands

### Google Gemini Code Assist

**Best for**:

- Multi-modal help (can analyze diagrams)
- Code reviews
- Alternative perspective

**How to use**: Right-click code → "Ask Gemini"

## Quick Reference

### Most Common Tasks

| Task                      | Command / Shortcut              |
| ------------------------- | ------------------------------- |
| Health check              | `Ctrl+Shift+B` → Health Check   |
| Open terminal             | `Ctrl+` ` (backtick)            |
| Format code               | `Shift+Alt+F`                   |
| Git commit                | Click Git icon → Stage → Commit |
| Ask AI                    | Select code → Right-click       |
| Run task                  | `Ctrl+Shift+B`                  |
| Open command palette      | `Ctrl+Shift+P`                  |
| Search files              | `Ctrl+P`                        |
| Search in files           | `Ctrl+Shift+F`                  |
| Open Kubernetes view      | Click K8s icon in Activity Bar  |
| Switch terminal           | Click dropdown in terminal      |
| Split editor              | `Ctrl+\`                        |
| Close editor              | `Ctrl+W`                        |
| Open settings             | `Ctrl+,`                        |
| Toggle sidebar            | `Ctrl+B`                        |
| Toggle panel              | `Ctrl+J`                        |
| Zen mode (focus)          | `Ctrl+K Z`                      |
| Show problems             | `Ctrl+Shift+M`                  |
| Go to line                | `Ctrl+G`                        |
| Multi-cursor              | `Alt+Click`                     |
| Find and replace          | `Ctrl+H`                        |
| Comment/uncomment         | `Ctrl+/`                        |
| Duplicate line            | `Shift+Alt+Down`                |
| Move line up/down         | `Alt+Up/Down`                   |
| Open file in Kubernetes   | Right-click → Apply             |
| Describe K8s resource     | Right-click → Describe          |
| View K8s logs             | Right-click → Logs              |
| Terraform plan            | `F5` → Terraform Plan           |
| Ansible dry run           | `F5` → Ansible Dry Run          |
| Run pre-commit hooks      | `Ctrl+Shift+B` → Validate Code  |
| Open workspace settings   | File → Preferences → Settings   |
| Install extension         | Click Extensions → Search       |
| Reload window             | `Ctrl+Shift+P` → Reload Window  |
| Show Git changes          | Click file in Git sidebar       |
| Stage all                 | Git sidebar → `+` on Changes    |
| Discard changes           | Git sidebar → ↶ on file         |
| Create new terminal       | Terminal panel → `+` button     |
| Kill terminal             | Terminal panel → 🗑️ icon        |
| Open remote WSL           | Bottom-left → Reopen in WSL     |
| Access MCP tools          | Ask AI to run commands          |
| View extension logs       | Output panel → Select extension |
| Format on save            | Automatic (already configured)  |
| Auto-import organize      | Automatic on save               |
| Spell check               | Underlined words → Right-click  |
| Show all keyboard shortcuts | `Ctrl+K Ctrl+S`               |

### Environment Variables Reference

Set these in your shell or `.env` file:

```bash
# Terraform
export TF_DATA_DIR=~/.terraform.d
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret

# Ansible
export ANSIBLE_CONFIG=~/Homelab/infra/ansible/ansible.cfg
export ANSIBLE_VAULT_PASSWORD_FILE=~/.vault_pass
export ANSIBLE_INVENTORY=~/Homelab/infra/ansible/inventory

# Kubernetes
export KUBECONFIG=~/.kube/config

# Python virtual environment
export VIRTUAL_ENV=~/venv
```

## Tips & Tricks

### Speed Up Workflow

1. **Use keyboard shortcuts** - Much faster than mouse
2. **Ask AI first** - Claude/Copilot can generate boilerplate
3. **Create snippets** - For repeated YAML/Terraform blocks
4. **Use multi-cursor** - Edit multiple lines at once (`Alt+Click`)
5. **Terminal aliases** - Add to `~/.bashrc`:

   ```bash
   alias k='kubectl'
   alias kgp='kubectl get pods -A'
   alias tf='terraform'
   alias ap='ansible-playbook'
   ```

### Avoid Common Mistakes

1. **Always dry-run first** - `--check`, `--dry-run`, `plan` before apply
2. **Commit often** - Small commits are easier to revert
3. **Read error messages** - They usually tell you exactly what's wrong
4. **Ask AI to explain** - Don't guess, understand
5. **Back up state** - Terraform state, kubeconfig, Ansible vault passwords

### When to Use Each Tool

- **Terraform**: Infrastructure provisioning (VMs, networks, storage)
- **Ansible**: Configuration management (packages, services, files)
- **Kubernetes**: Container orchestration (deployments, services)
- **Docker Compose**: Local testing, simple multi-container apps
- **Helm**: Kubernetes package management
- **K9s**: Interactive cluster exploration
- **kubectl**: Precise Kubernetes operations

## Next Steps

- Read [OPERATIONS_RUNBOOK.md](OPERATIONS_RUNBOOK.md) for emergency procedures
- See [AI_ASSISTANTS_SETUP.md](AI_ASSISTANTS_SETUP.md) for AI configuration
- Check [WORKSPACE_GUIDE.md](WORKSPACE_GUIDE.md) for workspace features
- Review [WINDOWS_WSL_SETUP.md](WINDOWS_WSL_SETUP.md) for environment setup
