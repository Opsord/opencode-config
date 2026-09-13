#Requires -Version 5.1
<#
.SYNOPSIS
  Show current OpenCode CLI + config branch, then offer to switch.

.EXAMPLE
  pwsh ./scripts/switch-opencode.ps1
#>
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Repo

$dirty = git status --porcelain
if ($dirty) {
  throw "Working tree is dirty. Commit or stash first.`n$dirty"
}

function Get-OpenCodeCli {
  $cmd = Get-Command opencode -ErrorAction SilentlyContinue
  if (-not $cmd) {
    return @{ Major = $null; Label = 'not installed' }
  }
  $out = (& opencode --version 2>&1 | Out-String).Trim()
  $major = $null
  if ($out -match 'v?(\d+)\.') { $major = [int]$Matches[1] }
  return @{ Major = $major; Label = $out }
}

function Get-ConfigKind {
  $b = (git branch --show-current).Trim()
  switch ($b) {
    'opencode-v1' {
      return @{ Kind = 'v1'; Label = 'OpenCode 1 (opencode-v1)' }
    }
    'opencode-v2' {
      return @{ Kind = 'v2'; Label = 'OpenCode 2 (opencode-v2)' }
    }
    default {
      return @{ Kind = 'none'; Label = "none (branch '$b' has no live OpenCode config)" }
    }
  }
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

function Stop-OpenCodeProcesses {
  $procs = @(Get-Process -Name opencode -ErrorAction SilentlyContinue)
  if (-not $procs) { return }
  Write-Host "Stopping $($procs.Count) OpenCode process(es) (TUI / serve --service)."
  $procs | Stop-Process -Force
  Start-Sleep -Seconds 1
}

function Repair-AfterSwitch([string]$Target) {
  if ($Target -eq 'v1') {
    if (Test-Path -LiteralPath '.opencode') {
      Write-Host 'Removing leftover .opencode/ (v2 discovery dir; triggers a failed npm install on v1).'
      Remove-Item -LiteralPath '.opencode' -Recurse -Force
    }
    if (-not (Test-Path -LiteralPath 'package.json')) {
      Write-Host 'Writing local v1 package.json (gitignored) so plugin install can succeed.'
      @{
        dependencies = @{
          '@dietrichgebert/ponytail' = '^4.9.0'
          '@opencode-ai/plugin'      = '1.18.4'
          superpowers                = 'github:obra/superpowers'
        }
      } | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath 'package.json' -Encoding utf8NoBOM
    }
  }

  if (Test-Path -LiteralPath 'package.json') {
    Write-Host 'pnpm install (so the next TUI open does not hang on a failed background npm install).'
    pnpm install
  }
}

function Switch-To([string]$Target) {
  $branch = if ($Target -eq 'v1') { 'opencode-v1' } else { 'opencode-v2' }

  Stop-OpenCodeProcesses
  $currentBranch = (git branch --show-current).Trim()
  $major = (Get-OpenCodeCli).Major

  if ($Target -eq 'v1') {
    if ($currentBranch -ne $branch) { git switch $branch }
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
    if ((git branch --show-current).Trim() -ne $branch) { git switch $branch }
  }

  Repair-AfterSwitch $Target

  Write-Host "branch: $((git branch --show-current).Trim())"
  Write-Host -NoNewline 'cli: '
  opencode --version
  Write-Host 'Restart OpenCode.'
}

function Test-Yes([string]$Answer) {
  return $Answer -match '^(y|yes|s|si|sí)?$'
}

$cli = Get-OpenCodeCli
$cfg = Get-ConfigKind

Write-Host "CLI:    $($cli.Label)"
Write-Host "Config: $($cfg.Label)"

if ($cfg.Kind -in @('v1', 'v2') -and $null -ne $cli.Major) {
  $expected = if ($cfg.Kind -eq 'v1') { 1 } else { 2 }
  if ($cli.Major -ne $expected) {
    Write-Host "Mismatch: CLI major $($cli.Major) vs config $($cfg.Kind)."
  }
}

if ($cfg.Kind -eq 'none') {
  $ans = Read-Host 'No live config on this branch. Switch to [1] OpenCode 1, [2] OpenCode 2, [n] cancel'
  if ($null -eq $ans) { Write-Host 'Cancelled.'; exit 0 }
  switch -Regex ($ans.Trim()) {
    '^1$' { Switch-To 'v1' }
    '^2$' { Switch-To 'v2' }
    default { Write-Host 'Cancelled.' }
  }
  exit 0
}

$other = if ($cfg.Kind -eq 'v1') { 'v2' } else { 'v1' }
$otherLabel = if ($other -eq 'v1') { 'OpenCode 1 (opencode-v1)' } else { 'OpenCode 2 (opencode-v2)' }
Write-Host "Target: $otherLabel"
$ans = Read-Host "Switch to ${otherLabel}? [Y/n]"
if ($null -eq $ans -or -not (Test-Yes $ans.Trim())) {
  Write-Host 'Cancelled.'
  exit 0
}
Switch-To $other
