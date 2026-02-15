<#
.DESCRIPTION
Builds Kaitai Struct C++ runtime library and unit tests on Windows using MinGW

Requires:
- MinGW installed and available in the command prompt
- cmake/ctest available
- GTest installed, path passed in `-GTestPath`
#>

[CmdletBinding(PositionalBinding=$false)]
param (
    [Parameter(Mandatory=$true)]
    [string] $GTestPath,

    [Parameter(Mandatory=$false)]
    [string] $EncodingType = "NONE",

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

    cmake -DCMAKE_PREFIX_PATH="$GTestPath" -DSTRING_ENCODING_TYPE="$EncodingType" -G "MinGW Makefiles" .. @ExtraArgs
    if ($LastExitCode -ne 0) {
        throw "'cmake' exited with code $LastExitCode"
    }

    cmake --build . --config Debug
    if ($LastExitCode -ne 0) {
        throw "'cmake --build' exited with code $LastExitCode"
    }

    # MinGW Makefiles build generates the following output:
    #
    # - build/libkaitai_struct_cpp_stl_runtime.dll
    # - build/libkaitai_struct_cpp_stl_runtime.dll.a
    # - build/tests/unittest.exe
    #
    # unittest.exe links dynamically against GTest DLLs and `libkaitai_struct_cpp_stl_runtime.dll`, and it
    # will need all of them in same directory as .exe to run it, so we copy it.

    cp $GTestPath\debug\bin\*.dll tests
    cp libkaitai_struct_cpp_stl_runtime.dll tests
} finally {
    Pop-Location
}
