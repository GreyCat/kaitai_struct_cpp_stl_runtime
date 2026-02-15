<#
.DESCRIPTION
Runs unit tests on Windows

.PARAMETER Toolchain
Specifies which toolchain was used to build: 'MSVC' or 'MinGW'
This determines the path to the executable.
#>

[CmdletBinding(PositionalBinding=$false)]
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet('MSVC', 'MinGW')]
    [string] $Toolchain = 'MSVC',

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]] $TestArgs
)

# Standard boilerplate
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Go to repo root
$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
Push-Location $repoRoot

try {
    cd build

    # Run gtest-generated binary directly, produces more detailed output
    #
    # NOTE: `$TestArgs` contains all command-line arguments passed to the script.
    # We use [splatting](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_splatting?view=powershell-7.5)
    # to pass all received arguments to the test runner.
    
    if ($Toolchain -eq 'MSVC') {
        ./tests/Debug/unittest.exe @TestArgs
    } else {
        # MinGW
        ./tests/unittest.exe @TestArgs
    }
} finally {
    Pop-Location
}
