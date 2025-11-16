# Homelab MCP Server

Model Context Protocol (MCP) server that provides AI agents with full access to all homelab CLI
tools running in WSL.

## What is MCP?

Model Context Protocol is a standard that allows AI assistants to interact with external tools and
services. This MCP server exposes all your homelab infrastructure tools (kubectl, terraform,
ansible, docker, etc.) to AI agents like Claude Code, Continue.dev, and others.

## Features

- **Full CLI Access**: All homelab tools available to AI agents
- **WSL Integration**: Runs commands in WSL with full admin privileges
- **Safe Execution**: Command validation and error handling
- **Tool Discovery**: AI agents can list and learn about available tools
- **Context Aware**: Supports working directory and environment variables

## Available Tools

The MCP server exposes 30+ CLI tools across these categories:

### Kubernetes
- `kubectl` - Kubernetes CLI
- `helm` - Package manager
- `k9s` - Interactive TUI

### Infrastructure as Code
- `terraform` - Infrastructure provisioning
- `ansible` / `ansible-playbook` - Configuration management

### Containers
- `docker` - Container runtime
- `docker-compose` - Multi-container apps

### Version Control
- `git` - Version control
- `gh` - GitHub CLI

### System Utilities
- `ls`, `cat`, `grep`, `find`, `tree`
- `curl`, `wget`
- `jq`, `yq` - JSON/YAML processors

### And more...
- Python, Node.js, npm
- File operations (cp, mv, mkdir)
- System monitoring (htop, systemctl)

## Setup

### 1. Prerequisites

- Node.js 18+ installed in WSL
- All homelab CLI tools installed in WSL
- Continue.dev or Claude Code AI assistant

### 2. Verify Installation

```bash
# In WSL
cd /path/to/VS-code-home-lab/mcp-server
node homelab-mcp-server.js
```

You should see:
```
[MCP] Homelab MCP Server starting...
[MCP] Available tools: 30+
[MCP] AI agents have full WSL CLI access
```

Press Ctrl+C to stop.

### 3. Configure AI Assistant

The MCP server is already configured in `.continuerc.json`:

```json
{
  "experimental": {
    "modelContextProtocolServers": [
      {
        "name": "homelab-tools",
        "command": "wsl",
        "args": ["-e", "node", "${workspaceFolder}/mcp-server/homelab-mcp-server.js"]
      }
    ]
  }
}
```

### 4. Test with AI

Ask your AI assistant:

```
Can you list all pods in the cluster?
```

The AI will use the MCP server to execute:
```bash
kubectl get pods --all-namespaces
```

## Usage Examples

### Example 1: Kubernetes Operations

**Prompt**: "Show me all deployments in the default namespace"

AI executes via MCP:
```bash
kubectl get deployments -n default
```

### Example 2: Terraform Planning

**Prompt**: "Run a terraform plan in the infrastructure directory"

AI executes via MCP:
```bash
cd infra/terraform && terraform plan
```

### Example 3: Ansible Deployment

**Prompt**: "Deploy the K3s cluster using Ansible"

AI executes via MCP:
```bash
ansible-playbook infra/ansible/playbooks/deploy-k3s.yml
```

### Example 4: Docker Management

**Prompt**: "Show me all running containers"

AI executes via MCP:
```bash
docker ps
```

### Example 5: File Operations

**Prompt**: "Find all YAML files in the kubernetes directory"

AI executes via MCP:
```bash
find kubernetes -name '*.yaml'
```

## How It Works

1. **AI Request**: AI assistant wants to execute a command
2. **MCP Protocol**: Request sent to MCP server via stdin/stdout
3. **Command Execution**: MCP server runs command in WSL
4. **Response**: Output returned to AI assistant
5. **AI Response**: AI interprets results and responds to user

## Architecture

```
┌─────────────────────┐
│   AI Assistant      │
│  (Claude, etc.)     │
└──────────┬──────────┘
           │ MCP Protocol
           │ (JSON-RPC)
           ▼
┌─────────────────────┐
│  MCP Server         │
│  (Node.js)          │
└──────────┬──────────┘
           │ spawn()
           ▼
┌─────────────────────┐
│  WSL Environment    │
│  (Full Admin)       │
│                     │
│  - kubectl          │
│  - terraform        │
│  - ansible          │
│  - docker           │
│  - ...30+ tools     │
└─────────────────────┘
```

## Security

### Allowed Commands

Only pre-approved commands in `HOMELAB_TOOLS` can be executed:
- Kubernetes: kubectl, helm, k9s
- IaC: terraform, ansible
- Containers: docker, docker-compose
- Version control: git, gh
- System utilities: ls, cat, grep, find, etc.

### No Shell Injection

Commands are executed with `spawn()` (not `exec()`), preventing shell injection attacks.

### Working Directory Control

AI can specify working directory, but command execution is sandboxed to project directories.

## Troubleshooting

### MCP Server Not Starting

```bash
# Check Node.js version
node --version  # Should be 18+

# Test manually
node mcp-server/homelab-mcp-server.js

# Check for errors
```

### Commands Not Executing

```bash
# Verify tool is installed
which kubectl terraform ansible docker

# Check permissions
ls -la /usr/local/bin/kubectl
```

### AI Can't Access MCP Server

1. Check Continue.dev configuration in `.continuerc.json`
2. Verify WSL is accessible: `wsl --version`
3. Test MCP manually: `echo '{"method":"tools/list","id":1}' | node mcp-server/homelab-mcp-server.js`

### Permission Denied Errors

```bash
# Ensure commands are executable
chmod +x /usr/local/bin/*

# Check user permissions
whoami
groups
```

## Development

### Adding New Tools

Edit `homelab-mcp-server.js` and add to `HOMELAB_TOOLS`:

```javascript
const HOMELAB_TOOLS = {
  // ... existing tools
  "my-new-tool": {
    description: "Description of tool",
    examples: ["my-new-tool --help"]
  }
};
```

### Testing

Create a test request:

```bash
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | \
  node mcp-server/homelab-mcp-server.js
```

Expected output:
```json
{"jsonrpc":"2.0","id":1,"result":{"tools":[...]}}
```

### Debugging

Enable debug output:

```javascript
// In homelab-mcp-server.js
console.error('[DEBUG] Request:', JSON.stringify(request));
console.error('[DEBUG] Response:', JSON.stringify(response));
```

## Best Practices

1. **Test commands manually first** before letting AI execute them
2. **Review AI-generated commands** before confirmation
3. **Use working directories** to scope command execution
4. **Monitor MCP server logs** for unexpected behavior
5. **Keep tool list updated** as you add new CLI tools

## Integration with AI Assistants

### Continue.dev

Already configured. Just ask:
```
"Deploy the homelab using terraform"
```

### Claude Code

Claude Code can use MCP tools directly. Configure in Claude desktop app settings.

### GitHub Copilot

Copilot doesn't support MCP yet, but Continue.dev can act as a bridge.

## Limitations

- Commands run synchronously (one at a time)
- No interactive commands (like vim, nano)
- Output limited to stdout/stderr
- No file uploads (use file paths instead)

## Future Enhancements

- [ ] Async command execution
- [ ] Command history and caching
- [ ] File upload/download support
- [ ] Interactive command handling
- [ ] Resource limits and timeouts
- [ ] Audit logging of all commands

## Resources

- [MCP Specification](https://modelcontextprotocol.io/)
- [Continue.dev MCP Docs](https://docs.continue.dev/features/model-context-protocol)
- [Anthropic Claude MCP](https://www.anthropic.com/news/model-context-protocol)

## License

MIT License - See LICENSE file for details
