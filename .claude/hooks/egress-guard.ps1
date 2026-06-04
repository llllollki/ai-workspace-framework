# PreToolUse egress guard for WebFetch.
# Blocks (exit 2) any fetch whose host is not in .claude/egress-allowlist.txt (domain + subdomains).
# Raw network CLI (curl/wget/iwr/irm/nc/scp/rsync) is denied separately in settings.json.
# Defense against data exfiltration; resident/PII data must never be sent outbound regardless.

$ErrorActionPreference = 'Stop'
$projectDir = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { 'c:\Projects' }

function Block([string]$msg) {
  [Console]::Error.WriteLine("BLOCKED by egress-guard: $msg")
  exit 2
}

try {
  $raw = [Console]::In.ReadToEnd()
  if (-not $raw) { exit 0 }
  $payload = $raw | ConvertFrom-Json
} catch {
  exit 0   # unparseable hook input: do not break normal flow
}

if ($payload.tool_name -ne 'WebFetch') { exit 0 }
$url = [string]$payload.tool_input.url
if (-not $url) { exit 0 }

try { $target = ([uri]$url).Host.ToLowerInvariant() } catch { Block "unparseable URL: $url" }
if (-not $target) { Block "no host in URL: $url" }

$allowPath = Join-Path $projectDir '.claude\egress-allowlist.txt'
$allowed = @()
if (Test-Path $allowPath) {
  $allowed = Get-Content $allowPath |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }
}

$ok = $false
foreach ($d in $allowed) {
  $d = $d.ToLowerInvariant()
  if ($target -eq $d -or $target.EndsWith('.' + $d)) { $ok = $true; break }
}

if (-not $ok) {
  Block "egress to '$target' is not in .claude\egress-allowlist.txt. Add the domain there if it is a trusted documentation source, or avoid the request. Resident/PII data must never leave the workspace."
}

exit 0
