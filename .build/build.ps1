<#
.DESCRIPTION
Builds Kaitai Struct C++ runtime library and unit tests

Requires:
- MSVC native tools installed and available in the command prompt
- cmake/ctest available (normally installed with MSVC native tools)
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
& "$PSScriptRoot\build-windows.ps1" -Toolchain MSVC -GTestPath $GTestPath -EncodingType $EncodingType @ExtraArgs
