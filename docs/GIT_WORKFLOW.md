# GIT_WORKFLOW.md

**Monorepo Template — Official Git Workflow (HUMANS + AGENTS)**
**This is the master document. Every agent and human must follow it exactly.**

This workflow is designed for hybrid development, where multiple AI agents and humans work in parallel, each inside isolated Git worktrees.
Nothing in this file is optional.

---

# 📁 1. Monorepo Structure (Always)

```
{project}-monorepo/
│
├── backlog/
│   └── TASKS.md               ← task tracking for sessions
│
├── docs/
│   └── GIT_WORKFLOW.md        ← this file
│
├── scripts/
│   ├── init-workspace.sh      ← initialize full workspace
│   ├── new-feature.sh         ← create feature worktree
│   ├── nuke-feature.sh        ← safely remove feature worktree
│   └── verify-worktrees.sh    ← validate worktree health
│
├── {project}/                 ← main branch worktree (production root)
│   └── CLAUDE.md              ← agent instructions (auto-generated)
│
├── {project}-dev/             ← DEV environment (base for all feature worktrees)
│   ├── dev/                   ← the dev branch checkout
│   ├── dev-agent-*/           ← agent feature worktrees
│   └── dev-human-*/           ← human feature worktrees
│
└── {project}-staging/         ← staging branch worktree
```

**Note:** Replace `{project}` with your actual project name. Scripts auto-detect this from the folder name.

---

# 🌲 2. Branch Naming Rules (MANDATORY)

Every branch must follow the standard Git convention:

```
<type>/<owner>/<feature-name>
```

Where:

* **type** = `feature` (standard) or `hotfix` (rare, human-only)
* **owner** = `agent` or `human`
* **feature-name** = kebab-case name of the feature

### ✅ Good Examples

```
feature/agent/langwatch-integration
feature/human/payment-ui-fix
feature/agent/agent-card-qr
feature/human/share-system-v2
hotfix/human/critical-login-bug
```

### ❌ Bad Examples

```
dev/agent/stuff          ← Do not use environment names as type
agent/fix-login          ← Missing type prefix
feature/login-page       ← Missing owner segment
```

---

# 📂 3. Worktree Folder Naming Rules

Folders represent the **PHYSICAL LOCATION** of the work.
They use the environment prefix to indicate where they live.

```
<environment>-<owner>-<feature-name>
```

### Branch → Folder Mapping

| Branch | Folder |
|--------|--------|
| `feature/agent/qr-card` | `dev-agent-qr-card` |
| `feature/human/payment-fix` | `dev-human-payment-fix` |
| `feature/agent/langwatch` | `dev-agent-langwatch` |

### Why Different Prefixes?

* **Branch** uses `feature/` → describes **WHAT** type of work
* **Folder** uses `dev-` → describes **WHERE** it physically lives

These folders live **inside speakit-dev/** only.

---

# 🧠 4. Who Creates Feature Branches?

* **Humans** create branches for humans.
* **new-feature.sh** creates branches for agents.
* Agents must **never** create branches manually.

---

# 🚀 5. Workspace Initialization (First-Time Setup)

When setting up the monorepo for the first time, run:

```
./scripts/init-workspace.sh <git-repo-url>
```

This will:

1. Clone the repository into `speakit/` (main branch)
2. Create `speakit-dev/dev/` worktree (dev branch)
3. Create `speakit-staging/` worktree (staging branch)
4. Set up proper Git worktree links

**Run this only once per machine.**

---

# 🔍 6. Workspace Verification (Health Check)

To verify your workspace is correctly configured, run:

```
./scripts/verify-worktrees.sh
```

This checks:

* All required directories exist
* All worktrees are properly linked
* No orphan folders in speakit-dev/
* All branches referenced by worktrees exist

**Run this when:**
* Something feels broken
* After pulling major changes
* Before onboarding a new team member

---

# 🎋 7. Feature Creation (Always via Script)

From:

```
~/Documents/dev/speakit-monorepo/
```

Run:

```
./scripts/new-feature.sh agent <feature-name>
./scripts/new-feature.sh human <feature-name>
```

This will:

1. create the correct branch name
2. create the matching worktree
3. copy `.env.local`
4. prepare the folder for safe agent work

---

# 🧨 8. Feature Deletion (Safe Cleanup)

From:

```
~/Documents/dev/speakit-monorepo/
```

Run:

```
./scripts/nuke-feature.sh <folder-name>
```

This removes:

* the worktree
* the folder
* the branch
* cleans Git worktree metadata

Agents must **never** delete manually.

---

# 🔄 9. Syncing Rules (Agents + Humans)

### MUST sync before first commit of each session:

```
cd dev/  (inside speakit-dev)
git pull origin dev
```

Agents do not guess. They always sync at the start.

### Agents MAY NOT merge or rebase manually.

They can:

* allow Git to auto-resolve trivial merges
* must stop if merge markers appear (`<<<<<<`)

Humans handle all non-trivial conflicts.

---

# 🚑 10. Hotfix Strategy (Critical)

Hotfixes created on `staging` **must** propagate back to dev.

Use this decision table:

### ✔ Small isolated fix (1–2 lines)

Cherry-pick from staging → dev.

### ✔ Fix touches files heavily modified in dev

Re-implement manually on dev.

### ✔ Conflict appears

Agent MUST STOP immediately.
Human resolves.

### ✔ Logic decision required

Human-only.

---

# 📬 11. Commit Message Rules (MANDATORY)

Agents must ALWAYS use this template:

```
<type>(<scope>): <short description>

<body – optional>
```

Where:

* **type** = feat, fix, chore, refactor, docs
* **scope** = feature-name or folder affected

### Examples

```
feat(agent-card-qr): add QR generation logic
fix(langwatch): prevent redacting safe-list words
refactor(audio): simplify chunk processor
```

Agents MUST NOT:

* create vague messages
* include emojis
* write long explanations

---

# 🧪 12. Testing Requirements

Before pushing any feature branch:

* Agents must run the test command they are instructed to run.
* If tests fail, the agent must stop and request human review.

---

# 🧵 13. Pull Request Rules

Feature branches follow the pipeline:

```
feature → dev → staging → main
```

### Agents must NOT create PRs to main or staging.

Only humans can.

### Agents may open PRs to dev.

Humans review everything.

---

# 🚫 14. Forbidden Actions (Agents)

Agents must NEVER:

* modify Git root folders (speakit, speakit-dev, speakit-staging)
* delete branches manually
* change remotes
* rebase interactively
* merge staging or main
* touch scripts in `/scripts/` folder
* touch this file (GIT_WORKFLOW.md)

Agents MUST stop immediately upon:

* merge conflicts
* dependency installation failures
* modified lock files that they did not create

---

# 📜 15. Required Headers Inside Scripts

All scripts in `/scripts/` MUST begin with:

```
# See GIT_WORKFLOW.md for rules and constraints.
```

This applies to:
* `init-workspace.sh`
* `new-feature.sh`
* `nuke-feature.sh`
* `verify-worktrees.sh`

This keeps agents aligned.

---

# 🌱 16. Environment Rules

### Features always start from:

```
dev branch → speakit-dev/
```

Agents may NOT:

* create feature branches from staging or main
* push commits directly to dev (only via PR)

---

# 🧰 17. Worktree Hygiene

### After finishing a feature:

Human merges PR → then runs:

```
./scripts/nuke-feature.sh <folder>
```

This ensures:

* no stale branches
* no orphan folders
* no Git metadata corruption

---

# 🛡 18. Safety Guarantees

This workflow guarantees:

* No feature pollutes another (full folder isolation)
* No agent can break dev accidentally
* Every feature is traceable by prefix
* Humans hold merge authority to staging/main
* Git never becomes corrupted by agent errors

---

# 🧭 19. Quick Reference Cheat Sheet

```
# Create feature
./scripts/new-feature.sh agent <name>
./scripts/new-feature.sh human <name>

# Delete feature
./scripts/nuke-feature.sh <folder>

# Verify workspace health
./scripts/verify-worktrees.sh

# Sync before work
cd speakit-dev/dev
git pull origin dev

# Commit format
feat(scope): short description
```

---

# 🧱 20. Philosophy

We assume:

* Agents work best in isolated folders
* Humans approve all high-level merges
* Agents must be deterministic
* Clear prefixing ensures traceability
* Scripts must enforce safety, not rely on memory

This workflow is the foundation for scaling multiple agents and humans working in parallel.

---

# ✅ END OF DOCUMENT — DO NOT MODIFY
