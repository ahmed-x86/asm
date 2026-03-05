[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$msysDir = "C:\msys64"
$pacmanExe = Join-Path $msysDir "usr\bin\pacman.exe"
$currentDir = Get-Location
$destination = Join-Path $currentDir "msys2.exe"

Write-Host "Checking for existing MSYS2 installation..." -ForegroundColor Cyan

# 1. Check if MSYS2 is already installed by checking the folder
if (Test-Path -Path $msysDir -PathType Container) {
    Write-Host "MSYS2 folder already exists at $msysDir. Skipping download and installation." -ForegroundColor Green
}
else {
    # Folder doesn't exist, proceed to download
    Write-Host "Downloading latest MSYS2 installer..." -ForegroundColor Cyan

    $url = "https://repo.msys2.org/distrib/msys2-x86_64-latest.exe"

    # إجبار الويندوز على استخدام بروتوكولات أمان حديثة لتجنب مشاكل التحميل
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
    $ProgressPreference = 'SilentlyContinue' # إخفاء شريط التحميل لتسريع العملية ومنع التجميد

    try {
        Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing
        Write-Host "Download completed successfully via PowerShell." -ForegroundColor Green
    }
    catch {
        Write-Host "PowerShell download failed, trying native curl.exe..." -ForegroundColor Yellow
        try {
            curl.exe -L -o $destination $url
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Download completed successfully via curl." -ForegroundColor Green
            } else {
                throw "curl exited with error code $LASTEXITCODE"
            }
        } catch {
            Write-Host "Download completely failed on this machine. Error: $_" -ForegroundColor Red
            exit
        }
    }

    if (-not (Test-Path $destination)) {
        Write-Host "Installer not found after download." -ForegroundColor Red
        exit
    }

    # Install MSYS2 with GUI
    $answer = Read-Host "Do you want to skip installing MSYS2? (y/n)"

    if ($answer.Trim().ToLower() -eq "y") {
        Write-Host "Skipping MSYS2 installation." -ForegroundColor Yellow
    }
    else {
        Write-Host "Opening MSYS2 installer..." -ForegroundColor Cyan
        Write-Host "Please complete the setup wizard (Next -> Next -> Finish). IMPORTANT: Keep the default installation path (C:\msys64)." -ForegroundColor Yellow
        Write-Host "The script is paused and waiting for you to finish the installation..." -ForegroundColor Magenta

        # فتح الواجهة الرسومية والانتظار حتى يغلقها المستخدم
        Start-Process -FilePath $destination -Wait

        if (-not (Test-Path $pacmanExe)) {
            Write-Host "MSYS2 installation failed or was cancelled. pacman.exe not found." -ForegroundColor Red
            exit
        }

        Write-Host "MSYS2 installed successfully. Resuming script..." -ForegroundColor Green
    }
}

# 2. Add to PATH dynamically
Write-Host "Checking MSYS2 Environment Paths..." -ForegroundColor Cyan
$pathsToAdd = @(
    "C:\msys64\usr\bin",
    "C:\msys64\mingw64\bin",
    "C:\msys64\mingw32\bin",
    "C:\msys64\ucrt64\bin"
)

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathChanged = $false

foreach ($p in $pathsToAdd) {
    if (-not ($currentPath -split ";" | Where-Object { $_ -eq $p })) {
        $currentPath += ";$p"
        $pathChanged = $true
    }
}

if ($pathChanged) {
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
    $env:Path = $currentPath 
    Write-Host "Paths added successfully." -ForegroundColor Green
} else {
    Write-Host "Paths are already added." -ForegroundColor Green
}

# 3. Update MSYS2 and Install Packages automatically
Write-Host "Syncing pacman databases and installing packages..." -ForegroundColor Cyan

& "C:\msys64\usr\bin\pacman.exe" -Sy --noconfirm
& "C:\msys64\usr\bin\pacman.exe" -S --needed --noconfirm mingw-w64-i686-gcc mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb mingw-w64-x86_64-nasm make
& "C:\msys64\usr\bin\pacman.exe" -S --needed --noconfirm mingw-w64-x86_64-uasm --overwrite "/mingw64/bin/jwasm.exe,/mingw64/share/licenses/uasm/LICENSE"


# 4. VS Code Configuration Setup
Write-Host "Setting up VS Code environment..." -ForegroundColor Cyan

$vscodeDir = Join-Path $currentDir ".vscode"
$localSetupDir = Join-Path $currentDir "install-windows"
$jsonFiles = @("c_cpp_properties.json", "launch.json", "settings.json", "tasks.json")

if (-not (Test-Path $vscodeDir)) {
    New-Item -ItemType Directory -Path $vscodeDir | Out-Null
    Write-Host "Created .vscode directory." -ForegroundColor Green
}

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
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
        Invoke-WebRequest -Uri $irvineUrl -OutFile $irvineZipPath
        Write-Host "Download complete. Extracting files Here..." -ForegroundColor Cyan
        
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

# 6. Update launch.json with the dynamic current directory
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

# 7. Verify Installation
Write-Host "--------------------------------------"
Write-Host "Verification:" -ForegroundColor Cyan
& "C:\msys64\ucrt64\bin\gcc.exe" --version | Select-Object -First 1
& "C:\msys64\ucrt64\bin\gdb.exe" --version | Select-Object -First 1
& "C:\msys64\ucrt64\bin\g++.exe" --version | Select-Object -First 1
& "C:\msys64\usr\bin\make.exe" --version | Select-Object -First 1
& "C:\msys64\mingw64\bin\nasm.exe" --version | Select-Object -First 1
Write-Host "Environment Setup Complete! 🚀" -ForegroundColor Green

# 8. Download and Extract Frhed
Write-Host "--------------------------------------"
$frhedUrl = "https://master.dl.sourceforge.net/project/frhed/3.%20Alpha%20Releases/1.7.1/Frhed-1.7.1-exe.7z?viasf=1"
$frhed7zPath = Join-Path $currentDir "Frhed-1.7.1-exe.7z"
$frhedExtractDir = $currentDir

Write-Host "Downloading Frhed hex editor..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13
Invoke-WebRequest -Uri $frhedUrl -OutFile $frhed7zPath -UseBasicParsing
Write-Host "Frhed downloaded successfully at $frhed7zPath" -ForegroundColor Green

$sevenZipExe = "C:\Program Files\7-Zip\7z.exe"
if (-not (Test-Path $sevenZipExe)) {
    Write-Host "7-Zip not found in default path. Please install 7-Zip or adjust the path." -ForegroundColor Yellow
} else {
    Write-Host "Extracting Frhed..." -ForegroundColor Cyan
    & "$sevenZipExe" x $frhed7zPath "-o$frhedExtractDir" -y
    Write-Host "Frhed extracted successfully to $frhedExtractDir" -ForegroundColor Green
    
    Remove-Item -Path $frhed7zPath -Force
    Write-Host "Cleanup done, .7z file removed." -ForegroundColor Green
}