<#
.DESCRIPTION
Runs unit tests on Windows using MinGW

NOTE: This script is a compatibility wrapper. Use run-unittest-windows.ps1 instead.
#>

[CmdletBinding(PositionalBinding=$false)]
param (
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]] $TestArgs
)

# Forward to unified test script
& "$PSScriptRoot\run-unittest-windows.ps1" -Toolchain MinGW @TestArgs
