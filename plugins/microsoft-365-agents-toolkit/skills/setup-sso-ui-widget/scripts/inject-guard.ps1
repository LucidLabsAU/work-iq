# Phase 7a — Add jose to the MCP server and write the auth guard from references/auth.ts.
# (7b — inserting the guard into the /mcp handler — is a code edit the model performs; see
#  wire-and-guard.md. This script only does the mechanical, deterministic part.)
. "$PSScriptRoot/_lib.ps1"

$McpServerDir = Get-McpServerDir
if (-not $McpServerDir) { Fail "McpServerDir not found — run detect-project.ps1 first." }

# jose (idempotent).
npm --prefix $McpServerDir install jose@^5 --save
if ($LASTEXITCODE -ne 0) { Fail "npm install jose failed in $McpServerDir." }

# Copy the hardened guard (single-tenant; scp + tenant + app-only checks) into the server.
$srcDir  = if (Test-Path (Join-Path $McpServerDir "src")) { Join-Path $McpServerDir "src" } else { $McpServerDir }
$destAuth = Join-Path $srcDir "auth.ts"
$srcAuth  = Join-Path $PSScriptRoot "../references/auth.ts"
Copy-Item -Path $srcAuth -Destination $destAuth -Force
Write-Host "Wrote $destAuth OK (from references/auth.ts)" -ForegroundColor Green
Write-Host "Next: insert the guard into the /mcp POST handler + add Authorization to CORS (see wire-and-guard.md 7b/7c)."
