#!/bin/bash

# ===============================================
# nuke-feature.sh
# SAFE FEATURE DESTRUCTION SCRIPT
# See GIT_WORKFLOW.md for full workflow rules
# ===============================================

# --- Detect Monorepo Root & Project Name ---
MONOREPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MONOREPO_NAME=$(basename "$MONOREPO_DIR")

# Extract project name (remove -monorepo suffix if present)
if [[ "$MONOREPO_NAME" == *-monorepo ]]; then
  PROJECT_NAME="${MONOREPO_NAME%-monorepo}"
else
  PROJECT_NAME="$MONOREPO_NAME"
fi

# --- Validate argument ---
TARGET_FOLDER=$1

if [ -z "$TARGET_FOLDER" ]; then
  echo "❌ ERROR: Target folder name required."
  echo ""
  echo "Usage: ./scripts/nuke-feature.sh <folder-name>"
  echo ""
  echo "Example: ./scripts/nuke-feature.sh dev-agent-login"
  exit 1
fi

# --- Define paths ---
DEV_DIR="$MONOREPO_DIR/${PROJECT_NAME}-dev"
TARGET_PATH="$DEV_DIR/$TARGET_FOLDER"
GIT_ANCHOR="$DEV_DIR/dev"

# --- Safety: Protect core environment folders ---
PROTECTED_FOLDERS="dev staging main $PROJECT_NAME ${PROJECT_NAME}-dev ${PROJECT_NAME}-staging"
for protected in $PROTECTED_FOLDERS; do
  if [[ "$TARGET_FOLDER" == "$protected" ]]; then
    echo "⛔ CRITICAL ERROR: You cannot nuke a protected environment folder!"
    exit 1
  fi
done

# --- Safety: Folder must exist ---
if [ ! -d "$TARGET_PATH" ]; then
  echo "❌ ERROR: Folder does not exist: $TARGET_PATH"
  exit 1
fi

# --- Safety: Prevent deletion if user is inside folder ---
if [[ "$(pwd)" == *"$TARGET_FOLDER"* ]]; then
  echo "❌ ERROR: You are currently inside the folder you want to delete."
  echo "   Please 'cd ..' before running this script."
  exit 1
fi

# --- Ensure Git context exists ---
if [ ! -d "$GIT_ANCHOR" ]; then
    echo "❌ ERROR: Git anchor not found at: $GIT_ANCHOR"
    echo "   (Is the workspace initialized correctly?)"
    exit 1
fi

cd "$GIT_ANCHOR" || exit

# --- Detect Git worktree association ---
BRANCH_NAME=$(git worktree list | grep "${TARGET_FOLDER}$" | awk '{print $3}' | sed 's/\[//;s/\]//')

echo "🔥 Preparing to NUKE the feature worktree:"
echo "   Folder: $TARGET_PATH"
echo "   Branch: ${BRANCH_NAME:-UNKNOWN}"
echo

# --- Remove worktree ---
echo "🔌 Removing worktree connection..."
git worktree remove "$TARGET_PATH" --force

# --- Delete folder (fallback) ---
if [ -d "$TARGET_PATH" ]; then
  echo "🗑️  Cleaning up leftover files..."
  rm -rf "$TARGET_PATH"
else
  echo "✅ Folder already removed by Git."
fi

# --- Delete branch if detected ---
if [ -n "$BRANCH_NAME" ]; then
  echo "✂️  Deleting branch $BRANCH_NAME..."
  git branch -D "$BRANCH_NAME"
else
  echo "⚠️  Could not determine branch to delete."
  echo "   You may manually remove it: git branch -D feature/..."
fi

# --- Git cleanup ---
echo "🧹 Pruning Git metadata..."
git worktree prune

echo
echo "💀 Feature worktree destroyed successfully."

# Notify via mysay if available
if command -v mysay &>/dev/null; then
  mysay --done "Feature destroyed: $TARGET_FOLDER" &>/dev/null &
fi
