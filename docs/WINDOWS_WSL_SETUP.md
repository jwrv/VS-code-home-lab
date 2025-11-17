# Windows + WSL Dual Setup Guide for Complete Beginners

This guide will help you set up VS Code to work on **both Windows and WSL**. Even if you've never
used a computer before, you can follow along! We'll explain everything in simple terms.

## Table of Contents

1. [What You'll Learn](#what-youll-learn)
2. [Why Use Both Windows and WSL?](#why-use-both-windows-and-wsl)
3. [Prerequisites](#prerequisites)
4. [Step-by-Step Setup](#step-by-step-setup)
5. [Using Your New Setup](#using-your-new-setup)
6. [Troubleshooting](#troubleshooting)

## What You'll Learn

By the end of this guide, you'll have:

- ✅ VS Code working on Windows (your normal environment)
- ✅ VS Code working in WSL (Linux inside Windows)
- ✅ Both sharing the same code files
- ✅ AI assistants able to run homelab commands
- ✅ All your tools ready to use

## Why Use Both Windows and WSL?

Think of it like this:

| Environment | What It's Like | Best For |
|-------------|----------------|----------|
| **Windows** | Your comfortable home | Browsing files, editing docs, familiar programs |
| **WSL** | A Linux workshop in your basement | Homelab tools (Kubernetes, Docker, etc.) |

**The Magic**: They share the same files! Edit in Windows, run commands in WSL. It just works!

## Prerequisites

### What You Need

Before starting, make sure you have:

- [ ] Windows 10 version 2004 or higher, OR Windows 11
- [ ] Administrator access on your computer
- [ ] Internet connection
- [ ] About 30 minutes of time

### How to Check Your Windows Version

1. Press `Windows Key` + `R`
2. Type `winver` and press Enter
3. Look for "Version" - it should say 2004 or higher

**Don't have it?** Run Windows Update first.

## Step-by-Step Setup

### Part 1: Install WSL (Windows Subsystem for Linux)

This is like installing a mini Linux computer inside Windows.

#### Step 1.1: Open PowerShell as Administrator

1. Click the Windows Start button (bottom left)
2. Type `PowerShell`
3. Right-click on "Windows PowerShell"
4. Click "Run as administrator"
5. Click "Yes" when asked for permission

**You'll see a blue window with white text - that's PowerShell!**

#### Step 1.2: Install WSL

In the PowerShell window, type this **exactly** and press Enter:

```powershell
wsl --install -d Ubuntu-22.04
```

**What this does**: Installs Ubuntu Linux inside Windows.

**What you'll see**:
- Text scrolling (this is good!)
- "Installing..." messages
- Might take 5-10 minutes

**When it's done**: Your computer will ask to restart.
- Click "Restart now"
- Wait for your computer to restart (this is normal!)

#### Step 1.3: First Time Setup (After Restart)

When your computer restarts:

1. A window will pop up saying "Installing Ubuntu"
2. Wait (this takes a few minutes)
3. It will ask: "Enter new UNIX username:"
   - Type a simple username (like your first name, all lowercase)
   - Press Enter
4. It will ask for a password
   - Type a password (you won't see it typing - this is normal!)
   - Press Enter
5. Type the same password again
   - Press Enter

**Congratulations! WSL is installed!** 🎉

### Part 2: Set Up Your Workspace Folder

Now we'll create a folder where all your code lives.

#### Step 2.1: Create the Folder in Windows

1. Open File Explorer (the folder icon on your taskbar)
2. Click on "This PC" on the left
3. Double-click "Local Disk (C:)"
4. Double-click "Users"
5. Double-click your username folder
6. Right-click in the empty space
7. Choose "New" → "Folder"
8. Name it `homelab`
9. Press Enter

**Your folder path**: `C:\Users\YourUsername\homelab`

(Replace "YourUsername" with your actual Windows username)

#### Step 2.2: Download the Homelab Code

1. Open PowerShell (doesn't need to be administrator this time)
   - Press `Windows Key` + `R`
   - Type `powershell`
   - Press Enter

2. Go to your homelab folder:
   ```powershell
   cd C:\Users\YourUsername\homelab
   ```
   (Replace "YourUsername" with your actual username)

3. Download the code:
   ```powershell
   git clone https://github.com/jwrv/VS-code-home-lab.git .
   ```
   (The dot at the end is important!)

**What this does**: Downloads all the homelab setup files to your folder.

**If you see an error about git**: You need to install Git first.
- Go to: https://git-scm.com/download/win
- Download and install Git for Windows
- Then try the command again

### Part 3: Install VS Code and Extensions

#### Step 3.1: Install VS Code

1. Go to: https://code.visualstudio.com/
2. Click the big "Download for Windows" button
3. Run the installer
4. Click "Next" through all the screens
5. Click "Install"
6. Click "Finish"

**VS Code is now installed!**

#### Step 3.2: Install the WSL Extension

1. Open VS Code
2. Look at the left sidebar - click the icon that looks like building blocks (Extensions)
3. In the search box at the top, type: `WSL`
4. Look for "WSL" by Microsoft
5. Click the blue "Install" button

**Done!** You can now close the Extensions panel.

### Part 4: Open Your Workspace

#### Step 4.1: Open the Folder in VS Code

1. In VS Code, click "File" → "Open Folder"
2. Navigate to `C:\Users\YourUsername\homelab`
3. Click "Select Folder"
4. If asked "Do you trust the authors?", click "Yes, I trust"

**You should now see your files in VS Code!**

#### Step 4.2: Switch to WSL Mode

This is where the magic happens - we're going to make VS Code work in WSL!

1. Look at the bottom-left corner of VS Code
2. You'll see a blue or green icon that says  `><` or "Open a Remote Window"
3. Click that icon
4. A menu appears at the top
5. Click "Reopen Folder in WSL"

**What happens**:
- VS Code will reload
- Bottom-left corner now says "WSL: Ubuntu"
- You're now in Linux mode!
- **The files are still the same!**

### Part 5: Install Homelab Tools in WSL

Now we'll install all the tools needed for your homelab. We'll do this **inside WSL**.

#### Step 5.1: Open a Terminal in WSL

In VS Code (while in WSL mode):

1. Click "Terminal" at the top menu
2. Click "New Terminal"
3. A terminal window opens at the bottom
4. You should see something like: `username@computer:~$`

**This is your Linux terminal!**

#### Step 5.2: Update Linux

Copy and paste this command (right-click in terminal to paste):

```bash
sudo apt update && sudo apt upgrade -y
```

- It will ask for your password (the one you created during WSL setup)
- Type it (you won't see it) and press Enter
- Wait (might take a few minutes)

**What this does**: Updates Linux to the latest versions.

#### Step 5.3: Install Essential Tools

Copy and paste each command one at a time:

**Basic Tools:**
```bash
sudo apt install -y git curl wget unzip zip build-essential python3 python3-pip
```

**Network Tools:**
```bash
sudo apt install -y jq yq htop tree net-tools dnsutils
```

**What these are**: Helper programs that other tools need.

#### Step 5.4: Install Docker

Docker runs containers (like tiny virtual machines).

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

After this, **close and reopen** your terminal:
- Click the trash can icon on the terminal
- Click "Terminal" → "New Terminal" again

#### Step 5.5: Install Kubernetes Tools

These let you manage Kubernetes clusters.

**kubectl** (Kubernetes command-line tool):
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
```

**Helm** (Kubernetes package manager):
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**k9s** (Interactive Kubernetes viewer):
```bash
wget https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xzf k9s_Linux_amd64.tar.gz
sudo mv k9s /usr/local/bin/
rm k9s_Linux_amd64.tar.gz
```

#### Step 5.6: Install Terraform

Terraform creates infrastructure as code.

```bash
wget https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip terraform_1.7.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.7.5_linux_amd64.zip
```

#### Step 5.7: Install Ansible

Ansible configures servers automatically.

```bash
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible
```

#### Step 5.8: Verify Everything Installed

Let's check that all tools work:

```bash
echo "=== Checking Installed Tools ===" &&
for tool in git docker kubectl terraform ansible helm k9s python3 node; do
  if command -v $tool &> /dev/null; then
    echo "✓ $tool - Installed!"
  else
    echo "✗ $tool - NOT FOUND"
  fi
done
```

**You should see check marks (✓) for each tool!**

If any show ✗, go back and re-run that tool's installation command.

### Part 6: Set Up AI Assistant Access

This lets AI assistants run commands for you!

#### Step 6.1: Install Node.js (for MCP Server)

The MCP server needs Node.js to run.

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

Check it installed:
```bash
node --version
```

Should show something like `v20.11.0`

#### Step 6.2: Test the MCP Server

```bash
cd /mnt/c/Users/YourUsername/homelab/mcp-server
node homelab-mcp-server.js
```

(Replace "YourUsername" with your actual Windows username)

**You should see**:
```
[MCP] Homelab MCP Server starting...
[MCP] Available tools: 30+
[MCP] AI agents have full WSL CLI access
```

Press `Ctrl + C` to stop it (this is just a test!)

**Congratulations! Everything is set up!** 🎉

## Using Your New Setup

### Switching Between Windows and WSL

**From Windows to WSL:**
1. Open your folder in VS Code (Windows mode)
2. Click the bottom-left corner `><` icon
3. Click "Reopen Folder in WSL"
4. Now you're in Linux mode!

**From WSL to Windows:**
1. Click the bottom-left "WSL: Ubuntu" text
2. Click "Reopen Folder Locally"
3. Now you're back in Windows mode!

### When to Use Which

| Task | Use |
|------|-----|
| Editing files, browsing code | Either one! Both work great |
| Running kubectl, docker, terraform | **WSL** (Linux has better support) |
| Using AI assistants for homelab | **WSL** (they prefer it) |
| Windows-specific programs | **Windows** |

### Working with Terminals

**Open Windows PowerShell:**
- In VS Code (Windows mode)
- Terminal → New Terminal
- Should see `PS C:\...`

**Open WSL Bash:**
- In VS Code (WSL mode)
- Terminal → New Terminal
- Should see `username@computer:~$`

**Both have FULL ADMIN ACCESS!** You can do anything you need in either one.

## AI Assistant Configuration

The AI assistants can use all your homelab tools through the MCP server!

### What AI Can Do

When you ask AI assistants (like Claude Code, Continue.dev):

**Example requests:**
- "Show me all Kubernetes pods"
- "Deploy this with Terraform"
- "Run the Ansible playbook"
- "Check Docker containers"

**AI will automatically**:
1. Use the MCP server
2. Run the command in WSL
3. Show you the results
4. Explain what happened

### Setting Up AI Assistants

See the [AI Assistants Setup Guide](AI_ASSISTANTS_SETUP.md) for detailed instructions on:
- GitHub Copilot
- Claude Code
- Google Gemini
- Continue.dev

All of them can use your homelab tools through the MCP server!

## Troubleshooting

### Problem: WSL won't install

**Solution**:
1. Make sure you're running PowerShell as Administrator
2. Check Windows version (need 2004+)
3. Enable Windows features:
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```
4. Restart computer
5. Try `wsl --install` again

### Problem: Can't find files in WSL

Your Windows `C:\` drive is at `/mnt/c/` in WSL.

**Windows path**: `C:\Users\John\homelab`
**WSL path**: `/mnt/c/Users/John/homelab`

### Problem: Permission denied errors

**In WSL**, add yourself to the docker group:
```bash
sudo usermod -aG docker $USER
```

Then close and reopen the terminal.

### Problem: Command not found

**Solution**: Install the missing tool.

| Command | Install with |
|---------|--------------|
| kubectl | See Step 5.5 above |
| docker | See Step 5.4 above |
| terraform | See Step 5.6 above |
| ansible | See Step 5.7 above |

### Problem: VS Code won't connect to WSL

**Solution**:
1. Close VS Code completely
2. Open PowerShell
3. Type: `wsl --shutdown`
4. Wait 10 seconds
5. Open VS Code again
6. Try connecting to WSL again

### Problem: Git asking for credentials every time

**Solution** (run in WSL terminal):
```bash
git config --global credential.helper store
```

Next time you enter credentials, they'll be saved.

### Problem: Slow performance in WSL

**Tips**:
1. Keep files in Windows (`C:\Users\...`) and access from WSL
2. Don't put files in WSL home (`~`) and access from Windows
3. Use `/mnt/c/...` paths in WSL for best performance

### Problem: MCP server not starting

**Check Node.js is installed**:
```bash
node --version
```

If not installed, go back to Step 6.1

**Check you're in the right folder**:
```bash
pwd
```

Should show something ending in `/mcp-server`

**Try running with more info**:
```bash
node homelab-mcp-server.js 2>&1 | tee mcp.log
```

This saves output to `mcp.log` file you can check.

## Next Steps

Now that everything is set up:

1. **Try the AI assistants** - Ask them to show you Kubernetes pods or Docker containers
2. **Explore the homelab code** - Browse the `kubernetes/`, `terraform/`, and `ansible/` folders
3. **Run some commands** - Try `kubectl get pods` or `docker ps` in WSL
4. **Read the other guides**:
   - [Linting Guide](LINTING_GUIDE.md) - Keep your code clean
   - [AI Assistants Guide](AI_ASSISTANTS_SETUP.md) - Set up all 5 AI options

## Summary

**What you have now:**

✅ Windows VS Code - Full admin access, use Windows tools
✅ WSL VS Code - Full admin access, use Linux/homelab tools
✅ Shared files - Same code in both environments
✅ All homelab tools - kubectl, docker, terraform, ansible
✅ MCP server - AI assistants can run any command
✅ Both environments powerful - Do anything you need!

**Remember**:
- Both Windows and WSL have full admin access
- Use whichever environment is better for your task
- AI assistants prefer WSL for homelab commands
- Files are always in sync between both

You're all set! Happy homelabbing! 🚀
