# Monorepo Template — Task Backlog

**Last Updated:** December 1, 2025  
**Status:** ✅ READY FOR TESTING

---

## ✅ All Development Tasks Completed

| # | Task | Date |
|---|------|------|
| 1 | Fix script path detection (all 4 scripts) | Dec 1, 2025 |
| 2 | Update GIT_WORKFLOW.md structure diagram | Dec 1, 2025 |
| 3 | Update GIT_WORKFLOW.md command examples | Dec 1, 2025 |
| 4 | Document branch naming convention (`feature/owner/name`) | Dec 1, 2025 |
| 5 | Document folder naming convention (`env-owner-name`) | Dec 1, 2025 |
| 6 | Document `init-workspace.sh` in GIT_WORKFLOW.md | Dec 1, 2025 |
| 7 | Document `verify-worktrees.sh` in GIT_WORKFLOW.md | Dec 1, 2025 |
| 8 | Rename branch to `feature/agent/agent-card-qr` | Dec 1, 2025 |
| 9 | Rename folder to `dev-agent-agent-card-qr` | Dec 1, 2025 |
| 10 | Update Section 15 (all 4 scripts listed) | Dec 1, 2025 |
| 11 | Update scripts to auto-detect project name | Dec 1, 2025 |
| 12 | Update GIT_WORKFLOW.md to use `{project}` placeholders | Dec 1, 2025 |
| 13 | Add mysay detection + optional install to init-workspace.sh | Dec 1, 2025 |
| 14 | Create CLAUDE.md template (generated during init) | Dec 1, 2025 |
| 15 | Add root README.md | Dec 1, 2025 |
| 16 | Add GitHub CLI (gh) auth check to init-workspace.sh | Dec 1, 2025 |
| 17 | Add NEW repo creation option (private by default) | Dec 1, 2025 |
| 18 | Add repo creation rules to CLAUDE.md template | Dec 1, 2025 |
| 19 | Add Section 2 (GitHub Rules) to GIT_WORKFLOW.md | Dec 1, 2025 |
| 20 | Renumber all GIT_WORKFLOW.md sections (now 21 total) | Dec 1, 2025 |
| 21 | Commit & push template to GitHub | Dec 1, 2025 |

---

## 🧪 NEXT: Test the Template

**Test location:** `/Users/zyahav/Documents/dev/agent-test-monorepo`

**Test steps:**
1. Create folder `agent-test-monorepo`
2. Copy template files (scripts/, docs/, backlog/)
3. Run `./scripts/init-workspace.sh`
4. Verify: gh auth check works
5. Verify: mysay detection works
6. Verify: NEW repo creation works (private)
7. Verify: Worktrees created correctly
8. Verify: CLAUDE.md generated correctly
9. Run `./scripts/verify-worktrees.sh`
10. Test `./scripts/new-feature.sh agent test-feature`

---

## 📋 What Was Built

### Template Repository
https://github.com/zyahav/monorepo-template

### Features
- Auto-detects project name from folder
- GitHub CLI (gh) integration
- Private repos by default
- mysay integration (optional)
- CLAUDE.md auto-generation
- 21-section workflow documentation

---

# END OF BACKLOG
