<#
.DESCRIPTION
Builds Kaitai Struct C++ runtime library and unit tests using MinGW-w64

Requires:
- MinGW-w64 installed and available in PATH
- cmake available
- GTest installed, path passed in `-GTestPath`

NOTE: This script is a compatibility wrapper. Use build-windows.ps1 instead.
#>

[CmdletBinding(PositionalBinding=$false)]
param (
    [Parameter(Mandatory=$true)]
    [string] $GTestPath,

    [Parameter(Mandatory=$false)]
    [string] $EncodingType = "WIN32API",

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]] $ExtraArgs
)

# Forward to unified build script
& "$PSScriptRoot\build-windows.ps1" -Toolchain MinGW -GTestPath $GTestPath -EncodingType $EncodingType @ExtraArgs
