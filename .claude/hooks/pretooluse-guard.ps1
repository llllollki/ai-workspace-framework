# PreToolUse guard for Bash commands.
# Exit 2 = BLOCK (stderr is shown to the agent). Exit 0 = allow / defer to permissions.
# This is the real enforcement point for destructive ops. It is defense-in-depth, not complete:
# the human-owned backstops in ai-context\global\enforcement_design.md must also be configured.

$ErrorActionPreference = 'Stop'
$projectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { 'c:\Projects' }

function Block([string]$msg) {
  [Console]::Error.WriteLine("BLOCKED by pretooluse-guard: $msg")
  exit 2
}

try {
  $raw = [Console]::In.ReadToEnd()
  if (-not $raw) { exit 0 }
  $payload = $raw | ConvertFrom-Json
} catch {
  # Could not parse hook input: do not break normal tool flow.
  exit 0
}

if ($payload.tool_name -ne 'Bash') { exit 0 }
$cmd = [string]$payload.tool_input.command
if (-not $cmd) { exit 0 }
$c = $cmd.ToLowerInvariant()

# --- NEVER-AUTONOMOUS (no allow entry can grant these) ---
$never = @(
  'git push --force',
  'git push -f',
  'drop table',
  'truncate',
  'disable row level security',
  'drop policy',
  'supabase db reset',
  'rm -rf'
)
foreach ($p in $never) {
  if ($c.Contains($p)) {
    Block "'$p' is on the never-autonomous list. Requires human action (needs input)."
  }
}

# --- GATED (require a matching, active allow-list entry) ---
# op_class -> substrings that identify it
$gated = @{
  'deploy'       = @('vercel deploy', 'vercel --prod', 'vercel deploy --prod', 'npm run deploy')
  'db_migration' = @('supabase db push', 'supabase migration up')
  'force_push'   = @('git push')   # plain push is gated; --force already blocked above
  'secret_change'= @('supabase secrets set', 'vercel env add')
}

$matchedClass = $null
foreach ($class in $gated.Keys) {
  foreach ($sub in $gated[$class]) {
    if ($c.Contains($sub)) { $matchedClass = $class; break }
  }
  if ($matchedClass) { break }
}
if (-not $matchedClass) { exit 0 }   # not a gated op -> defer to permissions

# Detect target env from the command (best-effort); default to production for safety.
$targetEnv = 'production'
if ($c -match 'preview') { $targetEnv = 'preview' }
elseif ($c -match 'staging') { $targetEnv = 'staging' }
elseif ($c -match '--prod|production') { $targetEnv = 'production' }
elseif ($matchedClass -eq 'force_push') { $targetEnv = 'production' }

# Load allow-list.
$allowPath = Join-Path $projectDir '.claude\allow-list.json'
$entries = @()
if (Test-Path $allowPath) {
  try {
    $rawAllow = Get-Content $allowPath -Raw
    if ($rawAllow) { $rawAllow = $rawAllow.TrimStart([char]0xFEFF) }  # tolerate UTF-8 BOM
    $entries = @($rawAllow | ConvertFrom-Json)
  } catch { $entries = @() }
}

$today = Get-Date
$match = $entries | Where-Object {
  $_.op_class -eq $matchedClass -and
  $_.target_env -eq $targetEnv -and
  ( $_.grant -eq 'standing' -or $_.grant -eq 'once' )
} | Where-Object {
  # production-targeted ops must not be 'standing' and must have a future expiry
  if ($targetEnv -eq 'production') {
    if ($_.grant -eq 'standing') { return $false }
    if (-not $_.expires) { return $false }
    try { return ([datetime]$_.expires -ge $today) } catch { return $false }
  }
  return $true
} | Select-Object -First 1

if (-not $match) {
  Block "op_class='$matchedClass' target_env='$targetEnv' has no active allow-list entry in .claude\allow-list.json. Add a scoped entry or escalate (needs input)."
}

# Authorized: write an append-only audit line, then allow.
try {
  $audit = [pscustomobject]@{
    ts         = (Get-Date).ToString('o')
    op_class   = $matchedClass
    target_env = $targetEnv
    allow_note = $match.note
    task_id    = $match.task_id
    grant      = $match.grant
    command    = $cmd
  } | ConvertTo-Json -Compress
  Add-Content -Path (Join-Path $projectDir '.claude\audit-log.jsonl') -Value $audit
} catch {
  Block "could not write audit entry; refusing the op per enforcement_design.md."
}

exit 0
