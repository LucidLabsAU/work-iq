# Phase 0 — Workspace Check. Detects a ui-widget-developer project and stops if it isn't one.
. "$PSScriptRoot/_lib.ps1"

$AppPackageDir = Get-AppPackageDir
$hasAtk        = (Test-Path "m365agents.yml") -or (Test-Path "teamsapp.yml")
$mcpPluginPath = if ($AppPackageDir) { Join-Path $AppPackageDir "mcpPlugin.json" } else { $null }
$hasMcpPlugin  = $mcpPluginPath -and (Test-Path $mcpPluginPath)
$hasAiPlugin   = $AppPackageDir -and (Test-Path (Join-Path $AppPackageDir "ai-plugin.json"))
$McpServerDir  = Get-McpServerDir

Write-Host "AppPackageDir=$AppPackageDir hasAtk=$hasAtk hasMcpPlugin=$hasMcpPlugin hasAiPlugin=$hasAiPlugin McpServerDir=$McpServerDir"

if (-not ($hasAtk -and $AppPackageDir -and $hasMcpPlugin -and $McpServerDir)) {
    Write-Host "This does not look like a ui-widget-developer project." -ForegroundColor Red
    Write-Host "Expected: m365agents.yml + $AppPackageDir/mcpPlugin.json + an MCP server folder with @modelcontextprotocol/sdk." -ForegroundColor Red
    if ($hasAiPlugin -and -not $hasMcpPlugin) {
        Write-Host "Found ai-plugin.json instead of mcpPlugin.json — this skill is for the mcpPlugin.json (OAI Apps) layout." -ForegroundColor Yellow
    }
    Fail "Build the agent first with the ui-widget-developer skill (OAI Apps path), then re-run this skill."
}
Write-Host "ui-widget-developer project detected OK  (server: $McpServerDir)" -ForegroundColor Green
