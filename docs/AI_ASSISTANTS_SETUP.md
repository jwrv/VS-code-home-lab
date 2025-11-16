# AI Assistants Setup Guide

Comprehensive guide for configuring all AI coding assistants in your VS Code Homelab environment.

## Available AI Assistants

This environment supports **5 AI coding assistants**:

1. **GitHub Copilot** - Code completion and chat
2. **Claude Code** - Advanced reasoning and complex tasks
3. **Google Gemini Code Assist** - Multi-modal AI assistance
4. **Continue.dev** - Customizable open-source AI with MCP support
5. **ChatGPT (via extensions)** - Optional OpenAI integration

## Quick Comparison

| Assistant | Best For | Cost | Setup Complexity |
|-----------|----------|------|------------------|
| **GitHub Copilot** | Code completion, quick suggestions | $10/month or free with Student/OSS | Easy |
| **Claude Code** | Complex reasoning, refactoring, architecture | Included with Claude Pro or API | Easy |
| **Gemini Code Assist** | Free tier, multi-modal, Google Cloud | Free tier available | Medium |
| **Continue.dev** | Custom workflows, MCP tools, any LLM | Varies (supports local models) | Medium |
| **ChatGPT Extensions** | Optional OpenAI integration | API costs | Easy |

## 1. GitHub Copilot Setup

### Installation

GitHub Copilot is already in the recommended extensions list and will install automatically when you open the dev container.

### Activation

1. Open VS Code
2. Sign in to GitHub (Cmd/Ctrl+Shift+P → "GitHub: Sign In")
3. Copilot will activate automatically if you have a subscription

### Configuration

All Copilot settings are pre-configured in `.vscode/settings.json`:

```json
{
  "github.copilot.enable": {
    "*": true,
    "yaml": true,
    "terraform": true,
    "python": true,
    "shellscript": true
  },
  "github.copilot.editor.enableAutoCompletions": true
}
```

### Homelab-Specific Features

Copilot is trained on public code and understands:
- Kubernetes manifests
- Terraform modules
- Ansible playbooks
- Common homelab patterns

See [.ai-assistants/github-copilot-config.md](../.ai-assistants/github-copilot-config.md) for detailed usage.

---

## 2. Claude Code Setup

### Installation

Claude Code extension is pre-installed.

### Activation

1. Click Claude Code icon in sidebar
2. Sign in with your Anthropic account
3. Claude Code requires:
   - Claude Pro subscription ($20/month), OR
   - API key with pay-as-you-go billing

### MCP Integration

Claude Code supports Model Context Protocol (MCP) for homelab integrations. See configuration in [.ai-assistants/claude-code-config.md](../.ai-assistants/claude-code-config.md).

### Homelab Context

Claude Code has been configured with homelab-specific context in the config file. It understands:
- Your K3s cluster architecture
- Proxmox VE setup
- Terraform/Ansible workflows
- Common homelab services

---

## 3. Google Gemini Code Assist Setup

### Installation

The official extension `google.geminicodeassist` is pre-installed.

### Activation

```bash
# Install gcloud CLI (already in dev container)
# Authenticate
gcloud auth login
gcloud auth application-default login

# Set your project
gcloud config set project YOUR_PROJECT_ID
```

### VS Code Configuration

Settings are pre-configured:

```json
{
  "gemini.enabled": true,
  "gemini.model": "gemini-2.5-pro"
}
```

### Free Tier

Gemini Code Assist offers a generous free tier:
- Free for individuals
- Powered by Gemini 2.5
- Includes code completion, chat, and agent mode

### Features

- **Next Edit Predictions** - Suggests upcoming code changes
- **Agent Mode** - Multi-step autonomous tasks
- **MCP Support** - Connect to external services
- **Chat History** - Resume conversations

See [.ai-assistants/gemini-config.md](../.ai-assistants/gemini-config.md) for detailed setup.

---

## 4. Continue.dev Setup

### Why Continue.dev?

Continue.dev is the most flexible option:
- **Open source** - Full control and transparency
- **Any LLM** - Use OpenAI, Anthropic, local models (Ollama), etc.
- **MCP Integration** - Native support for Model Context Protocol
- **Custom Workflows** - Create homelab-specific commands
- **Cost Control** - Use local models or API, your choice

### Installation

Continue.dev extension is pre-installed.

### Configuration

Configuration file: `.continuerc.json`

Pre-configured with:
- Claude 3.5 Sonnet (primary)
- GPT-4 Turbo (alternative)
- Gemini Pro (alternative)
- Custom homelab slash commands

### Custom Slash Commands

Pre-configured commands for homelab:

```
/homelab-deploy  - Generate K8s manifests for homelab service
/terraform-module - Create Terraform module for Proxmox
/ansible-role    - Generate Ansible role
```

### API Keys Setup

Create `.env` file (already in `.gitignore`):

```bash
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...
```

Continue.dev will read these automatically.

### Local Models (Optional)

Use Ollama for free, local inference:

```bash
# Install Ollama (already in dev container)
# Pull a model
ollama pull codellama

# Update .continuerc.json:
{
  "models": [
    {
      "title": "Code Llama",
      "provider": "ollama",
      "model": "codellama"
    }
  ]
}
```

### MCP Tools

Continue.dev supports MCP servers for your homelab services. Configure in `.continuerc.json`:

```json
{
  "experimental": {
    "modelContextProtocolServers": [
      {
        "transport": {
          "type": "stdio",
          "command": "node",
          "args": ["/workspace/Homelab/tools/devtools/mcp-workspace/build/index.js"]
        }
      }
    ]
  }
}
```

---

## 5. ChatGPT Integration (Optional)

### Extensions

Several ChatGPT extensions available:

1. **ChatGPT - Genie AI** (`genieai.chatgpt-vscode`)
2. **Code GPT** (`DanielSanMedium.dscodegpt`)
3. **Rubberduck** (`Rubberduck.rubberduck-vscode`)

### Installation

```bash
# Install your preferred extension
code --install-extension genieai.chatgpt-vscode
```

### API Key

```json
{
  "chatgpt.apiKey": "${env:OPENAI_API_KEY}",
  "chatgpt.model": "gpt-4-turbo-preview"
}
```

See [.ai-assistants/chatgpt-codex-config.md](../.ai-assistants/chatgpt-codex-config.md) for details.

---

## Multi-Assistant Workflow

### When to Use Each Assistant

**GitHub Copilot:**
- Quick code completion while typing
- Generating boilerplate
- Common patterns

**Claude Code:**
- Complex refactoring
- Architecture decisions
- Understanding large codebases
- Security analysis

**Gemini Code Assist:**
- Multi-modal tasks (images, diagrams)
- Free alternative to Copilot
- Google Cloud integration

**Continue.dev:**
- Custom homelab workflows
- Local model inference
- Cost-sensitive projects
- MCP tool integration

**ChatGPT:**
- Specific OpenAI features
- Alternative to other assistants

### Example Workflow

1. **Design Phase** - Ask Claude Code or Gemini about architecture
2. **Implementation** - Use Copilot for code completion
3. **Debugging** - Use Continue.dev with MCP tools to query homelab
4. **Review** - Ask Claude Code to review changes
5. **Documentation** - Use any assistant to generate docs

## Keyboard Shortcuts

Pre-configured shortcuts:

- **Copilot Suggestions**: `Tab` (accept), `Alt+]` (next), `Alt+[` (previous)
- **Copilot Chat**: `Ctrl+Shift+I`
- **Claude Code**: `Ctrl+Shift+L` (chat)
- **Continue.dev**: `Ctrl+L` (chat)

## Cost Management

### Free Options

1. **Continue.dev + Ollama** - 100% free, local models
2. **Gemini Code Assist Free Tier** - Generous free quota
3. **GitHub Copilot** - Free for students and OSS maintainers

### Paid Subscriptions

1. **GitHub Copilot** - $10/month (best value for code completion)
2. **Claude Pro** - $20/month (includes Claude Code)
3. **ChatGPT Plus** - $20/month (if using ChatGPT extension)

### API Pay-As-You-Go

Use Continue.dev with API keys:

- **Claude 3.5 Sonnet**: ~$3 per million input tokens
- **GPT-4 Turbo**: ~$10 per million input tokens
- **Gemini Pro**: Free tier, then ~$0.50 per million tokens

### Recommendation

**Best Value Setup:**
- **GitHub Copilot** ($10/month) - For daily code completion
- **Continue.dev + Claude API** (pay-as-you-go) - For complex tasks
- **Gemini Free Tier** - Backup/alternative

## Troubleshooting

### Copilot not activating

```bash
# Check auth status
gh auth status

# Re-login
gh auth login

# Restart VS Code
```

### Claude Code connection issues

1. Check internet connection
2. Verify Claude Pro subscription or API key
3. Restart VS Code
4. Check Claude status: https://status.anthropic.com

### Gemini authentication fails

```bash
# Re-authenticate
gcloud auth application-default login

# Verify project
gcloud config list
```

### Continue.dev not finding API keys

1. Verify `.env` file exists in workspace root
2. Check environment variables are set
3. Restart VS Code to reload environment
4. Check `.continuerc.json` uses `${ANTHROPIC_API_KEY}` syntax

### Multiple assistants conflicting

Each assistant has its own trigger:
- Copilot: Inline suggestions (Tab)
- Claude Code: Sidebar panel
- Gemini: Separate panel
- Continue.dev: Separate chat panel

They should not conflict. If they do:

1. Disable inline suggestions for one:
   ```json
   {
     "github.copilot.editor.enableAutoCompletions": false
   }
   ```
2. Use keyboard shortcuts to activate specific assistant

## Privacy & Security

### Data Sharing

- **GitHub Copilot**: Code sent to GitHub (see terms)
- **Claude Code**: Code sent to Anthropic (see terms)
- **Gemini**: Code sent to Google (see terms)
- **Continue.dev**: You control where data goes
  - Local models: Nothing leaves your machine
  - API: Only data sent to chosen provider

### Best Practices

1. **Never share secrets** - Use placeholders in prompts
2. **Review suggestions** - Don't blindly accept AI code
3. **Use local models** - For sensitive codebases
4. **Disable for sensitive files** - Use `.gitignore` patterns

### Disable AI for Specific Files

```json
{
  "files.exclude": {
    "**/secrets/**": true
  },
  "github.copilot.advanced": {
    "excludedFiles": ["**/secrets/**", "**/*.secret"]
  }
}
```

## Resources

- [GitHub Copilot Docs](https://docs.github.com/copilot)
- [Claude Code Docs](https://claude.ai/code)
- [Gemini Code Assist Docs](https://cloud.google.com/gemini/docs/codeassist)
- [Continue.dev Docs](https://docs.continue.dev)
- [Homelab AI Configs](../.ai-assistants/)

## Next Steps

1. Choose your primary assistant(s)
2. Configure API keys in `.env`
3. Test each assistant with a simple task
4. Create custom Continue.dev slash commands for your homelab
5. Review the individual config files in `.ai-assistants/`
