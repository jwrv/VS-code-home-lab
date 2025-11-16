# Homelab VS Code Development Container
# Includes all tools needed for building and maintaining the homelab

ARG VARIANT="3.11-bullseye"
FROM mcr.microsoft.com/vscode/devcontainers/python:${VARIANT}

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV TERRAFORM_VERSION=1.7.5
ENV ANSIBLE_VERSION=2.16.4
ENV K3S_VERSION=v1.29.2+k3s1
ENV HELM_VERSION=3.14.2
ENV KUBECTL_VERSION=1.29.2

# Update and install system dependencies
RUN apt-get update && apt-get install -y \
    # Essential build tools
    build-essential \
    gcc \
    g++ \
    make \
    cmake \
    git \
    curl \
    wget \
    unzip \
    zip \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    # Network tools
    net-tools \
    iputils-ping \
    dnsutils \
    traceroute \
    netcat \
    telnet \
    nmap \
    tcpdump \
    iperf3 \
    iproute2 \
    # System monitoring
    htop \
    iotop \
    sysstat \
    # Text processing
    jq \
    yq \
    xmlstarlet \
    # SSL/TLS tools
    openssl \
    # SSH
    openssh-client \
    sshpass \
    # Version control
    git-lfs \
    # Shell tools
    bash-completion \
    vim \
    nano \
    tmux \
    screen \
    # Other utilities
    tree \
    rsync \
    expect \
    && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    terraform --version

# Install Ansible and Ansible Lint
RUN pip install --no-cache-dir \
    ansible==${ANSIBLE_VERSION} \
    ansible-lint \
    ansible-core \
    molecule \
    molecule-plugins[docker] \
    jinja2 \
    jmespath \
    netaddr \
    dnspython

# Install Ansible Collections
RUN ansible-galaxy collection install \
    community.general \
    community.docker \
    community.grafana \
    community.postgresql \
    community.proxmox \
    community.crypto \
    community.mongodb \
    cisco.ios

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    kubectl version --client

# Install Helm
RUN curl -fsSL https://get.helm.io/helm-v${HELM_VERSION}-linux-amd64.tar.gz -o helm.tar.gz && \
    tar -zxvf helm.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    rm -rf linux-amd64 helm.tar.gz && \
    helm version

# Install K9s (Kubernetes CLI UI)
RUN wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz && \
    tar -xzf k9s_Linux_amd64.tar.gz && \
    mv k9s /usr/local/bin/ && \
    rm k9s_Linux_amd64.tar.gz

# Install kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    mv kustomize /usr/local/bin/

# Install ArgoCD CLI
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

# Install Flux CLI
RUN curl -s https://fluxcd.io/install.sh | bash

# Install Python tools and libraries
RUN pip install --no-cache-dir \
    # Testing
    pytest \
    pytest-cov \
    pytest-mock \
    pytest-asyncio \
    # Linting & Formatting
    black \
    isort \
    pylint \
    mypy \
    flake8 \
    # Type stubs
    types-requests \
    types-PyYAML \
    # Utilities
    pyyaml \
    requests \
    python-dotenv \
    rich \
    typer \
    # Cloud SDKs
    boto3 \
    # Proxmox
    proxmoxer \
    # Network
    paramiko \
    netmiko \
    # Documentation
    mkdocs \
    mkdocs-material \
    mkdocs-mermaid2-plugin

# Install Docker Compose
RUN curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose --version

# Install hadolint (Dockerfile linter)
RUN wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64 && \
    chmod +x /usr/local/bin/hadolint

# Install shellcheck
RUN wget -qO- "https://github.com/koalaman/shellcheck/releases/latest/download/shellcheck-stable.linux.x86_64.tar.xz" | tar -xJv && \
    cp "shellcheck-stable/shellcheck" /usr/local/bin/ && \
    rm -rf "shellcheck-stable"

# Install yamllint
RUN pip install --no-cache-dir yamllint

# Install pre-commit
RUN pip install --no-cache-dir pre-commit

# Install Bitwarden CLI
RUN wget https://vault.bitwarden.com/download/?app=cli&platform=linux -O bw.zip && \
    unzip bw.zip && \
    chmod +x bw && \
    mv bw /usr/local/bin/ && \
    rm bw.zip

# Install MinIO Client (mc)
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc && \
    chmod +x mc && \
    mv mc /usr/local/bin/

# Install Restic (backup tool)
RUN wget https://github.com/restic/restic/releases/latest/download/restic_0.16.4_linux_amd64.bz2 && \
    bunzip2 restic_0.16.4_linux_amd64.bz2 && \
    chmod +x restic_0.16.4_linux_amd64 && \
    mv restic_0.16.4_linux_amd64 /usr/local/bin/restic

# Install Tailscale CLI
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Install Node.js and npm (for MCP workspace)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g \
    typescript \
    ts-node \
    @modelcontextprotocol/sdk \
    prettier \
    eslint

# Install actionlint (GitHub Actions linter)
RUN wget https://github.com/rhysd/actionlint/releases/latest/download/actionlint_linux_amd64.tar.gz && \
    tar -xzf actionlint_linux_amd64.tar.gz && \
    mv actionlint /usr/local/bin/ && \
    rm actionlint_linux_amd64.tar.gz

# Install gitleaks (secret scanner)
RUN wget https://github.com/gitleaks/gitleaks/releases/latest/download/gitleaks_8.18.2_linux_x64.tar.gz && \
    tar -xzf gitleaks_8.18.2_linux_x64.tar.gz && \
    mv gitleaks /usr/local/bin/ && \
    rm gitleaks_8.18.2_linux_x64.tar.gz

# Install Prometheus client tools
RUN pip install --no-cache-dir prometheus-client

# Install Grafana monitoring Python client
RUN pip install --no-cache-dir grafana-client

# Install MQTT client
RUN pip install --no-cache-dir paho-mqtt

# Install Redis client
RUN pip install --no-cache-dir redis

# Install PostgreSQL client
RUN apt-get update && apt-get install -y postgresql-client && \
    pip install --no-cache-dir psycopg2-binary && \
    rm -rf /var/lib/apt/lists/*

# Create workspace directories
RUN mkdir -p /workspace/.kube \
    /workspace/.ssh \
    /workspace/.ansible \
    /workspace/.terraform.d

# Set up bash completion for tools
RUN kubectl completion bash > /etc/bash_completion.d/kubectl && \
    helm completion bash > /etc/bash_completion.d/helm && \
    terraform -install-autocomplete || true

# Configure git (can be overridden by user)
RUN git config --global init.defaultBranch main && \
    git config --global core.editor vim

# Create useful aliases
RUN echo 'alias k=kubectl' >> /root/.bashrc && \
    echo 'alias tf=terraform' >> /root/.bashrc && \
    echo 'alias ap=ansible-playbook' >> /root/.bashrc && \
    echo 'alias dc=docker-compose' >> /root/.bashrc && \
    echo 'alias ll="ls -lah"' >> /root/.bashrc && \
    echo 'source <(kubectl completion bash)' >> /root/.bashrc && \
    echo 'complete -F __start_kubectl k' >> /root/.bashrc

# Set working directory
WORKDIR /workspace

# Switch back to dialog for any ad-hoc use
ENV DEBIAN_FRONTEND=dialog

# Default command
CMD ["/bin/bash"]
