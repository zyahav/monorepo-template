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
# STEP 1: CHECK MYSAY (Agent Communication)
# ============================================================================

echo -e "${YELLOW}📡 Step 1: Agent Communication Setup${NC}"
echo ""

MYSAY_INSTALLED=false

if command -v mysay &>/dev/null; then
  MYSAY_INSTALLED=true
  echo -e "   ${GREEN}✅ mysay is installed${NC}"
  echo "      Agents will use voice + Telegram to communicate with you."
  echo ""
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
    echo ""
  else
    echo -e "   ${YELLOW}⚠️  Skipping mysay. Agents will use text-only communication.${NC}"
    echo ""
  fi
fi

# ============================================================================
# STEP 2: VALIDATE INPUT
# ============================================================================

echo -e "${YELLOW}📋 Step 2: Repository Setup${NC}"
echo ""

if [ -z "$1" ]; then
  echo -e "   ${RED}❌ ERROR: Git repository URL required.${NC}"
  echo ""
  echo "   Usage: ./scripts/init-workspace.sh <git-repo-url>"
  echo ""
  echo "   Example:"
  echo "     ./scripts/init-workspace.sh https://github.com/user/myproject.git"
  echo ""
  exit 1
fi

REPO_URL=$1

# --- Define Paths ---
PROJECT_MAIN="$MONOREPO_DIR/$PROJECT_NAME"
PROJECT_DEV="$MONOREPO_DIR/${PROJECT_NAME}-dev"
PROJECT_STAGING="$MONOREPO_DIR/${PROJECT_NAME}-staging"


# ============================================================================
# STEP 3: CLONE REPOSITORY
# ============================================================================

if [ -d "$PROJECT_MAIN" ]; then
  echo "   ⚠️  Folder '$PROJECT_NAME' already exists → Skipping clone."
else
  echo "   📥 Cloning repository into $PROJECT_NAME/ ..."
  git clone "$REPO_URL" "$PROJECT_MAIN"
fi

# Validate clone
if [ ! -d "$PROJECT_MAIN/.git" ]; then
  echo -e "   ${RED}❌ ERROR: Cloning failed or repo is corrupted.${NC}"
  exit 1
fi

echo -e "   ${GREEN}✔️  Main worktree ready${NC}"
echo ""

# ============================================================================
# STEP 4: CREATE WORKTREES
# ============================================================================

echo -e "${YELLOW}🌱 Step 3: Creating Worktrees${NC}"
echo ""

# DEV worktree
if [ -d "$PROJECT_DEV" ]; then
  echo "   ⚠️  ${PROJECT_NAME}-dev/ already exists → Skipping."
else
  echo "   Creating dev worktree..."
  mkdir -p "$PROJECT_DEV"
  git -C "$PROJECT_MAIN" worktree add "$PROJECT_DEV/dev" dev
fi
echo -e "   ${GREEN}✔️  Dev environment ready${NC}"

# STAGING worktree
if [ -d "$PROJECT_STAGING" ]; then
  echo "   ⚠️  ${PROJECT_NAME}-staging/ already exists → Skipping."
else
  echo "   Creating staging worktree..."
  git -C "$PROJECT_MAIN" worktree add "$PROJECT_STAGING" staging
fi
echo -e "   ${GREEN}✔️  Staging environment ready${NC}"
echo ""


# ============================================================================
# STEP 5: CREATE CLAUDE.md (Agent Instructions)
# ============================================================================

echo -e "${YELLOW}🤖 Step 4: Creating Agent Instructions${NC}"
echo ""

CLAUDE_MD="$PROJECT_MAIN/CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  echo "   ⚠️  CLAUDE.md already exists → Skipping."
else
  echo "   Creating CLAUDE.md..."
  
  cat > "$CLAUDE_MD" << CLAUDEMD
# CLAUDE.md — Agent Instructions for $PROJECT_NAME

## Project Overview
This project uses a Git worktree-based development workflow.
Read \`docs/GIT_WORKFLOW.md\` in the monorepo root for full rules.

## Quick Reference

### Branch Naming
\`\`\`
feature/<owner>/<feature-name>
\`\`\`
- owner = \`agent\` or \`human\`
- Example: \`feature/agent/add-login\`

### Folder Naming
\`\`\`
dev-<owner>-<feature-name>
\`\`\`
- Example: \`dev-agent-add-login\`

### Commit Format
\`\`\`
<type>(<scope>): <short description>
\`\`\`
- Types: feat, fix, chore, refactor, docs
- Example: \`feat(auth): add login endpoint\`

## Forbidden Actions
- Do NOT push directly to main or staging
- Do NOT modify files in monorepo root
- Do NOT create branches manually (use scripts)
- STOP immediately on merge conflicts

CLAUDEMD

  # Add mysay section if installed
  if [ "$MYSAY_INSTALLED" = true ]; then
    cat >> "$CLAUDE_MD" << MYSAYSECTION

## Communication (mysay)

**This project has mysay installed.** Use it to communicate with the developer.

### Commands
\`\`\`bash
mysay --done "Task completed"           # 🎉 Celebrate completion
mysay --error "Found a problem"         # 🐛 Report errors
mysay --question -w "Should I continue?" # ❓ Ask and WAIT for reply
mysay --start "Starting work"           # 🚀 Announce start
\`\`\`

### Rules
- ✅ Use mysay for: task completion, errors, questions needing input
- ❌ Don't use for: routine progress, small steps
- Always use \`-w\` flag when you need a reply

### Developer Preferences
Check \`~/.config/mysay/DEVELOPER_PROFILE.md\` for communication preferences.
MYSAYSECTION
  else
    cat >> "$CLAUDE_MD" << NOMYSAYSECTION

## Communication
mysay is not installed. Use text-only responses.
NOMYSAYSECTION
  fi

  echo -e "   ${GREEN}✔️  CLAUDE.md created${NC}"
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
echo "   2. pnpm install"
echo "   3. ./scripts/new-feature.sh agent <feature-name>"
echo ""

# Speak if mysay is available
if [ "$MYSAY_INSTALLED" = true ]; then
  mysay --done "Workspace initialized successfully! Ready to start working." &>/dev/null &
fi

echo -e "${GREEN}   🟢 Ready to work!${NC}"
echo ""
