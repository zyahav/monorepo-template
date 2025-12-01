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

## 🤖 For AI Agents

1. Read `CLAUDE.md` in the project root
2. Follow `docs/GIT_WORKFLOW.md` rules
3. Use mysay for communication (if available)

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
