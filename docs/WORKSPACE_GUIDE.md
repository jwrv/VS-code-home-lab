# Homelab Workspace Guide for Beginners

This guide explains how to use the optimized VS Code workspace file for your homelab. Think of the
workspace as a "project file" that sets up VS Code perfectly for homelab work!

## What is a Workspace?

A **workspace** is like a saved configuration for VS Code that:

- Opens multiple folders at once (organized by purpose)
- Applies specific settings automatically
- Loads the right extensions
- Creates custom shortcuts and commands
- Optimizes everything for AI assistants
- **Organizes all the windows, panels, and layout perfectly**

**Think of it as**: A pre-configured VS Code setup that knows you're working on a homelab and
arranges everything exactly where you need it!

## Quick Start

### IMPORTANT: Before Opening the Workspace

**First-time setup** (skip if you've already done this):

1. **Create `.env` file**:

   ```bash
   cd VS-code-home-lab
   cp .env.example .env
   nano .env  # Edit with your values
   ```

2. **Verify Homelab location**:
   The workspace expects your Homelab repository at `../Homelab` (sibling directory).
   If yours is elsewhere, either:
   - Update `HOMELAB_PATH` in `.env`, OR
   - Create a symlink: `ln -s /path/to/Homelab ../Homelab`, OR
   - Edit folder paths in `homelab.code-workspace`

3. **Install pre-commit hooks** (optional):

   ```bash
   pip install pre-commit
   pre-commit install
   ```

See the [main README](../README.md) for full first-time setup.

### Opening the Workspace

**Method 1: Double-click (Easiest)**

1. Navigate to your VS-code-home-lab folder
2. Find the file `homelab.code-workspace`
3. Double-click it
4. VS Code opens with everything configured!

**Method 2: From VS Code**

1. Open VS Code
2. Click "File" → "Open Workspace from File..."
3. Navigate to `homelab.code-workspace`
4. Click "Open"

**Method 3: From Command Line**

```bash
# Windows PowerShell
code homelab.code-workspace

# WSL
code homelab.code-workspace
```

## What You Get

### Organized Folder Structure

When you open the workspace, you'll see folders in the sidebar:

```
🏠 Homelab Root        ← Main configuration files
☸️ Kubernetes         ← All Kubernetes manifests
🔧 Terraform          ← Infrastructure as Code
⚙️ Ansible            ← Configuration management
📜 Scripts            ← Helper scripts
📚 Documentation      ← Guides and docs
```

**Why this is great**:
- Easy to find what you need
- Jump between different parts of homelab quickly
- AI assistants can see all relevant code

### AI Assistant Optimization

The workspace is configured to make AI assistants work PERFECTLY:

**What's Enabled**:
✅ GitHub Copilot - Auto-complete as you type
✅ Continue.dev - Full AI chat and commands
✅ Claude Code - Advanced AI assistance
✅ Gemini Code Assist - Google's AI helper
✅ All configured to work together!

**What This Means**:
- AI suggestions appear automatically while typing
- Right-click and ask AI to explain code
- AI can see your whole homelab project
- MCP server gives AI access to run commands

### Smart Terminal Setup

The workspace sets up terminals perfectly:

**On Windows**:
- Default: WSL (Ubuntu) - Best for homelab tools!
- Alternative: PowerShell - When you need Windows
- Both have full admin access

**Terminal opens in the right place**:
- Already in your homelab folder
- Tools like kubectl, terraform ready to use
- AI assistants prefer this terminal

### Code Quality Tools

Everything stays clean automatically:

**On Save**:
- Code automatically formatted (Prettier)
- Imports organized (Python, JavaScript)
- Problems highlighted in real-time

**Before Commit**:
- Pre-commit hooks run linting
- Catches errors before they're committed
- AI can help fix any issues found

### File Organization

**Hidden files** (clutter removed):
- `.git`, `.terraform`, `node_modules`, etc.
- You can still access them if needed
- Just keeps the view clean

**Smart file associations**:
- `.yaml` files use YAML tools
- `.tf` files use Terraform tools
- Everything opens with the right editor

### VS Code Window Layout (Optimized!)

The workspace automatically organizes all VS Code windows and panels for homelab work:

**LEFT SIDE - Activity Bar & Sidebar**:

- **Activity Bar**: Icons for Explorer, Search, Git, Extensions, etc.
- **Primary Sidebar**: File Explorer showing all 6 homelab folders
- **Indent guides**: Makes folder structure crystal clear
- **Icon theme**: Beautiful icons for file types (vscode-icons)

**CENTER - Editor Area**:

- **Multiple tabs**: All open files shown at top
- **Split editors**: Can view files side-by-side (vertical split)
- **Minimap**: Code overview on right side of editor
- **Line numbers**: Easy code navigation
- **Rulers at 100/120 chars**: Keeps code properly formatted

**BOTTOM - Integrated Panels**:

- **Terminal**: WSL bash by default (AI-preferred!)
- **Problems**: Shows linting errors/warnings in real-time
- **Output**: Build/task output appears here
- **Debug Console**: When debugging Python/Node scripts
- **Tabs**: Switch between Terminal/Problems/Output easily

**BOTTOM RIGHT - Status Bar**:

- Current Git branch
- Line/column number
- File type (YAML, Terraform, etc.)
- AI assistant status (Copilot, Claude, etc.)
- Errors/warnings count

**What this means**:

- Everything you need is visible without hunting
- AI assistants can see the same layout you do
- Terminal is always accessible at bottom
- Problems show up immediately when linting runs
- Multi-folder view keeps all homelab code organized

## Using the Workspace

### Switching Between Folders

Click any folder name in the sidebar to see just those files:

1. Click `☸️ Kubernetes` → See all your K8s manifests
2. Click `🔧 Terraform` → See infrastructure code
3. Click `🏠 Homelab Root` → See main config files

**Pro Tip**: You can have files from different folders open at the same time!

### Running Quick Tasks

Press `Ctrl + Shift + B` (or Cmd + Shift + B on Mac) to see quick tasks:

**Available tasks**:

1. **🏥 Homelab Health Check**
   - Shows status of your Kubernetes cluster
   - Lists any pods that aren't running
   - Quick way to check if everything's OK

2. **✅ Validate All Code**
   - Runs linting on everything
   - Checks for errors
   - Makes sure code is clean

3. **🚀 Deploy (Ask AI for help!)**
   - Reminder to use AI assistants
   - AI can help with deployments

### Working with AI Assistants

**Getting Suggestions**:
1. Start typing code
2. Copilot suggests completions
3. Press `Tab` to accept
4. Keep typing or `Alt+]` for next suggestion

**Asking AI Questions**:
1. Select some code
2. Right-click → "Ask Claude" or "Chat with Continue"
3. Type your question
4. AI explains or helps fix it

**Example questions for AI**:
- "What does this Kubernetes manifest do?"
- "How can I improve this Terraform code?"
- "Deploy this service to the cluster"
- "Check if all pods are running"

### Terminal Usage

**Opening terminals**:
- View → Terminal (or Ctrl + `)
- Opens WSL terminal by default (AI-friendly!)

**Multiple terminals**:
- Click the `+` button for more terminals
- Click dropdown to choose PowerShell or WSL
- Each terminal remembers its directory

**AI can use your terminal**:
- When AI needs to run a command, it uses MCP
- AI executes in WSL automatically
- You see the output in real-time

## Workspace Settings Explained

### Editor Settings

**Line length**: 100 characters
- Keeps code readable
- Works well on any screen size
- Matches linting rules

**Rulers at 100 and 120**:
- Visual guides for line length
- Helps you see when lines are too long

**Auto-format on save**:
- Code cleaned up when you save
- No manual formatting needed
- Always consistent style

### AI Settings

**Inline suggestions enabled**:
- See AI suggestions as you type
- Don't have to ask - AI offers help

**Tab autocomplete**:
- Press Tab to accept suggestions
- Fast way to write code

**Context aware**:
- AI sees all open files
- AI understands your homelab structure
- Better, more relevant suggestions

### Terminal Settings

**Default to WSL**:
- Homelab tools work best in Linux
- AI prefers WSL for commands
- Can still use PowerShell when needed

**Scrollback: 10,000 lines**:
- See lots of command history
- Don't lose important output
- Scroll back to check old commands

**Copy on selection**:
- Select text, it's automatically copied
- Right-click to paste
- Faster workflow

## Customizing the Workspace

### Adding Your Own Folders

Edit `homelab.code-workspace`:

```json
{
  "folders": [
    // ... existing folders ...
    {
      "name": "🎯 My Stuff",
      "path": "/path/to/your/folder"
    }
  ]
}
```

### Adding Custom Tasks

Edit `homelab.code-workspace` under `"tasks"`:

```json
{
  "label": "My Custom Task",
  "type": "shell",
  "command": "echo 'Hello from my task!'",
  "presentation": {
    "reveal": "always"
  }
}
```

### Changing Default Terminal

In workspace settings, change:

```json
"terminal.integrated.defaultProfile.windows": "PowerShell (Admin)"
```

## Troubleshooting

### Workspace won't open

**Solution**:
1. Make sure you have VS Code installed
2. Check the file is `homelab.code-workspace`
3. Try: File → Open Workspace from File

### Folders show "Not Found"

**Solution**:
The workspace expects your Homelab folder to be next to this one.

**Structure should be**:
```
C:\Users\YourName\
├── homelab\                  ← VS-code-home-lab repo
│   └── homelab.code-workspace
└── Homelab\                  ← Your actual homelab
    └── infra\
```

**Fix**: Move folders or edit paths in workspace file.

### AI assistants not working

**Check**:
1. Extensions installed? (Check Extensions panel)
2. Logged in? (Click AI extension icons)
3. MCP server running? (See WINDOWS_WSL_SETUP.md)

**Solution**:
- Install missing extensions
- Sign in to GitHub, Anthropic, Google
- Test MCP server in WSL

### Terminal opens to wrong folder

**Solution**:
1. Click the `v` dropdown next to `+` in terminal
2. Select "Select Default Profile"
3. Choose "WSL - Ubuntu (AI Preferred)"

### Code not formatting on save

**Check**:
- `editor.formatOnSave` is true? (File → Preferences → Settings)
- Prettier extension installed?
- `.prettierrc.json` file exists?

**Solution**:
1. Install Prettier extension
2. Reload window: Ctrl+Shift+P → "Reload Window"

## Tips & Tricks

### Tip 1: Workspace saves your layout

- Open files in specific tabs
- Arrange them how you like
- Next time you open workspace, it's the same!

### Tip 2: Multiple workspace windows

You can have multiple workspace instances:

1. File → New Window
2. Open different workspace or folder
3. Work on multiple things at once!

### Tip 3: Search across all folders

- Ctrl+Shift+F opens search
- Searches ALL folders in workspace
- Find anything in your entire homelab!

### Tip 4: Git integration

- Sidebar shows changed files
- Click file to see diff
- Stage, commit, push from UI
- AI can help write commit messages!

### Tip 5: Quick file switching

- Ctrl+P opens quick open
- Type filename
- Searches all folders
- Jump anywhere instantly!

## Common Workflows

### Workflow 1: Making a Change

1. Open workspace (`homelab.code-workspace`)
2. Navigate to relevant folder (e.g., `☸️ Kubernetes`)
3. Edit the file
4. Ask AI: "Does this look correct?"
5. Save (auto-formats)
6. Test with terminal commands
7. Commit via Git panel

### Workflow 2: Deploying Something

1. Open workspace
2. Ask AI: "Deploy this service to Kubernetes"
3. AI generates or updates manifests
4. Review the changes
5. AI runs `kubectl apply` via MCP
6. Check status with health check task

### Workflow 3: Troubleshooting

1. Run health check task (Ctrl+Shift+B)
2. See which pods are failing
3. Ask AI: "Why is this pod failing?"
4. AI checks logs via `kubectl logs`
5. AI suggests fixes
6. Apply fixes and re-check

### Workflow 4: Learning

1. Open a file you don't understand
2. Select some code
3. Right-click → Ask AI: "Explain this"
4. AI breaks it down in simple terms
5. Ask follow-up questions
6. Learn by exploring with AI!

## Next Steps

Now that you understand the workspace:

1. **Open it**: Double-click `homelab.code-workspace`
2. **Explore folders**: Click through each section
3. **Try AI**: Ask Copilot or Continue.dev a question
4. **Run a task**: Press Ctrl+Shift+B
5. **Customize**: Add your own folders or tasks

## Summary

**The workspace gives you**:

✅ Organized view of your entire homelab
✅ AI assistants ready to help
✅ Smart terminal configuration
✅ Auto-formatting and linting
✅ Quick tasks for common operations
✅ Everything optimized for homelab work

**Remember**:
- The workspace is just VS Code configured perfectly for your homelab
- You can always edit the `.code-workspace` file to customize
- AI assistants work best when you use the workspace
- All your code stays organized and easy to find

**Happy homelabbing with AI-powered VS Code!** 🚀
