#!/bin/bash

# ===============================================
# utils.sh
# SHARED UTILITIES FOR ALL SCRIPTS
# Source this file: source "$(dirname "$0")/utils.sh"
# ===============================================

# --- Detect Project Name ---
# Robust script directory detection (Bash + Zsh)
if [ -n "$BASH_SOURCE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "$ZSH_VERSION" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi

MONOREPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# 1. Priority: .project_name file (Overrides everything)
if [ -f "$MONOREPO_DIR/.project_name" ]; then
  PROJECT_NAME=$(cat "$MONOREPO_DIR/.project_name" | tr -d '\n')
# 2. Priority: Existing Env Var
elif [ -n "$PROJECT_NAME" ]; then
  : # Keep existing PROJECT_NAME
# 3. Priority: .env file
elif [ -f "$MONOREPO_DIR/.env" ] && grep -q "PROJECT_NAME=" "$MONOREPO_DIR/.env"; then
  PROJECT_NAME=$(grep "PROJECT_NAME=" "$MONOREPO_DIR/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
# 4. Fallback: Directory name
else
  MONOREPO_NAME=$(basename "$MONOREPO_DIR")
  if [[ "$MONOREPO_NAME" == *-monorepo ]]; then
    PROJECT_NAME="${MONOREPO_NAME%-monorepo}"
  else
    PROJECT_NAME="$MONOREPO_NAME"
  fi
fi

# --- mysay Wrapper Functions ---
# Always include project name so you know which project is talking

say_done() {
  if command -v mysay &>/dev/null; then
    mysay --done "Project $PROJECT_NAME: $1"
  fi
}

say_start() {
  if command -v mysay &>/dev/null; then
    mysay --start "Project $PROJECT_NAME: $1"
  fi
}

say_error() {
  if command -v mysay &>/dev/null; then
    mysay --error "Project $PROJECT_NAME: $1"
  fi
}

say_question() {
  if command -v mysay &>/dev/null; then
    mysay --question -w "Project $PROJECT_NAME: $1"
  fi
}

say_idea() {
  if command -v mysay &>/dev/null; then
    mysay --idea "Project $PROJECT_NAME: $1"
  fi
}

say_hi() {
  if command -v mysay &>/dev/null; then
    mysay --hi "Project $PROJECT_NAME: $1"
  fi
}
