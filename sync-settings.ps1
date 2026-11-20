#Requires -Version 7.3
param(
    [Parameter(Mandatory)]
    [ValidateSet('Export', 'Apply')]
    [string] $Action,

    [string] $ConfigDirectory = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'
$sharedPath = Join-Path $PSScriptRoot 'settings.shared.json'
$localPath = Join-Path (Convert-Path -LiteralPath $ConfigDirectory) 'settings.json'

function Read-Settings([string] $Path) {
    $settings = Get-Content -LiteralPath $Path -Raw |
        ConvertFrom-Json -AsHashtable -NoEnumerate
    if ($settings -isnot [System.Collections.IDictionary]) {
        throw "Expected a JSON object in $Path"
    }
    return $settings
}

if ($Action -eq 'Export') {
    $settings = Read-Settings $localPath
    $settings.Remove('ssh_connections')
    $target = $sharedPath
} else {
    $settings = Read-Settings $sharedPath
    if ($settings.Contains('ssh_connections')) {
        throw 'Remove ssh_connections from settings.shared.json before applying.'
    }
    if (Test-Path -LiteralPath $localPath) {
        $local = Read-Settings $localPath
        if ($local.Contains('ssh_connections')) {
            $settings['ssh_connections'] = $local['ssh_connections']
        }
    }
    $target = $localPath
}

$temporaryPath = Join-Path (Split-Path -Parent $target) ".settings-write-$([guid]::NewGuid()).tmp"
try {
    $settings | ConvertTo-Json -Depth 100 -WarningAction Stop |
        Set-Content -LiteralPath $temporaryPath -Encoding utf8
    [System.IO.File]::Move($temporaryPath, $target, $true)
} finally {
    if (Test-Path -LiteralPath $temporaryPath) {
        Remove-Item -LiteralPath $temporaryPath
    }
}
