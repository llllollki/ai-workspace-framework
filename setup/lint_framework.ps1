# lint_framework.ps1 - structural consistency checks for the ai-context framework.
# Runs under Windows PowerShell 5.1. Exits 0 when clean, 1 with a per-finding report otherwise.
#
# Checks:
#   [REF]  Files referenced by skills_index.md, routing_rules.md, context_rules.md,
#          and ai-context\README.md must exist on disk.
#   [ID]   A task ID number must not appear on two files with different slugs within or
#          across tasks\active|backlog|done for the same project (ID collision).
#   [DUP]  The same ID+slug must not exist in two lifecycle dirs (stale lifecycle duplicate).
#   [SYNC] CLAUDE.md and AGENTS.md at the repo root must be byte-identical.
#
# Usage: powershell -File setup\lint_framework.ps1 [-RepoRoot <path>]

param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'Stop'
$aiContext = Join-Path $RepoRoot 'ai-context'
$findings = New-Object System.Collections.ArrayList

function Add-Finding {
    param([string]$Category, [string]$Message)
    [void]$findings.Add(('[{0}] {1}' -f $Category, $Message))
}

# ---------------------------------------------------------------------------
# [REF] referenced files must exist
# ---------------------------------------------------------------------------
$indexFiles = @(
    (Join-Path $aiContext 'skills\skills_index.md'),
    (Join-Path $aiContext 'orchestration\routing_rules.md'),
    (Join-Path $aiContext 'orchestration\context_rules.md'),
    (Join-Path $aiContext 'README.md')
)

foreach ($indexFile in $indexFiles) {
    if (-not (Test-Path $indexFile)) {
        Add-Finding 'REF' ('index file itself is missing: {0}' -f $indexFile)
        continue
    }
    $content = [System.IO.File]::ReadAllText($indexFile)
    $refMatches = [regex]::Matches($content, '`([^`\r\n]+?\.(?:md|ps1|json|jsonl|txt))`')
    $checked = @{}
    foreach ($m in $refMatches) {
        $ref = $m.Groups[1].Value
        # Skip placeholders, globs, and bare filenames without a path component.
        if ($ref -match '[<>*]') { continue }
        $ref = $ref -replace '/', '\'
        if ($ref -notmatch '\\') { continue }
        if ($checked.ContainsKey($ref)) { continue }
        $checked[$ref] = $true

        # A reference may be relative to the referencing file, the ai-context root,
        # the skills dir, the orchestration dir, or the repo root.
        $bases = @(
            (Split-Path -Parent $indexFile),
            $aiContext,
            (Join-Path $aiContext 'skills'),
            (Join-Path $aiContext 'orchestration'),
            $RepoRoot
        )
        $found = $false
        foreach ($base in $bases) {
            if (Test-Path (Join-Path $base $ref)) { $found = $true; break }
        }
        if (-not $found) {
            Add-Finding 'REF' ('{0} references missing file: {1}' -f (Split-Path -Leaf $indexFile), $ref)
        }
    }
}

# ---------------------------------------------------------------------------
# [ID]/[DUP] task ID collisions and lifecycle duplicates
# ---------------------------------------------------------------------------
$tasksRoot = Join-Path $aiContext 'tasks'
$lifecycles = @('active', 'backlog', 'done')
$taskRecords = @()

foreach ($lifecycle in $lifecycles) {
    $lifecycleDir = Join-Path $tasksRoot $lifecycle
    if (-not (Test-Path $lifecycleDir)) { continue }
    # Project dirs are discovered generically; any subdirectory is a project.
    foreach ($projectDir in (Get-ChildItem -Path $lifecycleDir -Directory)) {
        foreach ($file in (Get-ChildItem -Path $projectDir.FullName -File -Filter '*.md')) {
            if ($file.Name -eq 'README.md') { continue }
            if ($file.Name -match '^(\d{4})-(.+)\.md$') {
                $taskRecords += New-Object PSObject -Property @{
                    Project   = $projectDir.Name
                    Lifecycle = $lifecycle
                    Id        = $Matches[1]
                    Slug      = $Matches[2]
                    Path      = ('tasks\{0}\{1}\{2}' -f $lifecycle, $projectDir.Name, $file.Name)
                }
            }
        }
    }
}

# [ID] same project + ID, different slugs
$byProjectId = $taskRecords | Group-Object -Property { $_.Project + '|' + $_.Id }
foreach ($group in $byProjectId) {
    $slugs = $group.Group | Select-Object -ExpandProperty Slug -Unique
    if (@($slugs).Count -gt 1) {
        $paths = ($group.Group | Select-Object -ExpandProperty Path) -join '; '
        Add-Finding 'ID' ('ID collision {0}/{1}: {2}' -f $group.Group[0].Project, $group.Group[0].Id, $paths)
    }
}

# [DUP] same project + ID + slug in more than one lifecycle dir
$byProjectIdSlug = $taskRecords | Group-Object -Property { $_.Project + '|' + $_.Id + '|' + $_.Slug }
foreach ($group in $byProjectIdSlug) {
    if ($group.Count -gt 1) {
        $paths = ($group.Group | Select-Object -ExpandProperty Path) -join '; '
        Add-Finding 'DUP' ('lifecycle duplicate {0}/{1}-{2}: {3}' -f $group.Group[0].Project, $group.Group[0].Id, $group.Group[0].Slug, $paths)
    }
}

# ---------------------------------------------------------------------------
# [SYNC] CLAUDE.md and AGENTS.md must be byte-identical
# ---------------------------------------------------------------------------
$claudeMd = Join-Path $RepoRoot 'CLAUDE.md'
$agentsMd = Join-Path $RepoRoot 'AGENTS.md'
if (-not (Test-Path $claudeMd)) {
    Add-Finding 'SYNC' 'CLAUDE.md is missing at the repo root'
} elseif (-not (Test-Path $agentsMd)) {
    Add-Finding 'SYNC' 'AGENTS.md is missing at the repo root'
} else {
    $claudeHash = (Get-FileHash -Path $claudeMd -Algorithm SHA256).Hash
    $agentsHash = (Get-FileHash -Path $agentsMd -Algorithm SHA256).Hash
    if ($claudeHash -ne $agentsHash) {
        Add-Finding 'SYNC' 'CLAUDE.md and AGENTS.md are not byte-identical (they must carry the same agent-neutral content)'
    }
}

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
if ($findings.Count -gt 0) {
    Write-Output ('FRAMEWORK LINT: {0} finding(s)' -f $findings.Count)
    foreach ($f in $findings) { Write-Output ('  {0}' -f $f) }
    exit 1
} else {
    Write-Output 'FRAMEWORK LINT: OK (0 findings)'
    exit 0
}
