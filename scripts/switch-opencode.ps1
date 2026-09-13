#Requires -Version 5.1
<#
.SYNOPSIS
  Switch this repo between OpenCode 1.x and 2.x (CLI package + git branch).

.EXAMPLE
  pwsh ./scripts/switch-opencode.ps1 v1
  pwsh ./scripts/switch-opencode.ps1 v2
#>
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [ValidateSet('v1', 'v2')]
  [string]$Target
)

$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Repo

$Branch = if ($Target -eq 'v1') { 'opencode-v1' } else { 'opencode-v2' }
$Package = if ($Target -eq 'v1') { 'opencode-ai@1' } else { '@opencode/cli@2' }

function Get-OpenCodeMajor {
  $cmd = Get-Command opencode -ErrorAction SilentlyContinue
  if (-not $cmd) { return $null }
  $out = & opencode --version 2>&1 | Out-String
  if ($out -match 'v?(\d+)\.') { return [int]$Matches[1] }
  return $null
}

function Uninstall-CurrentCli {
  $cmd = Get-Command opencode -ErrorAction SilentlyContinue
  if ($cmd) {
    & opencode uninstall --keep-config --keep-data --force
    return
  }
  foreach ($pkg in @('@opencode/cli', 'opencode-ai')) {
    pnpm remove -g $pkg 2>$null
  }
}

$dirty = git status --porcelain
if ($dirty) {
  throw "Working tree is dirty. Commit or stash first.`n$dirty"
}

$currentBranch = (git branch --show-current).Trim()
$major = Get-OpenCodeMajor

Write-Host "Close the OpenCode TUI first."
Write-Host "Target $Target | branch $Branch | package $Package"

if ($Target -eq 'v1') {
  if ($currentBranch -ne $Branch) {
    git switch $Branch
  }
  if ($major -ne 1) {
    Uninstall-CurrentCli
    pnpm add -g opencode-ai@1
  }
}
else {
  if ($major -ne 2) {
    Uninstall-CurrentCli
    pnpm add -g @opencode/cli@2
  }
  if ($currentBranch -ne $Branch) {
    git switch $Branch
  }
}

Write-Host "branch: $((git branch --show-current).Trim())"
Write-Host -NoNewline "cli: "
opencode --version
Write-Host "Restart OpenCode."
