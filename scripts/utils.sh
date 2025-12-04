#!/bin/bash

# ===============================================
# utils.sh
# SHARED UTILITIES FOR ALL SCRIPTS
# Source this file: source "$(dirname "$0")/utils.sh"
# ===============================================

# --- Detect Project Name (if not already set) ---
if [ -z "$PROJECT_NAME" ]; then
  MONOREPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  
  # 1. Try reading from .project_name file in root
  if [ -f "$MONOREPO_DIR/.project_name" ]; then
    PROJECT_NAME=$(cat "$MONOREPO_DIR/.project_name" | tr -d '\n')
  # 2. Try reading from .env file
  elif [ -f "$MONOREPO_DIR/.env" ] && grep -q "PROJECT_NAME=" "$MONOREPO_DIR/.env"; then
    PROJECT_NAME=$(grep "PROJECT_NAME=" "$MONOREPO_DIR/.env" | cut -d '=' -f2 | tr -d '"' | tr -d "'")
  # 3. Fallback to directory name
  else
    MONOREPO_NAME=$(basename "$MONOREPO_DIR")
    if [[ "$MONOREPO_NAME" == *-monorepo ]]; then
      PROJECT_NAME="${MONOREPO_NAME%-monorepo}"
    else
      PROJECT_NAME="$MONOREPO_NAME"
    fi
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
