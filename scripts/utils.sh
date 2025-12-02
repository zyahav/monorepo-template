#!/bin/bash

# ===============================================
# utils.sh
# SHARED UTILITIES FOR ALL SCRIPTS
# Source this file: source "$(dirname "$0")/utils.sh"
# ===============================================

# --- Detect Project Name (if not already set) ---
if [ -z "$PROJECT_NAME" ]; then
  MONOREPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
