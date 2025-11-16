# Linting and Code Quality Guide

This guide explains the comprehensive linting and code quality setup for the VS Code Homelab environment.

## Overview

This repository includes enterprise-grade linting for all file types commonly used in homelab infrastructure:

- **Markdown** - markdownlint + prettier
- **YAML** - yamllint + prettier
- **Python** - black + ruff + isort
- **Shell** - shellcheck + shfmt
- **Terraform** - terraform fmt + terraform validate
- **Dockerfile** - hadolint
- **JSON** - prettier
- **JavaScript/TypeScript** - prettier + eslint

## Quick Start

### Install Pre-commit Hooks

```bash
# Install pre-commit (if not already installed in dev container)
pip install pre-commit

# Install the git hook scripts
pre-commit install

# (Optional) Run against all files
pre-commit run --all-files
```

### VS Code Integration

All linting runs automatically in VS Code:

- **On Save**: Format on save is enabled for all file types
- **On Type**: Real-time linting with inline errors (Error Lens)
- **Before Commit**: Pre-commit hooks validate before git commit

## File-Specific Configuration

### Markdown Files

**Configuration Files:**
- `.markdownlint.json` - Markdown linting rules
- `.prettierrc.json` - Formatting rules

**VS Code Settings:**
```json
{
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.wordWrap": "on",
    "editor.wordWrapColumn": 100
  }
}
```

**Rules:**
- Line length: No limit (MD013 disabled) - allows long lines in documentation
- HTML allowed: `<br>`, `<img>`, `<details>`, etc.
- First line heading: Not required (MD041 disabled)
- Bare URLs: Allowed (MD034 disabled)

**Common Issues and Fixes:**

```bash
# Fix markdown lint errors automatically
markdownlint --fix '**/*.md'

# Format with prettier
prettier --write '**/*.md'
```

### YAML Files

**Configuration Files:**
- `.yamllint.yml` - YAML linting rules

**Rules:**
- Line length: 120 characters (warning only)
- Indentation: 2 spaces
- Truthy values: `true/false`, `yes/no`, `on/off` all allowed
- Document markers: Optional

**Common Issues:**

```bash
# Check YAML files
yamllint .

# Auto-format with prettier
prettier --write '**/*.{yml,yaml}'
```

**Kubernetes/Ansible-specific:**
- Custom tags supported (`!vault`, `!reference`, etc.)
- Long lines in comments allowed
- Schema validation for K8s manifests

### Python Files

**Configuration Files:**
- `pyproject.toml` (if present) or embedded in pre-commit config

**Tools:**
- **Black**: Code formatting (line length: 100)
- **isort**: Import sorting (profile: black)
- **Ruff**: Fast linting (replaces flake8/pylint)

**VS Code Settings:**
```json
{
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  }
}
```

**Common Commands:**

```bash
# Format Python code
black --line-length 100 .

# Sort imports
isort --profile black .

# Lint with Ruff
ruff check --fix .
```

### Shell Scripts

**Configuration:** shellcheck (built-in rules)

**Rules:**
- POSIX compliance checking
- Common mistake detection
- Best practices enforcement

**Common Issues:**

```bash
# Check shell scripts
shellcheck **/*.sh

# Format shell scripts
shfmt -w -i 2 **/*.sh
```

**VS Code Settings:**
```json
{
  "[shellscript]": {
    "editor.defaultFormatter": "foxundermoon.shell-format"
  }
}
```

### Terraform Files

**Tools:**
- `terraform fmt` - Official formatter
- `terraform validate` - Syntax and reference validation

**VS Code Settings:**
```json
{
  "[terraform]": {
    "editor.defaultFormatter": "hashicorp.terraform",
    "editor.formatOnSave": true
  }
}
```

**Common Commands:**

```bash
# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate
```

### Dockerfiles

**Tool:** hadolint

**Configuration:** `.hadolintrc` (if custom rules needed)

**Common Issues:**

```bash
# Lint Dockerfile
hadolint Dockerfile

# Lint all Dockerfiles
find . -name "Dockerfile*" -exec hadolint {} \;
```

**Ignored Rules (optional):**
- DL3008: Pin versions in apt-get install
- DL3009: Delete apt cache

## Spell Checking

**Extension:** Code Spell Checker (cSpell)

**Configuration:** `.vscode/settings.json` > `cSpell.*`

### Homelab-Specific Dictionary

The configuration includes 200+ homelab-specific terms:

- Kubernetes terms: kubectl, k3s, kustomize, argocd
- Infrastructure: terraform, ansible, proxmox, traefik
- Applications: nextcloud, jellyfin, vaultwarden
- Protocols: mqtt, zigbee, nfs, iscsi
- And many more...

### Spell Check Settings

```json
{
  "cSpell.diagnosticLevel": "Warning",  // Show as warnings, not errors
  "cSpell.minWordLength": 4,            // Ignore short words
  "cSpell.maxNumberOfProblems": 100
}
```

### Ignore Patterns

Spell checking automatically ignores:
- Code blocks in markdown (```...```)
- Inline code (`...`)
- Links [text](url)
- YAML key:value pairs
- Comments in YAML/Ansible

### Adding Custom Words

**Per-file:**
```markdown
<!-- cSpell:ignore customword anotherword -->
```

**Globally:**
Edit `.vscode/settings.json` and add to `cSpell.words` array.

## Pre-commit Hooks

All checks run automatically before commit.

### Hook Configuration

File: `.pre-commit-config.yaml`

### Installed Hooks

1. **General Checks:**
   - Trailing whitespace removal
   - End-of-file fixer
   - Large file detection
   - Merge conflict detection
   - Private key detection

2. **Formatters:**
   - Prettier (MD, JSON, YAML, JS/TS)
   - Black (Python)
   - Terraform fmt

3. **Linters:**
   - markdownlint
   - shellcheck
   - yamllint
   - hadolint
   - ruff (Python)
   - actionlint (GitHub Actions)

4. **Security:**
   - gitleaks (secret detection)

### Skipping Hooks

```bash
# Skip all hooks (NOT RECOMMENDED)
git commit --no-verify

# Skip specific hook
SKIP=shellcheck git commit -m "message"

# Skip multiple hooks
SKIP=shellcheck,yamllint git commit -m "message"
```

### Updating Hooks

```bash
# Update to latest versions
pre-commit autoupdate

# Run manually
pre-commit run --all-files
```

## Prettier Configuration

**File:** `.prettierrc.json`

### Global Settings

```json
{
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": false,
  "trailingComma": "es5",
  "endOfLine": "lf",
  "proseWrap": "preserve"
}
```

### File-Specific Overrides

- **Markdown**: 100 character line width, preserve wrapping
- **YAML**: 100 character line width, double quotes
- **JSON**: 2 space indentation
- **JS/TS**: 100 character line width

### Ignoring Files

**File:** `.prettierignore`

Prettier skips:
- `node_modules/`
- `.terraform/`
- `*.min.js`, `*.min.css`
- Lock files

## EditorConfig

**File:** `.editorconfig`

Ensures consistent formatting across editors:

- UTF-8 encoding
- LF line endings
- Trim trailing whitespace
- Final newline
- 2-space indentation (except Python: 4 spaces)
- Tabs for Makefiles

## Troubleshooting

### Issue: Spell checker showing too many errors

**Solution:**
1. Add common terms to `.vscode/settings.json` > `cSpell.words`
2. Use `<!-- cSpell:ignore word1 word2 -->` in markdown
3. Adjust `cSpell.diagnosticLevel` to "Information" to reduce noise

### Issue: Line length violations in markdown

**Solution:**
Line length is disabled for markdown (MD013: false). If prettier is breaking lines:

1. Check `.prettierrc.json` has `"proseWrap": "preserve"`
2. Ensure markdown formatter is set to prettier

### Issue: YAML indentation errors

**Solution:**
```bash
# Auto-fix with prettier
prettier --write problematic-file.yaml

# Check yamllint rules
yamllint -c .yamllint.yml file.yaml
```

### Issue: Python import order conflicts

**Solution:**
Both isort and ruff handle imports. Configuration ensures compatibility:

```bash
# Fix import order
isort --profile black .

# Then format
black .
```

### Issue: Pre-commit hooks failing

**Solution:**
```bash
# See which hook is failing
pre-commit run --all-files

# Update hooks to latest
pre-commit autoupdate

# Clean and reinstall
pre-commit clean
pre-commit install --install-hooks
```

### Issue: Terraform validation failing

**Solution:**
```bash
# Initialize Terraform first
terraform init

# Then validate
terraform validate

# Format
terraform fmt -recursive
```

## GitHub Actions Integration

All linting can run in CI/CD:

```yaml
name: Lint

on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install pre-commit
        run: pip install pre-commit

      - name: Run pre-commit
        run: pre-commit run --all-files
```

## Best Practices

1. **Enable format on save** - Catches issues immediately
2. **Run pre-commit before pushing** - `pre-commit run --all-files`
3. **Keep custom word list updated** - Add homelab-specific terms
4. **Review warnings, not just errors** - Spell check warnings matter
5. **Use `.gitignore`** - Don't commit generated files
6. **Update hooks monthly** - `pre-commit autoupdate`

## Configuration Files Summary

| File | Purpose | Tool |
|------|---------|------|
| `.markdownlint.json` | Markdown linting rules | markdownlint |
| `.prettierrc.json` | Code formatting | prettier |
| `.prettierignore` | Files to skip formatting | prettier |
| `.yamllint.yml` | YAML linting rules | yamllint |
| `.editorconfig` | Editor consistency | EditorConfig |
| `.pre-commit-config.yaml` | Pre-commit hooks | pre-commit |
| `.vscode/settings.json` | VS Code configuration | VS Code |
| `.continuerc.json` | Continue.dev AI config | Continue.dev |

## Resources

- [markdownlint rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [Prettier options](https://prettier.io/docs/en/options.html)
- [yamllint documentation](https://yamllint.readthedocs.io/)
- [shellcheck wiki](https://github.com/koalaman/shellcheck/wiki)
- [pre-commit hooks](https://pre-commit.com/hooks.html)
- [Code Spell Checker](https://github.com/streetsidesoftware/vscode-spell-checker)
