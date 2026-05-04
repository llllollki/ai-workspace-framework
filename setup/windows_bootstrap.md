# Windows Bootstrap Guide

How to set up the AI context framework on a new Windows PC or laptop.

## Prerequisites

### 1. Install Git

Check if Git is already installed:

```powershell
git --version
```

If not installed, download from https://git-scm.com/download/win and install with defaults.

### 2. Check PowerShell execution policy

```powershell
Get-ExecutionPolicy -Scope CurrentUser
```

If the result is `Restricted`, allow local scripts with:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Use `-Scope CurrentUser` to avoid system-wide changes. Only change the policy if it is currently
`Restricted`.

### 3. Confirm workspace root exists

```powershell
Test-Path C:\Projects
```

If it does not exist, create it:

```powershell
New-Item -ItemType Directory -Path C:\Projects
```

---

## Clone the Framework Repo

Once a private Git remote has been set up (a separate step), clone it to the standard location:

```powershell
git clone <your-private-repo-url> C:\Projects\ai-workspace-framework
```

Replace `<your-private-repo-url>` with the actual private GitHub or other remote URL.

If you are setting up on a device before the remote exists (e.g., copying from another machine
manually), skip the clone step. The `ai-workspace-framework\` directory can be transferred by other
means.

---

## Run the Sync Script

Always run a dry run first and review the output before applying any changes.

```powershell
cd C:\Projects\ai-workspace-framework
.\setup\sync_framework.ps1 -WhatIf
```

Read every listed path. If anything looks unexpected, stop and investigate before continuing.

Apply the sync only after the dry run looks correct:

```powershell
.\setup\sync_framework.ps1
```

---

## Verify the Mirror

Confirm the device mirror files are in place:

```powershell
Test-Path C:\Projects\CLAUDE.md    # should return True
Test-Path C:\Projects\AGENTS.md   # should return True
Test-Path C:\Projects\ai-context   # should return True
```

---

## Day-to-Day Update Workflow

### Pulling framework updates made on another device

```powershell
cd C:\Projects\ai-workspace-framework
git pull
.\setup\sync_framework.ps1 -WhatIf   # review what changed
.\setup\sync_framework.ps1            # apply
```

### Committing framework changes from this device

After editing files in `ai-workspace-framework\`:

```powershell
cd C:\Projects\ai-workspace-framework
git add CLAUDE.md AGENTS.md ai-context/   # stage only framework content
git commit -m "describe what changed"
git push
```

Then sync to the device mirror and instruct the other device to pull and sync.

### Session changes written by AI

During Claude Code sessions, the AI writes to the device mirror (`C:\Projects\ai-context\`). After
a session, manually copy any framework-level changes you want to preserve into
`ai-workspace-framework\` before committing. The sync script runs in one direction only
(framework → mirror) and will not detect or propagate reverse changes automatically.

---

## Notes

- Run PowerShell as a normal user. Administrator rights are not required for any of these steps.
- Never edit `C:\Projects\CLAUDE.md`, `AGENTS.md`, or files in `C:\Projects\ai-context\` directly
  as a long-term workflow. The canonical location is `ai-workspace-framework\`.
- `C:\Projects\AssistedLivingHelp\` is a separate application repo. The sync script will never
  touch it, but do not copy it or add it to this framework repo either.
- `C:\Projects\.claude\` is Claude Code's local memory. It is machine-local, not synced, and must
  not be committed.
