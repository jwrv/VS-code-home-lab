#!/bin/bash
# Post-create script for VS Code dev container
# Runs after the container is created

set -e

echo "Running post-create setup..."

# Update pip
python3 -m pip install --upgrade pip

# Install additional Python packages if requirements.txt exists
if [ -f "/workspace/Homelab/requirements-dev.txt" ]; then
    echo "Installing Python dependencies from requirements-dev.txt..."
    pip install -r /workspace/Homelab/requirements-dev.txt
fi

# Set up pre-commit hooks if config exists
if [ -f "/workspace/Homelab/.pre-commit-config.yaml" ]; then
    echo "Installing pre-commit hooks..."
    cd /workspace/Homelab
    pre-commit install --install-hooks
    cd /workspace
fi

# Create default kubeconfig if it doesn't exist
if [ ! -f "/root/.kube/config" ]; then
    echo "Creating default kubeconfig directory..."
    mkdir -p /root/.kube
fi

# Set proper permissions for SSH keys
if [ -d "/root/.ssh" ]; then
    echo "Setting SSH key permissions..."
    chmod 700 /root/.ssh
    find /root/.ssh -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} \;
fi

# Initialize Terraform plugins cache
echo "Creating Terraform plugin cache directory..."
mkdir -p /root/.terraform.d/plugin-cache
cat > /root/.terraformrc <<EOF
plugin_cache_dir = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true
EOF

# Set up Ansible configuration
if [ ! -f "/root/.ansible.cfg" ]; then
    echo "Creating default Ansible configuration..."
    cat > /root/.ansible.cfg <<EOF
[defaults]
host_key_checking = False
stdout_callback = yaml
callbacks_enabled = profile_tasks, timer
deprecation_warnings = False
EOF
fi

# Display tool versions
echo ""
echo "=== Installed Tool Versions ==="
echo "Terraform: $(terraform --version | head -n1)"
echo "Ansible: $(ansible --version | head -n1)"
echo "kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "Helm: $(helm version --short)"
echo "Docker: $(docker --version)"
echo "Python: $(python3 --version)"
echo "Node.js: $(node --version)"
echo "================================"
echo ""

# Create workspace info file
cat > /workspace/.container-info <<EOF
Container built: $(date)
Homelab VS Code Development Environment
Ready for infrastructure management and development.

Quick start:
  - All homelab tools are pre-installed
  - Use 'k' alias for kubectl
  - Use 'tf' alias for terraform
  - Use 'ap' alias for ansible-playbook
  - Use 'dc' alias for docker-compose

Documentation: See README.md
EOF

echo "Post-create setup complete!"
cat /workspace/.container-info
