#!/bin/bash

# ===============================================
# init-workspace.sh
# FULL WORKSPACE INITIALIZATION
# See GIT_WORKFLOW.md for rules.
# ===============================================

set -e

# --- Detect Monorepo Root & Project Name ---
MONOREPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MONOREPO_NAME=$(basename "$MONOREPO_DIR")

# Extract project name (remove -monorepo suffix if present)
if [[ "$MONOREPO_NAME" == *-monorepo ]]; then
  PROJECT_NAME="${MONOREPO_NAME%-monorepo}"
else
  PROJECT_NAME="$MONOREPO_NAME"
fi

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   🚀 WORKSPACE INITIALIZATION${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "   Project:  ${GREEN}$PROJECT_NAME${NC}"
echo -e "   Root:     $MONOREPO_DIR"
echo ""

# ============================================================================
# STEP 1: CHECK GITHUB CLI (gh)
# ============================================================================

echo -e "${YELLOW}📡 Step 1: GitHub CLI Setup${NC}"
echo ""

GH_READY=false

# Check if gh is installed
if ! command -v gh &>/dev/null; then
  echo -e "   ${RED}❌ GitHub CLI (gh) is not installed.${NC}"
  echo ""
  echo "      Install it with:"
  echo "        brew install gh"
  echo ""
  echo "      Then run: gh auth login"
  echo ""
  exit 1
fi

# Check if gh is authenticated
if gh auth status &>/dev/null; then
  GH_USER=$(gh api user --jq '.login' 2>/dev/null || echo "unknown")
  echo -e "   ${GREEN}✅ GitHub CLI authenticated${NC}"
  echo "      Logged in as: $GH_USER"
  GH_READY=true
else
  echo -e "   ${RED}❌ GitHub CLI is not authenticated.${NC}"
  echo ""
  echo "      Run: gh auth login"
  echo ""
  exit 1
fi
echo ""

# ============================================================================
# STEP 2: CHECK MYSAY (Agent Communication)
# ============================================================================

echo -e "${YELLOW}📡 Step 2: Agent Communication Setup${NC}"
echo ""

MYSAY_INSTALLED=false

if command -v mysay &>/dev/null; then
  MYSAY_INSTALLED=true
  echo -e "   ${GREEN}✅ mysay is installed${NC}"
  echo "      Agents will use voice + Telegram to communicate."
else
  echo "   ❓ mysay is not installed."
  echo ""
  echo "      mysay enables AI agents to:"
  echo "        • Speak to you (voice)"
  echo "        • Send Telegram messages"
  echo "        • Wait for your replies"
  echo ""
  read -p "      Install mysay? (y/n): " INSTALL_MYSAY
  echo ""
  
  if [[ "$INSTALL_MYSAY" =~ ^[Yy]$ ]]; then
    echo "   📦 Installing mysay..."
    MYSAY_TEMP="/tmp/mysay-install-$$"
    git clone https://github.com/zyahav/mysay.git "$MYSAY_TEMP"
    cd "$MYSAY_TEMP"
    ./install.sh
    cd "$MONOREPO_DIR"
    rm -rf "$MYSAY_TEMP"
    MYSAY_INSTALLED=true
    echo -e "   ${GREEN}✅ mysay installed!${NC}"
  else
    echo -e "   ${YELLOW}⚠️  Skipping mysay. Agents will use text-only.${NC}"
  fi
fi
echo ""

# ============================================================================
# STEP 3: REPOSITORY SETUP
# ============================================================================

echo -e "${YELLOW}📋 Step 3: Repository Setup${NC}"
echo ""

REPO_URL=""

echo "   How do you want to set up the repository?"
echo ""
echo "   1) Create NEW repository on GitHub"
echo "   2) Use EXISTING repository URL"
echo ""
read -p "   Choose (1 or 2): " REPO_CHOICE
echo ""

if [[ "$REPO_CHOICE" == "1" ]]; then
  # Create new repository
  read -p "   Repository name (default: $PROJECT_NAME): " REPO_NAME
  REPO_NAME="${REPO_NAME:-$PROJECT_NAME}"
  
  echo ""
  echo "   Visibility:"
  echo "   1) Private (default)"
  echo "   2) Public"
  read -p "   Choose (1 or 2): " VISIBILITY_CHOICE
  
  if [[ "$VISIBILITY_CHOICE" == "2" ]]; then
    VISIBILITY="--public"
    VISIBILITY_TEXT="public"
  else
    VISIBILITY="--private"
    VISIBILITY_TEXT="private"
  fi
  
  echo ""
  echo "   Creating $VISIBILITY_TEXT repository: $GH_USER/$REPO_NAME"
  
  # Create the project directory first
  PROJECT_MAIN="$MONOREPO_DIR/$PROJECT_NAME"
  mkdir -p "$PROJECT_MAIN"
  cd "$PROJECT_MAIN"
  git init
  echo "# $PROJECT_NAME" > README.md
  git add README.md
  git commit -m "Initial commit"
  
  # Create GitHub repo and push
  gh repo create "$GH_USER/$REPO_NAME" $VISIBILITY --source=. --remote=origin --push
  
  REPO_URL="https://github.com/$GH_USER/$REPO_NAME.git"
  echo -e "   ${GREEN}✅ Repository created: $REPO_URL${NC}"
  
  cd "$MONOREPO_DIR"
  
elif [[ "$REPO_CHOICE" == "2" ]]; then
  read -p "   Enter repository URL: " REPO_URL
  
  if [ -z "$REPO_URL" ]; then
    echo -e "   ${RED}❌ ERROR: Repository URL required.${NC}"
    exit 1
  fi
  
  # Clone the repository
  PROJECT_MAIN="$MONOREPO_DIR/$PROJECT_NAME"
  if [ -d "$PROJECT_MAIN" ]; then
    echo "   ⚠️  Folder '$PROJECT_NAME' already exists → Skipping clone."
  else
    echo "   📥 Cloning repository..."
    git clone "$REPO_URL" "$PROJECT_MAIN"
  fi
else
  echo -e "   ${RED}❌ Invalid choice.${NC}"
  exit 1
fi

# Validate
if [ ! -d "$PROJECT_MAIN/.git" ]; then
  echo -e "   ${RED}❌ ERROR: Repository setup failed.${NC}"
  exit 1
fi

echo -e "   ${GREEN}✔️  Main repository ready${NC}"
echo ""

# --- Define remaining paths ---
PROJECT_DEV="$MONOREPO_DIR/${PROJECT_NAME}-dev"
PROJECT_STAGING="$MONOREPO_DIR/${PROJECT_NAME}-staging"


# ============================================================================
# STEP 4: CREATE WORKTREES
# ============================================================================

echo -e "${YELLOW}🌱 Step 4: Creating Worktrees${NC}"
echo ""

# Check if dev and staging branches exist, create if not
cd "$PROJECT_MAIN"

# Create dev branch if it doesn't exist
if ! git show-ref --verify --quiet refs/heads/dev; then
  echo "   Creating dev branch..."
  git checkout -b dev
  git push -u origin dev
  git checkout main
fi

# Create staging branch if it doesn't exist
if ! git show-ref --verify --quiet refs/heads/staging; then
  echo "   Creating staging branch..."
  git checkout -b staging
  git push -u origin staging
  git checkout main
fi

cd "$MONOREPO_DIR"

# DEV worktree
if [ -d "$PROJECT_DEV/dev" ]; then
  echo "   ⚠️  ${PROJECT_NAME}-dev/dev already exists → Skipping."
else
  echo "   Creating dev worktree..."
  mkdir -p "$PROJECT_DEV"
  git -C "$PROJECT_MAIN" worktree add "$PROJECT_DEV/dev" dev
fi
echo -e "   ${GREEN}✔️  Dev environment ready${NC}"

# STAGING worktree
if [ -d "$PROJECT_STAGING" ]; then
  echo "   ⚠️  ${PROJECT_NAME}-staging already exists → Skipping."
else
  echo "   Creating staging worktree..."
  git -C "$PROJECT_MAIN" worktree add "$PROJECT_STAGING" staging
fi
echo -e "   ${GREEN}✔️  Staging environment ready${NC}"
echo ""

# ============================================================================
# STEP 5: CREATE CLAUDE.md (Agent Instructions)
# ============================================================================

echo -e "${YELLOW}🤖 Step 5: Creating Agent Instructions${NC}"
echo ""

CLAUDE_MD="$PROJECT_MAIN/CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  echo "   ⚠️  CLAUDE.md already exists → Skipping."
else
  echo "   Creating CLAUDE.md..."
  
  cat > "$CLAUDE_MD" << 'CLAUDEMD_START'
# CLAUDE.md — Agent Instructions

## Project Overview
This project uses a Git worktree-based development workflow.
Read `docs/GIT_WORKFLOW.md` in the monorepo root for full rules.

## Quick Reference

### Branch Naming
```
feature/<owner>/<feature-name>
```
- owner = `agent` or `human`
- Example: `feature/agent/add-login`

### Folder Naming
```
dev-<owner>-<feature-name>
```
- Example: `dev-agent-add-login`

### Commit Format
```
<type>(<scope>): <short description>
```
- Types: feat, fix, chore, refactor, docs
- Example: `feat(auth): add login endpoint`

## Forbidden Actions
- Do NOT push directly to main or staging
- Do NOT modify files in monorepo root
- Do NOT create branches manually (use scripts)
- STOP immediately on merge conflicts

## Repository & Git Operations (MANDATORY)

**ALWAYS use GitHub CLI (`gh`). Never use other methods.**

### Check authentication
```bash
gh auth status
```

### Create new repository (PRIVATE by default)
```bash
gh repo create owner/repo-name --private --source=. --push
```

### Create PUBLIC repository (only if explicitly requested)
```bash
gh repo create owner/repo-name --public --source=. --push
```

### NEVER do these:
- ❌ Try SSH key configuration
- ❌ Ask for personal access tokens
- ❌ Create repos via GitHub web UI
- ❌ Use `git remote add` manually
- ❌ Try multiple authentication methods

### If authentication fails:
Tell the developer to run: `gh auth login`
Do NOT try alternative methods.
CLAUDEMD_START

  # Add mysay section if installed
  if [ "$MYSAY_INSTALLED" = true ]; then
    cat >> "$CLAUDE_MD" << 'MYSAYSECTION'

## Communication (mysay)

**This project has mysay installed.** Use it to communicate with the developer.

### Commands
```bash
mysay --done "Task completed"           # 🎉 Celebrate completion
mysay --error "Found a problem"         # 🐛 Report errors
mysay --question -w "Should I continue?" # ❓ Ask and WAIT for reply
mysay --start "Starting work"           # 🚀 Announce start
```

### Rules
- ✅ Use mysay for: task completion, errors, questions needing input
- ❌ Don't use for: routine progress, small steps
- Always use `-w` flag when you need a reply

### Developer Preferences
Check `~/.config/mysay/DEVELOPER_PROFILE.md` for communication preferences.
MYSAYSECTION
  else
    cat >> "$CLAUDE_MD" << 'NOMYSAYSECTION'

## Communication
mysay is not installed. Use text-only responses.
NOMYSAYSECTION
  fi

  # Commit CLAUDE.md to the repo
  cd "$PROJECT_MAIN"
  git add CLAUDE.md
  git commit -m "docs: add CLAUDE.md agent instructions"
  git push origin main
  cd "$MONOREPO_DIR"

  echo -e "   ${GREEN}✔️  CLAUDE.md created and pushed${NC}"
fi
echo ""


# ============================================================================
# COMPLETE
# ============================================================================

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}   ✅ WORKSPACE INITIALIZED SUCCESSFULLY${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "   Structure created:"
echo "   ├── $PROJECT_NAME/            (main branch)"
echo "   ├── ${PROJECT_NAME}-dev/"
echo "   │   └── dev/                  (dev branch)"
echo "   └── ${PROJECT_NAME}-staging/  (staging branch)"
echo ""
echo -e "${YELLOW}   Next steps:${NC}"
echo "   1. cd ${PROJECT_NAME}-dev/dev"
echo "   2. pnpm install (if needed)"
echo "   3. ./scripts/new-feature.sh agent <feature-name>"
echo ""

# Speak if mysay is available
if [ "$MYSAY_INSTALLED" = true ]; then
  mysay --done "Workspace initialized successfully! Ready to start working." &>/dev/null &
fi

echo -e "${GREEN}   🟢 Ready to work!${NC}"
echo ""
