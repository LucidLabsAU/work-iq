# Shared helpers for the setup-sso-ui-widget scripts.
# Dot-source at the top of each script:  . "$PSScriptRoot/_lib.ps1"
# State is carried between scripts in env/.env.local (the project's ATK local env), so scripts are
# self-contained and take (almost) no arguments. Build-time-only values use an SSO_ prefix and are
# stripped by cleanup.ps1.

$script:EnvFile = "env/.env.local"

# --- Project layout (re-detected cheaply; nothing to persist) ---------------------------------
function Get-AppPackageDir {
    if (Test-Path "appPackage/declarativeAgent.json") { return "appPackage" }
    if (Test-Path "DeclarativeAgent/declarativeAgent.json") { return "DeclarativeAgent" }
    return $null
}

function Get-McpServerDir {
    foreach ($cand in @("mcp-server", "server", ".")) {
        $pkg = Join-Path $cand "package.json"
        if (Test-Path $pkg) {
            try {
                $p = Get-Content $pkg -Raw | ConvertFrom-Json
                $deps = @()
                if ($p.dependencies)    { $deps += $p.dependencies.PSObject.Properties.Name }
                if ($p.devDependencies) { $deps += $p.devDependencies.PSObject.Properties.Name }
                if ($deps -contains "@modelcontextprotocol/sdk") { return $cand }
            } catch {}
        }
    }
    return $null
}

# --- env/.env.local read/write ----------------------------------------------------------------
function Get-EnvValue {
    param([Parameter(Mandatory)][string]$Key, [string]$File = $script:EnvFile)
    if (-not (Test-Path $File)) { return "" }
    $rx = "^$([regex]::Escape($Key))="
    $line = Get-Content $File | Where-Object { $_ -match $rx } | Select-Object -First 1
    if ($line) { return ($line -replace $rx, "").Trim() }
    return ""
}

function Set-EnvValue {
    param([Parameter(Mandatory)][string]$Key, [string]$Value = "", [string]$File = $script:EnvFile)
    $full = if ([System.IO.Path]::IsPathRooted($File)) { $File } else { Join-Path (Get-Location).Path $File }
    $dir = Split-Path $full -Parent
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $lines = [System.Collections.Generic.List[string]]::new()
    if (Test-Path $full) { foreach ($l in [System.IO.File]::ReadAllLines($full)) { [void]$lines.Add($l) } }
    $rx = "^$([regex]::Escape($Key))="
    $found = $false
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match $rx) { $lines[$i] = "$Key=$Value"; $found = $true }
    }
    if (-not $found) { [void]$lines.Add("$Key=$Value") }
    [System.IO.File]::WriteAllLines($full, $lines)
}

# Add a key only if it's missing (never clobber an existing value).
function Set-EnvDefault {
    param([Parameter(Mandatory)][string]$Key, [string]$Value = "", [string]$File = $script:EnvFile)
    if ([string]::IsNullOrWhiteSpace((Get-EnvValue -Key $Key -File $File))) {
        Set-EnvValue -Key $Key -Value $Value -File $File
    }
}

function Fail {
    param([Parameter(Mandatory)][string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}
