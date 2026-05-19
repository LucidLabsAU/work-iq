#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Sync the microsoft-365-agents-toolkit skill from the ATK source repo into the work-iq plugin.

.DESCRIPTION
  Copies bulk content (experts/, docs/, toolkit/, test-*, troubleshoot/, slack-to-teams/)
  from the ATK vscode-extension skill into the work-iq plugin, then re-injects DA redirect
  notices into conflict files. Skips SKILL.md (manually maintained).

  After syncing, records the source commit hash in sync-manifest.json for audit purposes.

.PARAMETER SourcePath
  Path to the ATK skill root:
  e.g. C:\path\to\microsoft-365-agents-toolkit\packages\vscode-extension\skills\microsoft-365-agents-toolkit

.PARAMETER TargetPath
  Path to the work-iq skill root (defaults to the standard relative location).

.PARAMETER DryRun
  Print what would be copied/updated without writing any files.

.EXAMPLE
  .\sync-atk-skill.ps1 -SourcePath "C:\repos\atk\packages\vscode-extension\skills\microsoft-365-agents-toolkit"
  .\sync-atk-skill.ps1 -SourcePath "..." -DryRun
#>
param(
  [Parameter(Mandatory)]
  [string]$SourcePath,

  [string]$TargetPath = (Join-Path $PSScriptRoot "..\plugins\microsoft-365-agents-toolkit\skills\teams-app-developer"),

  [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SourcePath = Resolve-Path $SourcePath
$TargetPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetPath)

Write-Host "Source : $SourcePath"
Write-Host "Target : $TargetPath"
if ($DryRun) { Write-Host "[DRY RUN] No files will be written.`n" -ForegroundColor Yellow }

# ── Directories to copy verbatim (overwrite) ──────────────────────────────────
$BulkDirs = @(
  "experts",
  "docs",
  "toolkit",
  "test-playground",
  "test-teams",
  "troubleshoot",
  "slack-to-teams"
)

$Changed = [System.Collections.Generic.List[string]]::new()

foreach ($dir in $BulkDirs) {
  $src = Join-Path $SourcePath $dir
  $tgt = Join-Path $TargetPath $dir
  if (-not (Test-Path $src)) {
    Write-Warning "Source directory not found, skipping: $src"
    continue
  }
  if ($DryRun) {
    $count = (Get-ChildItem $src -Recurse -File).Count
    Write-Host "  [WOULD COPY] $dir/ ($count files)"
  } else {
    Copy-Item -Path $src -Destination $tgt -Recurse -Force
    $count = (Get-ChildItem $tgt -Recurse -File).Count
    Write-Host "  [COPIED] $dir/ ($count files)"
  }
  $Changed.Add($dir)
}

# ── Files to copy then patch ───────────────────────────────────────────────────
$DA_CREATE_PROJECT_REDIRECT = @'

> **Creating a Declarative Agent?** Use the **`declarative-agent-developer`** skill instead — it
> provides deeper guidance on DA scaffolding, manifest authoring, capability configuration,
> API/MCP plugin setup, OAuth, localization, and deployment. The templates below include DA
> options for reference, but the `declarative-agent-developer` skill owns that workflow end-to-end.

'@

$DA_PROVISION_REDIRECT = @'

> **Declarative Agent deployment?** After provisioning, you need a test link to verify your DA in
> M365 Copilot. That post-deploy review UX (reading `M365_TITLE_ID` and presenting the test URL)
> is owned by the **`declarative-agent-developer`** skill — use that skill for all DA end-to-end
> workflows. This document covers the `atk provision / atk deploy` commands shared by all project
> types (DA, CEA, bot, tab, message extension).
'@

function Patch-DARedirect {
  param([string]$FilePath, [string]$Marker, [string]$Redirect)
  $content = Get-Content $FilePath -Raw -Encoding UTF8
  if ($content -match [regex]::Escape($Redirect.Trim())) {
    Write-Host "  [SKIP PATCH] Redirect already present: $FilePath"
    return
  }
  $patched = $content -replace [regex]::Escape($Marker), "$Marker`n$Redirect"
  if (-not $DryRun) {
    Set-Content $FilePath $patched -Encoding UTF8 -NoNewline
    Write-Host "  [PATCHED] $FilePath"
  } else {
    Write-Host "  [WOULD PATCH] $FilePath"
  }
}

# create-project
$cpSrc = Join-Path $SourcePath "create-project"
$cpTgt = Join-Path $TargetPath "create-project"
if (Test-Path $cpSrc) {
  if (-not $DryRun) {
    Copy-Item -Path $cpSrc -Destination $cpTgt -Recurse -Force
  }
  $cpFile = Join-Path $cpTgt "create-project.md"
  if (Test-Path $cpFile) {
    Patch-DARedirect -FilePath $cpFile `
      -Marker "## Template Selection Guide" `
      -Redirect $DA_CREATE_PROJECT_REDIRECT
  }
  $Changed.Add("create-project")
}

# provision-deploy
$pdSrc = Join-Path $SourcePath "provision-deploy"
$pdTgt = Join-Path $TargetPath "provision-deploy"
if (Test-Path $pdSrc) {
  if (-not $DryRun) {
    Copy-Item -Path $pdSrc -Destination $pdTgt -Recurse -Force
  }
  $pdFile = Join-Path $pdTgt "provision-deploy.md"
  if (Test-Path $pdFile) {
    Patch-DARedirect -FilePath $pdFile `
      -Marker "Provision Azure and M365 resources, then deploy your agent to the cloud." `
      -Redirect $DA_PROVISION_REDIRECT
  }
  $Changed.Add("provision-deploy")
}

# ── SKILL.md: skip (manually maintained) ──────────────────────────────────────
Write-Host "`n  [SKIPPED] SKILL.md (manually maintained — update by hand after reviewing source changes)"

# ── Record sync manifest ───────────────────────────────────────────────────────
$manifestPath = Join-Path $PSScriptRoot "sync-manifest.json"

# Try to get git commit of source
$sourceCommit = "unknown"
try {
  $gitOutput = & git -C $SourcePath log -1 --format="%H" 2>&1
  if ($LASTEXITCODE -eq 0) { $sourceCommit = $gitOutput.Trim() }
} catch { }

$manifest = [ordered]@{
  last_sync           = (Get-Date -Format "yyyy-MM-dd")
  source_path         = $SourcePath.ToString()
  source_commit       = $sourceCommit
  manually_maintained = @("SKILL.md")
  da_redirect_injected = @("create-project/create-project.md", "provision-deploy/provision-deploy.md")
  synced_dirs         = $Changed.ToArray()
}

if (-not $DryRun) {
  $manifest | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8
  Write-Host "`n  [WRITTEN] sync-manifest.json (source commit: $sourceCommit)"
} else {
  Write-Host "`n  [WOULD WRITE] sync-manifest.json (source commit: $sourceCommit)"
}

Write-Host "`nSync complete.`n"
