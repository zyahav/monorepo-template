#!/bin/bash

# ===============================================
# new-feature.sh
# SAFE FEATURE CREATION SCRIPT
# See GIT_WORKFLOW.md for full workflow rules
# ===============================================

# --- Source shared utilities ---
source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

# --- Detect Monorepo Root & Project Name ---
MONOREPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MONOREPO_NAME=$(basename "$MONOREPO_DIR")

# Extract project name (remove -monorepo suffix if present)
if [[ "$MONOREPO_NAME" == *-monorepo ]]; then
  PROJECT_NAME="${MONOREPO_NAME%-monorepo}"
else
  PROJECT_NAME="$MONOREPO_NAME"
fi

# Defaults
env="dev"   # only dev allowed currently
OWNER="human"

# --- Parse arguments ---
if [ -z "$1" ]; then
  echo "❌ ERROR: Feature name required"
  echo ""
  echo "Usage: ./scripts/new-feature.sh <feature-name> [--agent | --human]"
  echo ""
  echo "Examples:"
  echo "  ./scripts/new-feature.sh login-page --agent"
  echo "  ./scripts/new-feature.sh payment-fix --human"
  exit 1
fi

FEATURE_NAME=$1

# Check for flags in all arguments
for arg in "$@"; do
  if [[ "$arg" == "--agent" ]]; then OWNER="agent"; fi
  if [[ "$arg" == "--human" ]]; then OWNER="human"; fi
done

# Names
BRANCH_NAME="feature/${OWNER}/${FEATURE_NAME}"
FOLDER_NAME="${env}-${OWNER}-${FEATURE_NAME}"

# Dynamic paths based on project name
MAIN_REPO="$MONOREPO_DIR/$PROJECT_NAME"
DEV_DIR="$MONOREPO_DIR/${PROJECT_NAME}-dev"
BASE_DEV_WORKTREE="$DEV_DIR/dev"
TARGET_PATH="$DEV_DIR/$FOLDER_NAME"

# --- Summary ---
echo "🚀 Creating feature: $BRANCH_NAME"
echo "📁 Worktree folder: $TARGET_PATH"
echo

# Ensure base dev worktree exists
if [ ! -d "$BASE_DEV_WORKTREE" ]; then
  echo "❌ ERROR: Base dev worktree missing at:"
  echo "   $BASE_DEV_WORKTREE"
  echo "   (Did you run init-workspace.sh?)"
  exit 1
fi

# --- Create worktree + branch ---
cd "$BASE_DEV_WORKTREE" || exit

echo "🌱 Creating worktree and branch..."

# Check if branch already exists
if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1; then
    echo "⚠️  Branch $BRANCH_NAME already exists."
    echo "   Attaching worktree to existing branch..."
    git worktree add "$TARGET_PATH" "$BRANCH_NAME"
else
    git worktree add -b "$BRANCH_NAME" "$TARGET_PATH" dev
fi

# --- Copy env file ---
if [ -f "$MAIN_REPO/.env.local" ]; then
  echo "🧪 Copying .env.local ..."
  cp "$MAIN_REPO/.env.local" "$TARGET_PATH/.env.local"
else
  echo "⚠️  WARNING: No .env.local found in main repo"
fi

echo
echo "🎉 Feature created successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Branch:  $BRANCH_NAME"
echo "Folder:  $TARGET_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "👉 Next steps:"
echo "   cd $TARGET_PATH"
echo "   pnpm install"
echo "   Start coding!"
echo ""

# Notify via mysay
say_start "Feature $FEATURE_NAME created"
