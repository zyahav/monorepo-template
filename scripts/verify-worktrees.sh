#!/bin/bash

# ===============================================
# verify-worktrees.sh
# VALIDATES THE MONOREPO WORKTREE SETUP
# See GIT_WORKFLOW.md for full rules
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

# --- Define paths ---
MAIN_REPO="$MONOREPO_DIR/$PROJECT_NAME"
DEV_ROOT="$MONOREPO_DIR/${PROJECT_NAME}-dev"
STAGING_ROOT="$MONOREPO_DIR/${PROJECT_NAME}-staging"
BASE_DEV_WORKTREE="$DEV_ROOT/dev"

echo "🔍 Verifying Monorepo Worktrees..."
echo "   Project: $PROJECT_NAME"
echo "   Root: $MONOREPO_DIR"
echo

# ===============================================
# 1. VERIFY REQUIRED FOLDERS EXIST
# ===============================================

echo "📁 Checking required directories..."

MISSING=0

for folder in "$MAIN_REPO" "$DEV_ROOT" "$STAGING_ROOT"; do
    if [ ! -d "$folder" ]; then
        echo "❌ Missing required folder: $folder"
        MISSING=1
    else
        echo "✅ Found: $folder"
    fi
done

if [ $MISSING -eq 1 ]; then
  echo
  echo "❌ Environment is incomplete. Run init-workspace.sh first."
  exit 1
fi

echo

# ===============================================
# 2. VERIFY BASE DEV WORKTREE EXISTS
# ===============================================

echo "🧱 Checking base dev worktree..."

if [ ! -e "$BASE_DEV_WORKTREE/.git" ]; then
    echo "❌ ERROR: Base dev worktree is missing or invalid:"
    echo "   $BASE_DEV_WORKTREE"
    echo "   (Run: ./scripts/init-workspace.sh)"
    exit 1
fi

echo "✅ Base dev worktree OK"
echo

# ===============================================
# 3. GIT CONTEXT
# ===============================================

cd "$BASE_DEV_WORKTREE" || exit

echo "🔗 Reading git worktree list..."
echo

WORKTREE_OUTPUT=$(git worktree list)
echo "$WORKTREE_OUTPUT"
echo

# ===============================================
# 4. VALIDATE WORKTREE → FOLDER (PATHS EXIST)
# ===============================================

echo "🧩 Checking worktree paths..."

BROKEN_PATHS=0

while read -r line; do
    [ -z "$line" ] && continue
    
    WT_PATH=$(echo "$line" | awk '{print $1}')
    if [ ! -d "$WT_PATH" ]; then
        echo "❌ BROKEN: Worktree path does not exist → $WT_PATH"
        BROKEN_PATHS=1
    else
        echo "✅ Exists: $WT_PATH"
    fi
done <<< "$WORKTREE_OUTPUT"

echo

# ===============================================
# 5. VALIDATE FOLDER → WORKTREE (NO ORPHAN FOLDERS)
# ===============================================

echo "🗃️  Checking for orphan folders inside ${PROJECT_NAME}-dev..."

ORPHANS=0

for folder in "$DEV_ROOT"/*; do
    [ ! -d "$folder" ] && continue
    name=$(basename "$folder")

    # Skip the base dev folder
    if [[ "$name" == "dev" ]]; then
        continue
    fi

    # Check if folder is in the worktree list
    if ! echo "$WORKTREE_OUTPUT" | grep -q "$folder"; then
        echo "⚠️  Orphan folder (no matching worktree): $name"
        ORPHANS=1
    fi
done

echo

# ===============================================
# 6. VALIDATE WORKTREE → BRANCH (BRANCH EXISTS)
# ===============================================

echo "🌿 Checking that all worktrees have valid branches..."

BRANCH_ERRORS=0

while read -r line; do
    [ -z "$line" ] && continue

    WT_BRANCH=$(echo "$line" | awk '{print $3}' | sed 's/\[//;s/\]//')
    
    if [[ "$WT_BRANCH" == "(detached" ]]; then
         echo "⚠️  Worktree in Detached HEAD state: $line"
         continue
    fi

    if ! git show-ref --verify --quiet "refs/heads/$WT_BRANCH"; then
        echo "❌ Worktree references missing branch: $WT_BRANCH"
        BRANCH_ERRORS=1
    else
        echo "✅ Branch OK: $WT_BRANCH"
    fi
done <<< "$WORKTREE_OUTPUT"

echo

# ===============================================
# 7. FINAL SUMMARY
# ===============================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

if [[ $BROKEN_PATHS -eq 0 ]]; then
  echo "✔️  All worktree paths exist"
else
  echo "❌ Some worktree paths are broken"
fi

if [[ $ORPHANS -eq 0 ]]; then
  echo "✔️  No orphaned folders"
else
  echo "⚠️  Found orphan folders in ${PROJECT_NAME}-dev/"
fi

if [[ $BRANCH_ERRORS -eq 0 ]]; then
  echo "✔️  All branches linked to worktrees are valid"
else
  echo "❌ Some worktrees reference non-existent branches"
fi

echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [[ $BROKEN_PATHS -eq 0 && $ORPHANS -eq 0 && $BRANCH_ERRORS -eq 0 ]]; then
    echo "🎉 All worktrees are healthy!"
    exit 0
else
    echo "⚠️  Issues detected. Review output above."
    exit 1
fi
