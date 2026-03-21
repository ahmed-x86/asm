param (
    [Parameter(Position=0)]
    [string]$file
)

# 1. Check if file argument is provided
if (-not $file) {
    Write-Host "Oops, looks like you forgot the filename! 😅" -ForegroundColor Yellow
    Write-Host "Try running it like this: .\build.ps1 <filename.asm>"
    exit 1
}

# 2. Check if file exists
if (-not (Test-Path $file)) {
    Write-Host "Hmm... I can't seem to find '$file'. Are you sure it's in this folder? 🤔" -ForegroundColor Red
    exit 1
}

# Setup variables to mimic VS Code behavior
$fileInfo = Get-Item $file
$fileDirname = $fileInfo.DirectoryName
$fileBasenameNoExtension = $fileInfo.BaseName
$workspaceFolder = (Get-Location).Path

$objFile = "$fileDirname\$fileBasenameNoExtension.obj"
$exeFile = "$fileDirname\$fileBasenameNoExtension.exe"
$irvineLib = "$workspaceFolder\irvine\Irvine32.lib"
$irvineInc = "$workspaceFolder\irvine"

Write-Host "Choose build mode:" -ForegroundColor Cyan
Write-Host "1) Win32 Irvine (Standard)"
Write-Host "2) Win32 Standalone (Standard)"
Write-Host "3) Win64 Standalone (Standard)"
Write-Host "4) Win32 Irvine (Custom main)"
Write-Host "5) Win32 Standalone (Custom main)"
Write-Host "6) Win64 Standalone (Custom main)"

$opt = Read-Host "Option"

switch ($opt) {
    '1' {
        & C:\msys64\mingw64\bin\uasm.exe -q -coff -I"$irvineInc" -Fo"$objFile" "$file"
        if ($LASTEXITCODE -eq 0) { & C:\msys64\mingw32\bin\i686-w64-mingw32-gcc.exe "$objFile" "$irvineLib" -o "$exeFile" -nostdlib -lkernel32 -luser32 -w '-Wl,--subsystem,console' }
        if ($LASTEXITCODE -eq 0) { & "$exeFile" }
    }
    '2' {
        & C:\msys64\mingw64\bin\nasm.exe -f win32 "$file" -o "$objFile"
        if ($LASTEXITCODE -eq 0) { & C:\msys64\mingw32\bin\i686-w64-mingw32-gcc.exe "$objFile" -o "$exeFile" -nostartfiles -lkernel32 -luser32 }
        if ($LASTEXITCODE -eq 0) { & "$exeFile" }
    }
    '3' {
        & C:\msys64\mingw64\bin\nasm.exe -f win64 "$file" -o "$objFile"
        if ($LASTEXITCODE -eq 0) { & C:\msys64\mingw64\bin\x86_64-w64-mingw32-gcc.exe "$objFile" -o "$exeFile" -nostartfiles -lkernel32 -luser32 }
        if ($LASTEXITCODE -eq 0) { & "$exeFile" }
    }
    '4' {
        & C:\msys64\mingw64\bin\uasm.exe -q -coff -I"$irvineInc" -Fo"$objFile" "$file"
        if ($LASTEXITCODE -eq 0) { & C:\msys64\mingw32\bin\i686-w64-mingw32-gcc.exe "$objFile" "$irvineLib" -o "$exeFile" -nostdlib -lkernel32 -luser32 -w '-Wl,-e_main' '-Wl,--subsystem,console' '-Wl,--enable-stdcall-fixup' 2>$null }
        if ($LASTEXITCODE -eq 0) { & "$exeFile" }
    }
    '5' {
        & C:\msys64\mingw64\bin\nasm.exe -f win32 "$file" -o "$objFile"
        if ($LASTEXITCODE -eq 0) { & C:\msys64\mingw32\bin\i686-w64-mingw32-gcc.exe "$objFile" -o "$exeFile" -nostartfiles -lkernel32 -luser32 '-Wl,-e_main' }
        if ($LASTEXITCODE -eq 0) { & "$exeFile" }
    }
    '6' {
        & C:\msys64\mingw64\bin\nasm.exe -f win64 "$file" -o "$objFile"
        if ($LASTEXITCODE -eq 0) { & C:\msys64\mingw64\bin\x86_64-w64-mingw32-gcc.exe "$objFile" -o "$exeFile" -nostartfiles -lkernel32 -luser32 '-Wl,-emain' }
        if ($LASTEXITCODE -eq 0) { & "$exeFile" }
    }
    default {
        Write-Host "Whoops, that's not on the menu! Try picking a number from 1 to 6 next time. 😉" -ForegroundColor Yellow
        exit 1
    }
}