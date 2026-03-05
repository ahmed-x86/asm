[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "Fetching the latest MSYS2 download link from GitHub..." -ForegroundColor Cyan


$releaseData = Invoke-RestMethod -Uri "https://api.github.com/repos/msys2/msys2-installer/releases/latest"


$url = $releaseData.assets | Where-Object { $_.name -match "^msys2-x86_64-\d+\.exe$" } | Select-Object -ExpandProperty browser_download_url

if (-not $url) {
    Write-Host "Could not fetch dynamic URL. Using fallback..." -ForegroundColor Yellow
    $url = "https://repo.msys2.org/distrib/msys2-x86_64-latest.exe"
}

Write-Host "Latest URL found: $url" -ForegroundColor Green

$currentDir = Get-Location
$destination = Join-Path $currentDir "msys2.exe"
$downloadDoneFile = Join-Path $currentDir "downloading-done.txt"
$pathDoneFile = Join-Path $currentDir "add-to-path.txt"

# 1. Download and Install MSYS2
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
    
    # Update current PowerShell session just in case
    $env:Path = $currentPath 
    
    Set-Content -Path $pathDoneFile -Value "1"
    Write-Host "Paths added successfully." -ForegroundColor Green
} else {
    Write-Host "Paths are already added." -ForegroundColor Green
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "User")
}

# 3. Update MSYS2 and Install Packages automatically using Absolute Paths
Write-Host "Syncing pacman databases and installing packages..." -ForegroundColor Cyan

# Update databases first
& "C:\msys64\usr\bin\pacman.exe" -Sy --noconfirm

# Install all standard packages in one go (g++ is included in gcc)
& "C:\msys64\usr\bin\pacman.exe" -S --noconfirm mingw-w64-i686-gcc mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb mingw-w64-x86_64-nasm make

# Install UASM with the specific overwrite fix
& "C:\msys64\usr\bin\pacman.exe" -S --noconfirm mingw-w64-x86_64-uasm --overwrite "/mingw64/bin/jwasm.exe,/mingw64/share/licenses/uasm/LICENSE"


# 4. VS Code Configuration Setup (Local or Cloud)
Write-Host "Setting up VS Code environment..." -ForegroundColor Cyan

$vscodeDir = Join-Path $currentDir ".vscode"
$localSetupDir = Join-Path $currentDir "install-windows"
$jsonFiles = @("c_cpp_properties.json", "launch.json", "settings.json", "tasks.json")

# Create .vscode directory if it doesn't exist
if (-not (Test-Path $vscodeDir)) {
    New-Item -ItemType Directory -Path $vscodeDir | Out-Null
    Write-Host "Created .vscode directory." -ForegroundColor Green
}

# Check if the local folder exists and contains ALL 4 files
$localFilesComplete = $true
if (Test-Path $localSetupDir) {
    foreach ($file in $jsonFiles) {
        if (-not (Test-Path (Join-Path $localSetupDir $file))) {
            $localFilesComplete = $false
            break
        }
    }
} else {
    $localFilesComplete = $false
}

if ($localFilesComplete) {
    Write-Host "Found local VS Code configs. Copying them to .vscode..." -ForegroundColor Cyan
    foreach ($file in $jsonFiles) {
        Copy-Item -Path (Join-Path $localSetupDir $file) -Destination (Join-Path $vscodeDir $file) -Force
    }
    Write-Host "VS Code configs copied successfully." -ForegroundColor Green
} else {
    Write-Host "Local configs missing or incomplete. Downloading from GitHub..." -ForegroundColor Yellow
    $githubBaseUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows/"
    
    foreach ($file in $jsonFiles) {
        $fileUrl = $githubBaseUrl + $file
        $destPath = Join-Path $vscodeDir $file
        Write-Host "Downloading $file..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $fileUrl -OutFile $destPath
    }
    Write-Host "VS Code configs downloaded successfully." -ForegroundColor Green
}

# 5. Download and Extract Irvine32 Library
Write-Host "--------------------------------------"
$irvineAnswer = Read-Host "Do you want to download and extract the Irvine library? (y/n)"
if ($irvineAnswer.Trim().ToLower() -eq "y") {
    Write-Host "Downloading Irvine library..." -ForegroundColor Cyan
    $irvineUrl = "http://www.asmirvine.com/gettingStartedVS2019/Irvine.zip"
    $irvineZipPath = Join-Path $currentDir "Irvine.zip"

    try {
        Invoke-WebRequest -Uri $irvineUrl -OutFile $irvineZipPath
        Write-Host "Download complete. Extracting files Here..." -ForegroundColor Cyan
        
        # Extract Here (directly to the current directory)
        Expand-Archive -Path $irvineZipPath -DestinationPath $currentDir -Force
        
        Write-Host "Extraction complete. Cleaning up zip file..." -ForegroundColor Cyan
        Remove-Item -Path $irvineZipPath -Force
        Write-Host "Irvine library is ready!" -ForegroundColor Green
    } catch {
        Write-Host "Failed to download or extract Irvine library. Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipping Irvine library download." -ForegroundColor Yellow
}

# 6. Verify Installation using Absolute Paths
Write-Host "--------------------------------------"
Write-Host "Verification:" -ForegroundColor Cyan
& "C:\msys64\ucrt64\bin\gcc.exe" --version | Select-Object -First 1
& "C:\msys64\ucrt64\bin\gdb.exe" --version | Select-Object -First 1
& "C:\msys64\ucrt64\bin\g++.exe" --version | Select-Object -First 1
& "C:\msys64\usr\bin\make.exe" --version | Select-Object -First 1
& "C:\msys64\mingw64\bin\nasm.exe" --version | Select-Object -First 1
Write-Host "Environment Setup Complete! 🚀" -ForegroundColor Green