#Requires -Version 5.1
<#
.SYNOPSIS
    One-way sync from the canonical ai-workspace-framework to the device-local workspace mirror.

.DESCRIPTION
    Copies CLAUDE.md, AGENTS.md, and ai-context\ from FrameworkRoot to WorkspaceRoot.

    Default behavior is additive and update-only:
      - Identical files are skipped.
      - New files are copied.
      - Files that differ are warned about and skipped unless -Force is specified.
      - Destination files are never deleted.

    Never copies: .git, .claude, .env*, AssistedLivingHelp, node_modules, .next, dist, build, *.log
    Never deletes destination files.
    Never touches AssistedLivingHelp or .claude.

.PARAMETER FrameworkRoot
    Path to the canonical framework repo directory.
    Default: C:\Projects\ai-workspace-framework

.PARAMETER WorkspaceRoot
    Path to the device-local workspace root where the mirror lives.
    Default: C:\Projects

.PARAMETER Force
    Overwrite destination files that differ from the source without additional prompting.
    Without -Force, differing files are warned about and skipped.

.EXAMPLE
    # Dry run — see exactly what would be copied without making any changes.
    .\setup\sync_framework.ps1 -WhatIf

.EXAMPLE
    # Standard sync — copy new files; skip and warn about files that differ.
    .\setup\sync_framework.ps1

.EXAMPLE
    # Sync and overwrite all differing files.
    .\setup\sync_framework.ps1 -Force

.NOTES
    Sync is one-way: FrameworkRoot -> WorkspaceRoot.
    To propagate AI session changes back to the canonical repo, manually copy changed files
    from the workspace mirror into ai-workspace-framework\ and commit there.

    Path resolution and file hashing use .NET methods ([System.IO.Path]::GetFullPath,
    [System.Security.Cryptography.MD5]) rather than Resolve-Path and Get-FileHash, which
    are affected by PowerShell's WhatIf mode and return unexpected values in dry runs.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$FrameworkRoot = 'C:\Projects\ai-workspace-framework',
    [string]$WorkspaceRoot = 'C:\Projects',
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# $WhatIfPreference is non-zero (Continue=2) when -WhatIf is active.
$isWhatIf = [bool]$WhatIfPreference

# ─── Path resolution (.NET — immune to WhatIf mode) ────────────────────────────

$fw = [System.IO.Path]::GetFullPath($FrameworkRoot)
if (-not (Test-Path -LiteralPath $fw -PathType Container)) {
    Write-Error "FrameworkRoot not found or not a directory: '$fw'"
    exit 1
}

$ws = [System.IO.Path]::GetFullPath($WorkspaceRoot)
if (-not (Test-Path -LiteralPath $ws -PathType Container)) {
    Write-Error "WorkspaceRoot not found or not a directory: '$ws'"
    exit 1
}

# ─── Validation ─────────────────────────────────────────────────────────────────

if ($fw -eq $ws) {
    Write-Error "FrameworkRoot and WorkspaceRoot are the same path: '$fw'. Aborting."
    exit 1
}

# WorkspaceRoot must not be a subdirectory of FrameworkRoot (would create a recursive copy)
if ($ws.StartsWith($fw + '\', [StringComparison]::OrdinalIgnoreCase)) {
    Write-Error "WorkspaceRoot ('$ws') is inside FrameworkRoot ('$fw'). Aborting."
    exit 1
}

# Sanity check: FrameworkRoot must contain CLAUDE.md
if (-not (Test-Path -LiteralPath (Join-Path $fw 'CLAUDE.md'))) {
    Write-Error "CLAUDE.md not found in '$fw'. Verify -FrameworkRoot points to the correct directory."
    exit 1
}

# Protected paths — never a sync destination under any circumstance
$alhPath    = Join-Path $ws 'AssistedLivingHelp'
$claudePath = Join-Path $ws '.claude'

# ─── Header ─────────────────────────────────────────────────────────────────────

Write-Host ''
Write-Host ('=' * 62)
Write-Host '  sync_framework.ps1'
Write-Host ('=' * 62)
Write-Host "  Source (canonical):   $fw"
Write-Host "  Destination (mirror): $ws"
Write-Host "  -Force:               $([bool]$Force)"
Write-Host "  -WhatIf (dry run):    $isWhatIf"
Write-Host ('=' * 62)
Write-Host ''

# ─── MD5 hash helper (.NET — immune to WhatIf mode) ────────────────────────────

function Get-MD5Hash ([string]$Path) {
    $md5    = [System.Security.Cryptography.MD5]::Create()
    $stream = [System.IO.File]::OpenRead($Path)
    try   { $bytes = $md5.ComputeHash($stream) }
    finally { $stream.Dispose(); $md5.Dispose() }
    [System.BitConverter]::ToString($bytes).Replace('-', '')
}

# ─── Build file-pair list from allowlist ────────────────────────────────────────

# Only these three items are ever candidates for copying. All other contents of
# FrameworkRoot (README.md, .gitignore, setup\) stay in the canonical repo only.
$allowlist = @('CLAUDE.md', 'AGENTS.md', 'ai-context')

$pairs = [System.Collections.Generic.List[hashtable]]::new()

foreach ($item in $allowlist) {
    $srcPath = Join-Path $fw $item

    if (-not (Test-Path -LiteralPath $srcPath)) {
        Write-Warning "Source not found in framework, skipping: $srcPath"
        continue
    }

    if (Test-Path -LiteralPath $srcPath -PathType Container) {
        # Directory: expand to individual file pairs preserving relative structure
        Get-ChildItem -LiteralPath $srcPath -Recurse -File | ForEach-Object {
            $rel = $_.FullName.Substring($srcPath.Length).TrimStart('\')
            $pairs.Add(@{ Src = $_.FullName; Dst = Join-Path (Join-Path $ws $item) $rel })
        }
    } else {
        $pairs.Add(@{ Src = $srcPath; Dst = Join-Path $ws $item })
    }
}

# ─── Safety gate: validate all computed destinations before touching anything ────

foreach ($p in $pairs) {
    $d = $p.Dst
    if ($d.StartsWith($alhPath    + '\', [StringComparison]::OrdinalIgnoreCase) -or
        $d -eq $alhPath) {
        Write-Error "Computed destination '$d' is inside AssistedLivingHelp. Aborting."
        exit 1
    }
    if ($d.StartsWith($claudePath + '\', [StringComparison]::OrdinalIgnoreCase) -or
        $d -eq $claudePath) {
        Write-Error "Computed destination '$d' is inside .claude. Aborting."
        exit 1
    }
}

# ─── Sync ────────────────────────────────────────────────────────────────────────

$cntCopied   = 0
$cntSkipped  = 0
$cntDiffered = 0

foreach ($p in $pairs) {
    $src    = $p.Src
    $dst    = $p.Dst
    $dstDir = Split-Path $dst -Parent

    if (Test-Path -LiteralPath $dst) {
        $hSrc = Get-MD5Hash $src
        $hDst = Get-MD5Hash $dst

        if ($hSrc -eq $hDst) {
            Write-Host "  [SKIP  identical]    $dst"
            $cntSkipped++
            continue
        }

        # Destination exists but differs from source
        $cntDiffered++
        Write-Warning "  [DIFFER]             $dst"

        if (-not $Force) {
            Write-Warning "    Skipped. Run with -Force to overwrite."
            $cntSkipped++
            continue
        }

        # -Force: show intent, then overwrite via ShouldProcess (respects -WhatIf/-Confirm)
        Write-Host "  [OVERWRITE  -Force]  $dst"
        if ($PSCmdlet.ShouldProcess($dst, 'Overwrite (differs from source, -Force set)')) {
            if (-not (Test-Path -LiteralPath $dstDir)) {
                New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
            }
            Copy-Item -LiteralPath $src -Destination $dst -Force
            $cntCopied++
        }
        continue
    }

    # Destination does not exist — show intent, then copy via ShouldProcess
    Write-Host "  [COPY  new]          $dst"
    if ($PSCmdlet.ShouldProcess($dst, 'Copy new file')) {
        if (-not (Test-Path -LiteralPath $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }
        Copy-Item -LiteralPath $src -Destination $dst -Force
        $cntCopied++
    }
}

# ─── Summary ─────────────────────────────────────────────────────────────────────

Write-Host ''
Write-Host ('=' * 62)
if ($isWhatIf) {
    Write-Host '  DRY RUN COMPLETE -- no files were written.'
    Write-Host "  Identical (skipped):         $cntSkipped"
    Write-Host "  Differed (skipped):          $cntDiffered  (use -Force to overwrite)"
    Write-Host '  (New files and -Force overwrites appear as [COPY new] / [OVERWRITE]'
    Write-Host '   above; the actual copy is gated by -WhatIf and did not run.)'
} else {
    Write-Host '  Sync complete.'
    Write-Host "  Copied:   $cntCopied"
    Write-Host "  Skipped:  $cntSkipped  (identical or require -Force)"
    Write-Host "  Differed: $cntDiffered  (skipped; run with -Force to overwrite)"
}
Write-Host ('=' * 62)
Write-Host ''
