# Windows + WSL Dual Setup Guide

Complete guide for running VS Code with both Windows PowerShell (read-only) and WSL (full admin
access) for AI agents.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│ Windows Host                                                 │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ VS Code (Windows)                                   │    │
│  │ - PowerShell Terminal (Read-Only for viewing)      │    │
│  │ - Limited permissions for safety                   │    │
│  └────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          │ Shared Workspace                  │
│                          │ (same Git repo)                   │
│                          ▼                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ C:\Users\<user>\homelab\                            │    │
│  │ ├── .git/                                           │    │
│  │ ├── .vscode/                                        │    │
│  │ └── ... (all code files)                            │    │
│  └────────────────────────────────────────────────────┘    │
│                          │                                   │
│                          │ Mounted in WSL                    │
│                          ▼                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ WSL 2 (Ubuntu/Debian)                               │    │
│  │                                                      │    │
│  │  /mnt/c/Users/<user>/homelab/ (same files)         │    │
│  │  or                                                  │    │
│  │  ~/homelab/ (bind mounted from Windows)             │    │
│  │                                                      │    │
│  │  ┌──────────────────────────────────────────┐      │    │
│  │  │ VS Code Server (Remote-WSL)               │      │    │
│  │  │ - Bash Terminal (FULL ADMIN ACCESS)       │      │    │
│  │  │ - All CLI tools for AI agents             │      │    │
│  │  │ - Docker, kubectl, terraform, ansible     │      │    │
│  │  │ - AI agents have unrestricted access      │      │    │
│  │  └──────────────────────────────────────────┘      │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Benefits of This Setup

1. **Shared Workspace**: Single git repository accessible from both environments
2. **Windows Safety**: PowerShell with read-only for viewing, no accidental damage
3. **WSL Power**: Full admin access for AI agents to execute any command
4. **Performance**: Native Linux tools in WSL for infrastructure work
5. **Flexibility**: Use Windows for browsing/viewing, WSL for actual work

## Prerequisites

- Windows 10/11 with WSL 2 installed
- VS Code installed on Windows
- Git installed on both Windows and WSL
- Docker Desktop (optional, can use Docker in WSL)

## Setup Instructions

### Step 1: Install WSL 2

```powershell
# Run in PowerShell as Administrator
wsl --install -d Ubuntu-22.04

# Or if WSL is already installed
wsl --set-default-version 2
wsl --install -d Ubuntu-22.04

# Verify WSL 2
wsl --list --verbose
```

### Step 2: Choose Workspace Location

**Option A: Windows-based workspace (Recommended)**

```powershell
# Create workspace on Windows
mkdir C:\Users\<YourUsername>\homelab
cd C:\Users\<YourUsername>\homelab

# Clone the repository
git clone https://github.com/jwrv/VS-code-home-lab.git .
```

**Option B: WSL-based workspace**

```bash
# In WSL
mkdir ~/homelab
cd ~/homelab
git clone https://github.com/jwrv/VS-code-home-lab.git .
```

### Step 3: Configure Git for Both Environments

**Windows Git Config:**

```powershell
# Configure Git on Windows (if using Windows workspace)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.autocrlf true  # Important for Windows
```

**WSL Git Config:**

```bash
# In WSL terminal
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.autocrlf input  # Important for WSL
```

### Step 4: Install VS Code Extensions

**Windows VS Code:**

```powershell
# Install WSL extension
code --install-extension ms-vscode-remote.remote-wsl

# Install all homelab extensions
Get-Content .vscode\extensions.json | Select-String -Pattern '"([^"]+)"' -AllMatches |
  ForEach-Object { $_.Matches.Groups[1].Value } | Where-Object { $_ -notmatch '^//' } |
  ForEach-Object { code --install-extension $_ }
```

### Step 5: Configure Shared Workspace

**Create workspace file for dual access:**

File: `homelab.code-workspace`

```json
{
  "folders": [
    {
      "name": "Homelab (Windows - Read)",
      "path": "."
    },
    {
      "name": "Homelab (WSL - Full Access)",
      "path": "\\\\wsl$\\Ubuntu-22.04\\mnt\\c\\Users\\<YourUsername>\\homelab"
    }
  ],
  "settings": {
    // Windows-specific settings (read-only hints)
    "terminal.integrated.profiles.windows": {
      "PowerShell": {
        "source": "PowerShell",
        "icon": "terminal-powershell",
        "color": "terminal.ansiBlue"
      }
    },
    "terminal.integrated.defaultProfile.windows": "PowerShell",

    // WSL-specific settings (full access)
    "terminal.integrated.profiles.linux": {
      "bash": {
        "path": "/bin/bash",
        "icon": "terminal-linux"
      }
    },
    "terminal.integrated.defaultProfile.linux": "bash",

    // Remote WSL settings
    "remote.WSL.fileWatcher.polling": true,
    "files.watcherExclude": {
      "**/node_modules/**": true,
      "**/.terraform/**": true
    }
  },
  "extensions": {
    "recommendations": [
      "ms-vscode-remote.remote-wsl"
    ]
  }
}
```

## Usage Patterns

### Pattern 1: View on Windows, Execute in WSL

1. **Open workspace in Windows** to browse/view code
2. **Open same workspace in WSL** for AI agents to execute commands

```powershell
# Windows: Open for viewing
code C:\Users\<YourUsername>\homelab

# Then in VS Code: F1 → "Remote-WSL: Reopen Folder in WSL"
```

### Pattern 2: WSL-Only with Windows Fallback

1. **Primary work in WSL** with full access
2. **Occasional Windows viewing** if needed

```bash
# Open in WSL directly
code --remote wsl+Ubuntu-22.04 /mnt/c/Users/<YourUsername>/homelab
```

### Pattern 3: Two VS Code Windows

1. **Windows VS Code**: Read-only viewing, documentation
2. **WSL VS Code**: AI agents, CLI tools, execution

```powershell
# Terminal 1 (Windows)
code C:\Users\<YourUsername>\homelab

# Terminal 2 (PowerShell)
code --remote wsl+Ubuntu-22.04 C:\Users\<YourUsername>\homelab
```

## PowerShell Configuration (Read-Only Mode)

**Windows PowerShell Profile:**

File: `$PROFILE` (usually `C:\Users\<User>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)

```powershell
# Homelab PowerShell Profile - READ-ONLY MODE
# This limits destructive operations to prevent accidents

# Set read-only aliases
Set-Alias -Name rm -Value Remove-ItemSafely -Option AllScope -Force
Set-Alias -Name del -Value Remove-ItemSafely -Option AllScope -Force

function Remove-ItemSafely {
    Write-Host "⚠️  Destructive operations disabled in PowerShell." -ForegroundColor Yellow
    Write-Host "   Use WSL terminal for file operations." -ForegroundColor Cyan
    return
}

# Override dangerous commands
function Remove-Item {
    Write-Host "⚠️  Remove-Item disabled. Use WSL for file operations." -ForegroundColor Yellow
}

# Helpful viewing commands
function Show-HomelabStatus {
    Write-Host "=== Homelab Status (Read-Only View) ===" -ForegroundColor Green
    Write-Host "Workspace: $PWD"
    Write-Host "Git Branch: $(git branch --show-current 2>$null)"
    Write-Host "Git Status: $(git status --short 2>$null | Measure-Object -Line | Select-Object -ExpandProperty Lines) changes"
    Write-Host ""
    Write-Host "💡 For full access, switch to WSL terminal" -ForegroundColor Cyan
}

# Informational message
Write-Host "🛡️  PowerShell Read-Only Mode Active" -ForegroundColor Yellow
Write-Host "   Switch to WSL terminal for AI agent operations" -ForegroundColor Cyan
```

## WSL Configuration (Full Admin Access)

**WSL Bash Profile:**

File: `~/.bashrc` (append to end)

```bash
# Homelab WSL Profile - FULL ADMIN ACCESS
# All tools available for AI agents

# Homelab aliases
alias h='cd ~/homelab || cd /mnt/c/Users/$(whoami)/homelab'
alias k='kubectl'
alias tf='terraform'
alias ap='ansible-playbook'

# AI Agent permissions confirmation
export HOMELAB_ADMIN_MODE=true

# Colored prompt for WSL
export PS1='\[\e[32m\][WSL-ADMIN]\[\e[0m\] \[\e[34m\]\w\[\e[0m\]\$ '

# Verify all CLI tools are available
echo "🚀 WSL Admin Mode - Full CLI access for AI agents"
echo "   Location: $PWD"
which kubectl terraform ansible docker 2>/dev/null | sed 's/^/   ✓ /'
```

## CLI Tools for AI Agents (WSL)

All tools should be installed in WSL for AI agent access:

```bash
# Update WSL
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y \
  git curl wget unzip zip \
  build-essential python3 python3-pip \
  jq yq htop tree \
  net-tools dnsutils

# Install Docker (if not using Docker Desktop)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Terraform
wget https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip terraform_1.7.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Install Ansible
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install k9s
wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/

# Verify all tools
echo "Installed CLI tools:"
for tool in git docker kubectl terraform ansible helm k9s python3 node npm; do
  if command -v $tool &> /dev/null; then
    echo "✓ $tool: $(command -v $tool)"
  else
    echo "✗ $tool: NOT FOUND"
  fi
done
```

## AI Agent MCP Integration

### Configure AI Agents to Use WSL Tools

**Continue.dev Configuration for WSL:**

Update `.continuerc.json`:

```json
{
  "terminalSettings": {
    "shellIntegration": true,
    "defaultShell": {
      "windows": "wsl",
      "linux": "bash"
    }
  },
  "experimental": {
    "modelContextProtocolServers": [
      {
        "name": "homelab-tools",
        "transport": {
          "type": "stdio",
          "command": "wsl",
          "args": ["-e", "bash", "-c", "node /mnt/c/Users/<User>/homelab/mcp-server.js"]
        }
      }
    ]
  },
  "contextProviders": [
    {
      "name": "terminal",
      "params": {
        "shell": "wsl"
      }
    }
  ]
}
```

### MCP Server for Homelab Tools

Create: `mcp-server.js` (runs in WSL, exposes all CLI tools to AI)

```javascript
#!/usr/bin/env node

// MCP Server for Homelab CLI Tools
// Allows AI agents to execute commands in WSL with full access

const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

// Allowed commands for AI agents
const ALLOWED_COMMANDS = [
  'kubectl', 'k9s', 'helm',
  'terraform', 'ansible', 'ansible-playbook',
  'docker', 'docker-compose',
  'git', 'gh',
  'python3', 'pip3', 'node', 'npm',
  'curl', 'wget', 'jq', 'yq',
  'ls', 'cat', 'grep', 'find', 'tree'
];

// MCP tool definitions
const tools = ALLOWED_COMMANDS.map(cmd => ({
  name: `execute_${cmd}`,
  description: `Execute ${cmd} command in WSL with full admin access`,
  inputSchema: {
    type: "object",
    properties: {
      args: {
        type: "array",
        items: { type: "string" },
        description: `Arguments for ${cmd} command`
      }
    },
    required: ["args"]
  }
}));

// Tool execution handler
async function executeTool(toolName, args) {
  const cmd = toolName.replace('execute_', '');

  if (!ALLOWED_COMMANDS.includes(cmd)) {
    throw new Error(`Command not allowed: ${cmd}`);
  }

  const fullCommand = `${cmd} ${args.args.join(' ')}`;
  console.error(`Executing in WSL: ${fullCommand}`);

  try {
    const { stdout, stderr } = await execAsync(fullCommand);
    return {
      content: [
        {
          type: "text",
          text: stdout + (stderr ? `\nStderr: ${stderr}` : '')
        }
      ]
    };
  } catch (error) {
    return {
      content: [
        {
          type: "text",
          text: `Error executing ${cmd}: ${error.message}`
        }
      ],
      isError: true
    };
  }
}

// MCP Protocol implementation
async function handleMCPRequest(request) {
  switch (request.method) {
    case 'tools/list':
      return { tools };

    case 'tools/call':
      return await executeTool(request.params.name, request.params.arguments);

    default:
      throw new Error(`Unknown method: ${request.method}`);
  }
}

// Start MCP server
process.stdin.setEncoding('utf8');
let buffer = '';

process.stdin.on('data', async (chunk) => {
  buffer += chunk;
  const lines = buffer.split('\n');

  buffer = lines.pop();

  for (const line of lines) {
    if (line.trim()) {
      try {
        const request = JSON.parse(line);
        const response = await handleMCPRequest(request);
        console.log(JSON.stringify(response));
      } catch (error) {
        console.log(JSON.stringify({
          error: { code: -32603, message: error.message }
        }));
      }
    }
  }
});

console.error('Homelab MCP Server started - AI agents have full WSL access');
```

## VS Code Settings for Dual Environment

Update `.vscode/settings.json`:

```json
{
  // Terminal configuration for Windows/WSL
  "terminal.integrated.profiles.windows": {
    "PowerShell (Read-Only)": {
      "source": "PowerShell",
      "icon": "book",
      "color": "terminal.ansiBlue"
    },
    "WSL (Full Access)": {
      "path": "wsl.exe",
      "icon": "terminal-linux",
      "color": "terminal.ansiGreen"
    }
  },
  "terminal.integrated.defaultProfile.windows": "WSL (Full Access)",

  // AI assistants should use WSL terminal
  "continue.terminalSettings": {
    "defaultShell": "wsl"
  },

  // Remote WSL settings
  "remote.WSL.fileWatcher.polling": true,
  "remote.WSL.useShellEnvironment": true
}
```

## Git Configuration for Shared Workspace

### Handling Line Endings

```bash
# In WSL
git config --global core.autocrlf input

# In Windows PowerShell
git config --global core.autocrlf true
```

### Shared Git Config

File: `.gitconfig` (in repository root)

```ini
[core]
    # Let individual environments handle line endings
    autocrlf = false
    eol = lf

[diff]
    # Better diff for homelab files
    tool = vscode

[merge]
    tool = vscode

[pull]
    rebase = false
```

## Troubleshooting

### Issue: File permissions errors in WSL

```bash
# Fix in WSL /etc/wsl.conf
sudo tee /etc/wsl.conf > /dev/null <<EOF
[automount]
enabled = true
options = "metadata,umask=22,fmask=11"
EOF

# Restart WSL
wsl --shutdown
```

### Issue: Git shows all files as modified

```bash
# Ignore file mode changes
git config core.fileMode false
```

### Issue: PowerShell can still delete files

- Ensure PowerShell profile is loaded: `$PROFILE`
- Use Execution Policy: `Set-ExecutionPolicy RemoteSigned`
- Consider using Windows Sandbox for complete isolation

### Issue: AI agents can't access WSL tools

1. Verify MCP server is running
2. Check Continue.dev configuration
3. Ensure wsl.exe is in PATH
4. Test manually: `wsl -e kubectl version`

## Best Practices

1. **Always commit from WSL** - Better Git integration
2. **Use Windows for viewing/browsing** only
3. **Run AI agents in WSL** - Full tool access
4. **Keep workspace in Windows directory** - Better performance
5. **Regular backups** - Use WSL backup tools

## Summary

| Environment | Access Level | Use For | AI Agents |
|-------------|--------------|---------|-----------|
| **Windows PowerShell** | Read-Only | Viewing, browsing code | ❌ No |
| **WSL Bash** | Full Admin | All operations, AI work | ✅ Yes |

**Shared Workspace:** Same Git repository accessible from both, ensuring consistency.

**MCP Integration:** AI agents access all CLI tools through MCP server running in WSL.

This setup gives you safety (Windows read-only) and power (WSL full access) in one configuration!
