# Monorepo Development Template

**A professional Git worktree-based development workflow for hybrid human/AI teams.**

---

## 🎯 What Is This?

A reusable template for managing projects where multiple AI agents and humans work in parallel. It provides:

- **Isolated workspaces** — Each feature branch gets its own folder
- **Safe automation** — Scripts prevent common Git mistakes
- **Clear ownership** — Every branch shows who (agent/human) owns it
- **Agent communication** — Optional mysay integration for voice + Telegram

---

## 🚀 Quick Start

### 1. Create your monorepo folder

```bash
mkdir myproject-monorepo
cd myproject-monorepo
```

### 2. Copy template files

Copy these folders into your monorepo:
- `backlog/`
- `docs/`
- `scripts/`

### 3. Initialize workspace

```bash
./scripts/init-workspace.sh https://github.com/you/myproject.git
```

This will:
- Check/install mysay (optional)
- Clone your repo
- Create dev and staging worktrees
- Generate CLAUDE.md for agents

---

## 📁 Structure After Init

```
myproject-monorepo/
├── backlog/TASKS.md           ← Task tracking
├── docs/GIT_WORKFLOW.md       ← Workflow rules
├── scripts/                   ← Automation
├── myproject/                 ← main branch
├── myproject-dev/
│   └── dev/                   ← dev branch
└── myproject-staging/         ← staging branch
```

---

## 🔧 Scripts

| Script | Purpose |
|--------|---------|
| `init-workspace.sh` | First-time setup |
| `new-feature.sh` | Create feature branch + worktree |
| `nuke-feature.sh` | Safely delete feature |
| `verify-worktrees.sh` | Health check |

---

## 📖 Documentation

- **[GIT_WORKFLOW.md](docs/GIT_WORKFLOW.md)** — Complete workflow rules
- **[TASKS.md](backlog/TASKS.md)** — Current task backlog

---

## 🤖 For AI Agents (CRITICAL READ)

**STOP AND READ THIS BEFORE DOING ANYTHING ELSE.**

1. **📖 Read the Rules**: You MUST read `docs/GIT_WORKFLOW.md`. It contains the **MANDATORY** Git Worktree workflow.
2. **🗣️ Communication**: You MUST source `scripts/utils.sh` and use the wrapper functions (`say_start`, `say_done`) for all updates.
3. **🧠 Context Awareness**: Check your `pwd`.
    - Are you in the **Root** (`.../monorepo/`)? -> Edit docs/scripts here.
    - Are you in a **Worktree** (`.../dev-agent-.../`)? -> Edit code here.
4. **🚫 No Manual Git**: NEVER create branches manually. Use `./scripts/new-feature.sh`.

---

## 📡 Communication (mysay)

If mysay is installed, agents can:

```bash
mysay --done "Task completed"           # Voice + Telegram
mysay --question -w "Should I continue?" # Wait for reply
mysay --error "Found a problem"
```

---

## License

MIT
