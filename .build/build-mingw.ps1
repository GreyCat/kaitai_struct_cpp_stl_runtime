<#
.DESCRIPTION
Builds Kaitai Struct C++ runtime library and unit tests using MinGW-w64

Requires:
- MinGW-w64 installed and available in PATH
- cmake available
- GTest installed, path passed in `-GTestPath`
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

# Standard boilerplate
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Go to repo root
$repoRoot = (Resolve-Path "$PSScriptRoot\..").Path
Push-Location $repoRoot

try {
    $null = New-Item -Path build -ItemType Directory -Force
    cd build

    $env:VERBOSE = '1'

    # Use MinGW Makefiles generator
    cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="$GTestPath" -DSTRING_ENCODING_TYPE="$EncodingType" .. @ExtraArgs
    if ($LastExitCode -ne 0) {
        throw "'cmake' exited with code $LastExitCode"
    }

    cmake --build .
    if ($LastExitCode -ne 0) {
        throw "'cmake --build' exited with code $LastExitCode"
    }

    # Copy DLL files to the tests directory
    if (Test-Path "$GTestPath\bin\*.dll") {
        cp $GTestPath\bin\*.dll tests\
    }
    if (Test-Path "libkaitai_struct_cpp_stl_runtime.dll") {
        cp libkaitai_struct_cpp_stl_runtime.dll tests\
    }
} finally {
    Pop-Location
}
