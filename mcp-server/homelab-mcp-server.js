#!/usr/bin/env node

/**
 * Homelab MCP Server
 * Provides full CLI tool access to AI agents running in WSL
 *
 * This server exposes all homelab infrastructure tools through the Model Context Protocol,
 * allowing AI assistants to execute commands with full admin privileges in WSL.
 *
 * Usage:
 *   node homelab-mcp-server.js
 *
 * Or configure in Continue.dev:
 *   {
 *     "experimental": {
 *       "modelContextProtocolServers": [{
 *         "command": "wsl",
 *         "args": ["-e", "node", "/path/to/homelab-mcp-server.js"]
 *       }]
 *     }
 *   }
 */

const { spawn } = require('child_process');
const readline = require('readline');

// Homelab CLI tools available to AI agents
const HOMELAB_TOOLS = {
  // Kubernetes
  kubectl: {
    description: "Kubernetes CLI - manage K8s clusters and resources",
    examples: ["kubectl get pods", "kubectl apply -f manifest.yaml"]
  },
  helm: {
    description: "Kubernetes package manager - install and manage charts",
    examples: ["helm list", "helm install myapp ./chart"]
  },
  k9s: {
    description: "Kubernetes TUI - interactive cluster management",
    examples: ["k9s"]
  },

  // Infrastructure as Code
  terraform: {
    description: "Infrastructure as Code - provision and manage infrastructure",
    examples: ["terraform plan", "terraform apply"]
  },
  ansible: {
    description: "Configuration management - deploy and configure services",
    examples: ["ansible-playbook playbook.yml"]
  },
  "ansible-playbook": {
    description: "Run Ansible playbooks",
    examples: ["ansible-playbook deploy.yml -i inventory"]
  },

  // Containers
  docker: {
    description: "Container runtime - build and run containers",
    examples: ["docker ps", "docker build -t image:tag ."]
  },
  "docker-compose": {
    description: "Multi-container Docker applications",
    examples: ["docker-compose up -d", "docker-compose logs"]
  },

  // Version Control
  git: {
    description: "Version control - manage code repositories",
    examples: ["git status", "git commit -m 'message'"]
  },
  gh: {
    description: "GitHub CLI - interact with GitHub",
    examples: ["gh pr list", "gh issue create"]
  },

  // Programming & Scripting
  python3: {
    description: "Python interpreter",
    examples: ["python3 script.py"]
  },
  node: {
    description: "Node.js runtime",
    examples: ["node script.js"]
  },
  npm: {
    description: "Node package manager",
    examples: ["npm install", "npm run build"]
  },

  // System Utilities
  ls: {
    description: "List directory contents",
    examples: ["ls -la"]
  },
  cat: {
    description: "Display file contents",
    examples: ["cat file.txt"]
  },
  grep: {
    description: "Search text patterns",
    examples: ["grep 'pattern' file.txt"]
  },
  find: {
    description: "Find files and directories",
    examples: ["find . -name '*.yaml'"]
  },
  tree: {
    description: "Display directory tree structure",
    examples: ["tree -L 2"]
  },
  curl: {
    description: "Transfer data with URLs",
    examples: ["curl https://api.example.com"]
  },
  wget: {
    description: "Download files from web",
    examples: ["wget https://example.com/file"]
  },

  // Data Processing
  jq: {
    description: "JSON processor",
    examples: ["cat data.json | jq '.field'"]
  },
  yq: {
    description: "YAML processor",
    examples: ["cat config.yaml | yq '.spec'"]
  },

  // File Operations
  cp: {
    description: "Copy files and directories",
    examples: ["cp source dest"]
  },
  mv: {
    description: "Move/rename files",
    examples: ["mv old new"]
  },
  rm: {
    description: "Remove files (use with caution)",
    examples: ["rm file.txt"]
  },
  mkdir: {
    description: "Create directories",
    examples: ["mkdir -p path/to/dir"]
  },

  // Monitoring & Debugging
  htop: {
    description: "Interactive process viewer",
    examples: ["htop"]
  },
  journalctl: {
    description: "Query systemd journal",
    examples: ["journalctl -u service"]
  },
  systemctl: {
    description: "Control systemd services",
    examples: ["systemctl status service"]
  }
};

/**
 * Execute a command in WSL
 * @param {string} command - Command to execute
 * @param {string[]} args - Command arguments
 * @returns {Promise<{stdout: string, stderr: string, exitCode: number}>}
 */
function executeCommand(command, args) {
  return new Promise((resolve, reject) => {
    const proc = spawn(command, args, {
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: false
    });

    let stdout = '';
    let stderr = '';

    proc.stdout.on('data', (data) => {
      stdout += data.toString();
    });

    proc.stderr.on('data', (data) => {
      stderr += data.toString();
    });

    proc.on('close', (exitCode) => {
      resolve({ stdout, stderr, exitCode });
    });

    proc.on('error', (error) => {
      reject(error);
    });
  });
}

/**
 * MCP Protocol Handler
 */
class MCPServer {
  constructor() {
    this.tools = this.generateToolDefinitions();
  }

  /**
   * Generate MCP tool definitions from HOMELAB_TOOLS
   */
  generateToolDefinitions() {
    return Object.entries(HOMELAB_TOOLS).map(([name, info]) => ({
      name: `execute_${name.replace(/-/g, '_')}`,
      description: `${info.description}\nExamples: ${info.examples.join(', ')}`,
      inputSchema: {
        type: "object",
        properties: {
          args: {
            type: "array",
            items: { type: "string" },
            description: `Arguments for ${name} command`
          },
          cwd: {
            type: "string",
            description: "Working directory (optional)"
          }
        },
        required: ["args"]
      }
    }));
  }

  /**
   * Handle MCP request
   */
  async handleRequest(request) {
    try {
      switch (request.method) {
        case 'initialize':
          return {
            jsonrpc: "2.0",
            id: request.id,
            result: {
              protocolVersion: "0.1.0",
              serverInfo: {
                name: "homelab-mcp-server",
                version: "1.0.0"
              },
              capabilities: {
                tools: {}
              }
            }
          };

        case 'tools/list':
          return {
            jsonrpc: "2.0",
            id: request.id,
            result: {
              tools: this.tools
            }
          };

        case 'tools/call':
          return await this.executeTool(request);

        default:
          throw new Error(`Unknown method: ${request.method}`);
      }
    } catch (error) {
      return {
        jsonrpc: "2.0",
        id: request.id,
        error: {
          code: -32603,
          message: error.message
        }
      };
    }
  }

  /**
   * Execute a tool (CLI command)
   */
  async executeTool(request) {
    const { name, arguments: args } = request.params;

    // Extract command name from tool name (e.g., "execute_kubectl" -> "kubectl")
    const commandName = name.replace(/^execute_/, '').replace(/_/g, '-');

    if (!HOMELAB_TOOLS[commandName]) {
      throw new Error(`Unknown tool: ${commandName}`);
    }

    const commandArgs = args.args || [];
    const cwd = args.cwd || process.cwd();

    // Log the command being executed
    console.error(`[MCP] Executing: ${commandName} ${commandArgs.join(' ')}`);
    console.error(`[MCP] Working directory: ${cwd}`);

    try {
      // Change to working directory if specified
      if (cwd !== process.cwd()) {
        process.chdir(cwd);
      }

      const { stdout, stderr, exitCode } = await executeCommand(commandName, commandArgs);

      return {
        jsonrpc: "2.0",
        id: request.id,
        result: {
          content: [
            {
              type: "text",
              text: stdout || stderr || `Command executed with exit code: ${exitCode}`
            }
          ],
          metadata: {
            exitCode,
            hasStderr: stderr.length > 0
          }
        }
      };
    } catch (error) {
      return {
        jsonrpc: "2.0",
        id: request.id,
        error: {
          code: -32000,
          message: `Failed to execute ${commandName}: ${error.message}`
        }
      };
    }
  }

  /**
   * Start the MCP server (stdio transport)
   */
  start() {
    console.error('[MCP] Homelab MCP Server starting...');
    console.error('[MCP] Available tools:', Object.keys(HOMELAB_TOOLS).length);
    console.error('[MCP] AI agents have full WSL CLI access');

    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: false
    });

    rl.on('line', async (line) => {
      try {
        const request = JSON.parse(line);
        const response = await this.handleRequest(request);
        console.log(JSON.stringify(response));
      } catch (error) {
        console.error('[MCP] Error processing request:', error);
        console.log(JSON.stringify({
          jsonrpc: "2.0",
          id: null,
          error: {
            code: -32700,
            message: "Parse error"
          }
        }));
      }
    });

    rl.on('close', () => {
      console.error('[MCP] Server shutting down');
      process.exit(0);
    });
  }
}

// Start the server
const server = new MCPServer();
server.start();
