<#
.DESCRIPTION
Builds Kaitai Struct C++ runtime library and unit tests on Windows

Requires:
- MSVC native tools (for MSVC) or MinGW-w64 (for MinGW) installed and available
- cmake/ctest available
- GTest installed, path passed in `-GTestPath`

.PARAMETER Toolchain
Specifies which toolchain to use: 'MSVC' or 'MinGW'
#>

[CmdletBinding(PositionalBinding=$false)]
param (
    [Parameter(Mandatory=$true)]
    [string] $GTestPath,

    [Parameter(Mandatory=$false)]
    [ValidateSet('MSVC', 'MinGW')]
    [string] $Toolchain = 'MSVC',

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

    # Configure CMake based on toolchain
    if ($Toolchain -eq 'MinGW') {
        # Use MinGW Makefiles generator
        cmake -G "MinGW Makefiles" -DCMAKE_PREFIX_PATH="$GTestPath" -DSTRING_ENCODING_TYPE="$EncodingType" .. @ExtraArgs
    } else {
        # Use default generator (Visual Studio for MSVC)
        cmake -DCMAKE_PREFIX_PATH="$GTestPath" -DSTRING_ENCODING_TYPE="$EncodingType" .. @ExtraArgs
    }
    
    if ($LastExitCode -ne 0) {
        throw "'cmake' exited with code $LastExitCode"
    }

    # Build
    if ($Toolchain -eq 'MSVC') {
        cmake --build . --config Debug
    } else {
        cmake --build .
    }
    
    if ($LastExitCode -ne 0) {
        throw "'cmake --build' exited with code $LastExitCode"
    }

    # Copy DLL files to the tests directory
    if ($Toolchain -eq 'MSVC') {
        cp $GTestPath\debug\bin\*.dll tests\Debug
        cp Debug\kaitai_struct_cpp_stl_runtime.dll tests\Debug
    } else {
        # MinGW
        if (Test-Path "$GTestPath\bin\*.dll") {
            cp $GTestPath\bin\*.dll tests\
        }
        if (Test-Path "libkaitai_struct_cpp_stl_runtime.dll") {
            cp libkaitai_struct_cpp_stl_runtime.dll tests\
        }
    }
} finally {
    Pop-Location
}
