# Device Setup Checklist

Use this checklist when setting up the AI context framework on any Windows device.

---

## Prerequisites

- [ ] Git is installed — `git --version` returns a version number
- [ ] PowerShell is available (Windows PowerShell 5.1 or later)
- [ ] Execution policy allows local scripts:
  ```powershell
  Get-ExecutionPolicy -Scope CurrentUser
  ```
  If result is `Restricted`, set it:
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
  ```
- [ ] `C:\Projects\` directory exists

---

## Framework Setup

- [ ] `C:\Projects\ai-workspace-framework\` exists
  - From remote (once configured): `git clone <url> C:\Projects\ai-workspace-framework`
  - Or transfer manually from another device if no remote is set up yet
- [ ] Run dry-run sync and review output:
  ```powershell
  cd C:\Projects\ai-workspace-framework
  .\setup\sync_framework.ps1 -WhatIf
  ```
- [ ] Dry-run output shows only expected paths — no surprises
- [ ] Run actual sync:
  ```powershell
  .\setup\sync_framework.ps1
  ```

---

## Verification

- [ ] Mirror files exist:
  ```powershell
  Test-Path C:\Projects\CLAUDE.md    # True
  Test-Path C:\Projects\AGENTS.md   # True
  Test-Path C:\Projects\ai-context   # True
  ```
- [ ] Claude Code workspace root is `C:\Projects\`
- [ ] `C:\Projects\CLAUDE.md` is readable from Claude Code
- [ ] `C:\Projects\AssistedLivingHelp\` is present and was not modified by sync
- [ ] `C:\Projects\.claude\` is present and was not modified by sync

---

## Day-to-Day Update Workflow

### Pulling framework updates from another device

- [ ] `git pull` in `C:\Projects\ai-workspace-framework\`
- [ ] `.\setup\sync_framework.ps1 -WhatIf` — review changes
- [ ] `.\setup\sync_framework.ps1` — apply

### Making framework changes on this device

- [ ] Edit files in `C:\Projects\ai-workspace-framework\` (not in the mirror directly)
- [ ] Commit from `C:\Projects\ai-workspace-framework\`
- [ ] Push to remote
- [ ] Run sync to apply to device mirror
- [ ] On other device: pull and run sync

### After an AI session (Claude Code writes to the mirror)

- [ ] Review what changed in `C:\Projects\ai-context\`
- [ ] Copy any framework-level changes into `C:\Projects\ai-workspace-framework\ai-context\`
- [ ] Commit and push from `ai-workspace-framework\`
- [ ] Sync on this device to confirm mirror matches canonical

---

## Reminders

- Never hand-edit `C:\Projects\CLAUDE.md`, `AGENTS.md`, or `ai-context\` as a regular workflow.
  The canonical source is `ai-workspace-framework\`.
- `AssistedLivingHelp\` is a separate app repo — never copy it here or modify it from this repo.
- `.claude\` is Claude Code's local memory — not synced, not committed.
