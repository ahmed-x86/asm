[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$msysDir = "C:\msys64"
$pacmanExe = Join-Path $msysDir "usr\bin\pacman.exe"
$currentDir = Get-Location
$destination = Join-Path $currentDir "msys2.exe"
$pathDoneFile = Join-Path $currentDir "add-to-path.txt"

Write-Host "Checking for existing MSYS2 installation..." -ForegroundColor Cyan

# 0. Check if MSYS2 is already installed
if (Test-Path $pacmanExe) {
    Write-Host "MSYS2 is already installed in $msysDir. Skipping download and installation!" -ForegroundColor Green
} else {
    # 1. Download and Install MSYS2
    if (Test-Path $downloadDoneFile -and (Get-Content $downloadDoneFile -Raw).Trim() -eq "1" -and (Test-Path $destination)) {
        Write-Host "MSYS2 installer is already downloaded locally." -ForegroundColor Green
    } else {
        Write-Host "Fetching the latest MSYS2 download link from GitHub..." -ForegroundColor Cyan
        
        # قراءة بيانات آخر إصدار من واجهة برمجة تطبيقات جيت هاب
        $releaseData = Invoke-RestMethod -Uri "https://api.github.com/repos/msys2/msys2-installer/releases/latest"
        
        # البحث عن ملف التثبيت بصيغة exe
        $url = $releaseData.assets | Where-Object { $_.name -match "^msys2-x86_64-\d+\.exe$" } | Select-Object -ExpandProperty browser_download_url
        
        if (-not $url) {
            Write-Host "Could not fetch dynamic URL. Using fallback..." -ForegroundColor Yellow
            $url = "https://repo.msys2.org/distrib/msys2-x86_64-latest.exe"
        }
        
        Write-Host "Latest URL found: $url" -ForegroundColor Green
        Write-Host "Downloading MSYS2..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $destination
        
        if (Test-Path $destination) {
            Write-Host "Download completed." -ForegroundColor Green
            Set-Content -Path $downloadDoneFile -Value "1"
        } else {
            Write-Host "Download failed." -ForegroundColor Red
            exit
        }
    }

    # Install MSYS2
    $answer = Read-Host "Do you want to skip installing MSYS2? (y/n)"

    if ($answer.Trim().ToLower() -eq "y") {
        Write-Host "Skipping MSYS2 installation." -ForegroundColor Yellow
    }
    else {
        Write-Host "Installing MSYS2..." -ForegroundColor Cyan

        Start-Process `
            -FilePath $destination `
            -ArgumentList "in --confirm-command --accept-messages --root $msysDir" `
            -Wait

        # تحقق من نجاح التثبيت
        if (-not (Test-Path $pacmanExe)) {
            Write-Host "MSYS2 installation failed. pacman.exe not found." -ForegroundColor Red
            exit
        }

        Write-Host "MSYS2 installed successfully." -ForegroundColor Green
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

# Install all standard packages in one go
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

# 7. Update launch.json with the dynamic current directory
Write-Host "--------------------------------------"
Write-Host "Updating VS Code launch.json paths..." -ForegroundColor Cyan
$launchJsonPath = Join-Path $vscodeDir "launch.json"

if (Test-Path $launchJsonPath) {
   
    $launchContent = Get-Content $launchJsonPath -Raw
    
    
    $forwardSlashDir = $currentDir -replace '\\', '/'
    
    
    $launchContent = $launchContent -ireplace "c:/Users/ahmed/Downloads/asm", $forwardSlashDir
    
   
    Set-Content -Path $launchJsonPath -Value $launchContent -Encoding UTF8
    
    Write-Host "launch.json updated successfully with path: $forwardSlashDir" -ForegroundColor Green
} else {
    Write-Host "launch.json not found to update." -ForegroundColor Yellow
}

# 8. Verify Installation using Absolute Paths
Write-Host "--------------------------------------"
Write-Host "Verification:" -ForegroundColor Cyan
& "C:\msys64\ucrt64\bin\gcc.exe" --version | Select-Object -First 1
& "C:\msys64\ucrt64\bin\gdb.exe" --version | Select-Object -First 1
& "C:\msys64\ucrt64\bin\g++.exe" --version | Select-Object -First 1
& "C:\msys64\usr\bin\make.exe" --version | Select-Object -First 1
& "C:\msys64\mingw64\bin\nasm.exe" --version | Select-Object -First 1
Write-Host "Environment Setup Complete! 🚀" -ForegroundColor Green

# ---------------------- 9. Download and Extract Frhed (Final Fixed Version) ----------------------
Write-Host "--------------------------------------"
$frhedAnswer = Read-Host "Do you want to download and setup Frhed Hex Editor in C:\? (y/n)"

if ($frhedAnswer.Trim().ToLower() -eq "y") {
    
    $currentDir = Get-Location
    $frhedUrl = "https://master.dl.sourceforge.net/project/frhed/3.%20Alpha%20Releases/1.7.1/Frhed-1.7.1-exe.7z?viasf=1"
    $frhed7zPath = Join-Path $currentDir "Frhed.7z"
    $frhedDestFolder = "C:\Frhed-1.7.1-exe"
    
   
    $sevenZipProgramFiles = "C:\Program Files\7-Zip\7z.exe"
    $sevenZipPortable = Join-Path $currentDir "7z.exe"
    
    $sevenZipExe = ""
    if (Test-Path $sevenZipProgramFiles) {
        $sevenZipExe = $sevenZipProgramFiles
    } elseif (Test-Path $sevenZipPortable) {
        $sevenZipExe = $sevenZipPortable
    } else {
        
        $sevenZipExe = "7z" 
    }


    Write-Host "Downloading Frhed hex editor..." -ForegroundColor Cyan
    try {
        
        Invoke-WebRequest -Uri $frhedUrl -OutFile $frhed7zPath -UseBasicParsing
        Write-Host "Download complete." -ForegroundColor Green

        Write-Host "Extracting Frhed to $frhedDestFolder..." -ForegroundColor Cyan
        
        if (-not (Test-Path $frhedDestFolder)) { 
            New-Item -ItemType Directory -Path $frhedDestFolder -Force | Out-Null 
        }

       
        if ($sevenZipExe -eq "7z") {
            & 7z x "$frhed7zPath" "-o$frhedDestFolder" -y
        } else {
            & "$sevenZipExe" x "$frhed7zPath" "-o$frhedDestFolder" -y
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Frhed setup successfully in $frhedDestFolder" -ForegroundColor Green
        } else {
            Write-Host "Extraction failed. Make sure 7z.exe is in the current folder." -ForegroundColor Red
        }

        if (Test-Path $frhed7zPath) { Remove-Item -Path $frhed7zPath -Force }
        
    } catch {
        Write-Host "An error occurred during Frhed setup: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Skipping Frhed setup." -ForegroundColor Yellow
}

Write-Host "--------------------------------------"
Write-Host "All tasks finished successfully! 🏁" -ForegroundColor Magenta

# ---------------------- 10. Add Frhed to PATH and Create Alias ----------------------
Write-Host "--------------------------------------"
Write-Host "Configuring PATH and PowerShell Alias for Frhed..." -ForegroundColor Cyan


$frhedPathsToAdd = @(
    "C:\Frhed-1.7.1-exe",
    "C:\Frhed-1.7.1-exe\Frhed-1.7.1-exe"
)

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathModified = $false

foreach ($p in $frhedPathsToAdd) {
    if (-not ($currentPath -split ";" | Where-Object { $_ -eq $p })) {
        $currentPath += ";$p"
        $pathModified = $true
    }
}

if ($pathModified) {
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
    $env:Path = $currentPath 
    Write-Host "Frhed paths added to User PATH successfully." -ForegroundColor Green
} else {
    Write-Host "Frhed paths are already in the PATH." -ForegroundColor Green
}


$profilePath = $PROFILE


if (-not (Test-Path (Split-Path $profilePath))) {
    New-Item -Type Directory -Path (Split-Path $profilePath) -Force | Out-Null
}


if (-not (Test-Path $profilePath)) {
    New-Item -Type File -Path $profilePath -Force | Out-Null
}

$aliasName = "ghex"
$exePath = "C:\Frhed-1.7.1-exe\Frhed-1.7.1-exe\Frhed.exe"


$aliasContent = "`nfunction $aliasName { & `"$exePath`" `$args }"

$profileContent = ""
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
}


if (-not $profileContent -or $profileContent -notmatch "function $aliasName") {
    Add-Content -Path $profilePath -Value $aliasContent -Encoding UTF8
    Write-Host "Alias '$aliasName' mapped to Frhed successfully in PowerShell Profile." -ForegroundColor Green
    
    
    Invoke-Expression $aliasContent
} else {
    Write-Host "Alias '$aliasName' already exists in PowerShell Profile." -ForegroundColor Green
}

Write-Host "--------------------------------------"
Write-Host "Step 10 completed! You can now use 'ghex' from any terminal." -ForegroundColor Magenta