[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$url = "https://github.com/msys2/msys2-installer/releases/download/2025-12-13/msys2-x86_64-20251213.exe"

$currentDir = Get-Location
$destination = Join-Path $currentDir "msys2.exe"
$downloadDoneFile = Join-Path $currentDir "downloading-done.txt"
$pathDoneFile = Join-Path $currentDir "add-to-path.txt"

# 1. Download MSYS2
if (Test-Path $downloadDoneFile) {
    $content = Get-Content $downloadDoneFile -Raw
    if ($content.Trim() -eq "1") {
        Write-Host "MSYS2 installer is already downloaded." -ForegroundColor Green
    }
} else {
    Write-Host "Downloading MSYS2..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $destination

    if (Test-Path $destination) {
        Write-Host "Download completed." -ForegroundColor Green
        Set-Content -Path $downloadDoneFile -Value "1"

        $answer = Read-Host "Do you want to skip installing MSYS2? (y/n)"
        if ($answer.Trim().ToLower() -eq "y") {
            Write-Host "Skipping MSYS2 installation." -ForegroundColor Yellow
        } else {
            Write-Host "Installing MSYS2 silently. Please wait..." -ForegroundColor Cyan
            Start-Process -FilePath $destination -ArgumentList "in --confirm-command --accept-messages --root C:\msys64" -Wait
            Write-Host "MSYS2 installed successfully in C:\msys64" -ForegroundColor Green
        }
    } else {
        Write-Host "Download failed." -ForegroundColor Red
        exit
    }
}

# 2. Add to PATH
if (-not (Test-Path $pathDoneFile)) {
    Write-Host "Adding MSYS2 directories to PATH..." -ForegroundColor Cyan
    $pathsToAdd = @(
        "C:\msys64\usr\bin",
        "C:\msys64\mingw64\bin",
        "C:\msys64\mingw32\bin",
        "C:\msys64\ucrt64\bin"
    )

    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    foreach ($p in $pathsToAdd) {
        if (-not ($currentPath -split ";" | Where-Object { $_ -eq $p })) {
            $currentPath += ";$p"
        }
    }

    # Update Windows permanently
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
    
    # Update current PowerShell session so 'pacman' works immediately below
    $env:Path = $currentPath 
    
    Set-Content -Path $pathDoneFile -Value "1"
    Write-Host "Paths added successfully." -ForegroundColor Green
} else {
    Write-Host "Paths are already added." -ForegroundColor Green
    # Ensure current session has the paths if the script is run again in a fresh window
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User")
}

# 3. Update MSYS2 and Install Packages automatically
Write-Host "Syncing pacman databases and installing packages..." -ForegroundColor Cyan

# Update databases first
pacman -Sy --noconfirm

# Install all standard packages in one go (saves time and resolves dependencies together)
pacman -S --noconfirm mingw-w64-i686-gcc mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb mingw-w64-x86_64-nasm make

# Install UASM with the specific overwrite fix
pacman -S --noconfirm mingw-w64-x86_64-uasm --overwrite "/mingw64/bin/jwasm.exe,/mingw64/share/licenses/uasm/LICENSE"

# 4. Verify Installation
Write-Host "--------------------------------------"
Write-Host "Verification:" -ForegroundColor Cyan
gcc --version | Select-Object -First 1
gdb --version | Select-Object -First 1
g++ --version | Select-Object -First 1
make --version | Select-Object -First 1
nasm --version
Write-Host "Environment Setup Complete! 🚀" -ForegroundColor Green