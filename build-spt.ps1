<#
.SYNOPSIS
    Builds DPX-ElectronicsCase against a local SPT 4.1.x server and installs it.

.PARAMETER SptRoot
    Folder that contains SPTarkov.Server.Core.dll (SPT_Runtime).

.PARAMETER Package
    Also write build\DPX-ElectronicsCase-v<version>.zip (SPT_Runtime\user\mods\...).

.PARAMETER SkipDeploy
    Only build/package, do not touch the game folder.
#>
[CmdletBinding()]
param(
    [string]$SptRoot = 'D:\Games\SPT 4.1.6 essential\SPT_Runtime',
    [string]$Configuration = 'Release',
    [switch]$Package,
    [switch]$SkipDeploy
)

$ErrorActionPreference = 'Stop'
$repo = $PSScriptRoot
$proj = Join-Path $repo 'DPX-ElectronicsCase.csproj'

if (-not (Test-Path (Join-Path $SptRoot 'SPTarkov.Server.Core.dll'))) {
    throw "No SPT runtime found at '$SptRoot' (SPTarkov.Server.Core.dll missing). Point -SptRoot at the SPT_Runtime folder."
}
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    throw 'dotnet SDK not found. SPT 4.1.x runs on .NET 10 - install the .NET 10 SDK.'
}

$version = ([regex]::Match((Get-Content $proj -Raw), '<Version>([^<]+)</Version>')).Groups[1].Value
Write-Host "SPT runtime : $SptRoot"
Write-Host "dotnet      : $(& dotnet --version)"
Write-Host "version     : $version"

& dotnet build $proj -c $Configuration "/p:SptRoot=$SptRoot" -v minimal --nologo
if ($LASTEXITCODE -ne 0) { throw "Build failed (exit $LASTEXITCODE)" }

$out = Join-Path $repo "bin\$Configuration\net10.0"
$dll = Join-Path $out 'DPX-ElectronicsCase.dll'
if (-not (Test-Path $dll)) { throw "missing build output: $dll" }
Write-Host ("built {0} ({1} bytes)" -f $dll, (Get-Item $dll).Length)

function Copy-ModFiles([string]$dest) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Copy-Item $dll (Join-Path $dest 'DPX-ElectronicsCase.dll') -Force
    Copy-Item (Join-Path $repo 'bundles.json') $dest -Force
    Copy-Item (Join-Path $repo 'package.json') $dest -Force
    Copy-Item (Join-Path $repo 'bundles') $dest -Recurse -Force
    # never overwrite an existing user config
    $cfg = Join-Path $dest 'config\config.json'
    if (-not (Test-Path $cfg)) {
        New-Item -ItemType Directory -Force -Path (Split-Path $cfg) | Out-Null
        Copy-Item (Join-Path $repo 'config\config.json') $cfg -Force
    }
}

if ($Package) {
    $stage = Join-Path $repo 'build\SPT_Runtime\user\mods\DPX-ElectronicsCase'
    if (Test-Path (Join-Path $repo 'build')) { Remove-Item (Join-Path $repo 'build') -Recurse -Force }
    Copy-ModFiles $stage
    $zip = Join-Path $repo "build\DPX-ElectronicsCase-v$version.zip"
    Compress-Archive -Path (Join-Path $repo 'build\SPT_Runtime') -DestinationPath $zip -Force
    Write-Host "package : $zip"
}

if ($SkipDeploy) { Write-Host 'Built, deployment skipped.'; return }
if (Get-Process -Name 'SPT.Server' -ErrorAction SilentlyContinue) {
    Write-Warning 'SPT.Server is running - stop it and re-run to deploy.'
    return
}

$mod = Join-Path $SptRoot 'user\mods\DPX-ElectronicsCase'
Copy-ModFiles $mod
Write-Host ''
Write-Host "Installed to: $mod"
Get-ChildItem $mod -Recurse -File | Select-Object @{n='file';e={$_.FullName.Substring($mod.Length)}},Length | Format-Table -AutoSize
