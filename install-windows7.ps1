# Set Execution Policy to bypass for the current process
Set-ExecutionPolicy Bypass -Scope Process -Force

# Enable TLS 1.2 for modern web downloads (Crucial for Windows 7/PS 2.0)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Path configurations
$msysDir = "C:\msys64"
$pacmanExe = "$msysDir\usr\bin\pacman.exe"
$currentDir = Get-Location.Path
$destination = "$currentDir\msys2.exe"
$pathDoneFile = "$currentDir\add-to-path.txt"
$webClient = New-Object System.Net.WebClient

Write-Host "Checking for existing MSYS2 installation..." -ForegroundColor Cyan

# Step 0: Check if MSYS2 is already installed
if (Test-Path $pacmanExe) {
    Write-Host "MSYS2 is already installed in $msysDir. Skipping download!" -ForegroundColor Green
} else {
    # Step 1: Download MSYS2 (Using a direct link as PS 2.0 cannot easily parse GitHub JSON)
    Write-Host "Downloading MSYS2 installer..." -ForegroundColor Cyan
    $url = "https://repo.msys2.org/distrib/msys2-x86_64-latest.exe"
    
    try {
        $webClient.DownloadFile($url, $destination)
        Write-Host "Download complete." -ForegroundColor Green
    } catch {
        Write-Host "Download failed. Please check your internet connection." -ForegroundColor Red
        exit
    }

    $answer = Read-Host "Do you want to install MSYS2 now? (y/n)"
    if ($answer.Trim().ToLower() -eq "y") {
        Write-Host "Starting installer. Please complete the wizard manually." -ForegroundColor Cyan
        $process = Start-Process -FilePath $destination -Wait
    }
}

# Step 2: Add MSYS2 Binaries to System PATH
if (-not (Test-Path $pathDoneFile)) {
    Write-Host "Adding MSYS2 directories to PATH..." -ForegroundColor Cyan
    $pathsToAdd = @("C:\msys64\usr\bin", "C:\msys64\mingw64\bin", "C:\msys64\mingw32\bin", "C:\msys64\ucrt64\bin")
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    
    foreach ($p in $pathsToAdd) {
        if ($currentPath -notlike "*$p*") {
            $currentPath = "$currentPath;$p"
        }
    }
    
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
    $env:Path = $currentPath
    Set-Content -Path $pathDoneFile -Value "1"
    Write-Host "Paths added successfully." -ForegroundColor Green
}

# Step 3: Update Pacman and Install Assembly Tools
Write-Host "--------------------------------------"
$installPackagesAnswer = Read-Host "Install MSYS2 packages (gcc, gdb, nasm, make, uasm)? (y/n)"
if ($installPackagesAnswer.Trim().ToLower() -eq "y") {
    if (Test-Path $pacmanExe) {
        Write-Host "Syncing databases..." -ForegroundColor Cyan
        & $pacmanExe -Sy --noconfirm
        & $pacmanExe -S --noconfirm mingw-w64-i686-gcc mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb mingw-w64-x86_64-nasm make p7zip
        & $pacmanExe -S --noconfirm mingw-w64-x86_64-uasm --overwrite "/mingw64/bin/jwasm.exe,/mingw64/share/licenses/uasm/LICENSE"
        Write-Host "Packages installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Error: Pacman not found at $pacmanExe" -ForegroundColor Red
    }
}

# Step 4: VS Code Environment Configuration
Write-Host "Setting up VS Code environment..." -ForegroundColor Cyan
$vscodeDir = "$currentDir\.vscode"
if (-not (Test-Path $vscodeDir)) { [Void](New-Item -ItemType Directory -Path $vscodeDir) }

$jsonFiles = @("c_cpp_properties.json", "launch.json", "settings.json", "tasks.json")
$githubBaseUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows/"

foreach ($file in $jsonFiles) {
    Write-Host "Downloading $file..." -ForegroundColor Gray
    $webClient.DownloadFile(($githubBaseUrl + $file), "$vscodeDir\$file")
}

# Step 5: Download and Extract Irvine32 Library (Legacy method for ZIP)
Write-Host "--------------------------------------"
$irvineAnswer = Read-Host "Download and extract Irvine library? (y/n)"
if ($irvineAnswer.Trim().ToLower() -eq "y") {
    $irvineZip = "$currentDir\Irvine.zip"
    Write-Host "Downloading Irvine.zip..." -ForegroundColor Cyan
    $webClient.DownloadFile("http://www.asmirvine.com/gettingStartedVS2019/Irvine.zip", $irvineZip)
    
    Write-Host "Extracting ZIP..." -ForegroundColor Cyan
    $shell = New-Object -ComObject Shell.Application
    $zipFile = $shell.NameSpace($irvineZip)
    $destFolder = $shell.NameSpace($currentDir)
    $destFolder.CopyHere($zipFile.Items(), 0x10)
    
    Remove-Item $irvineZip -Force
    Write-Host "Irvine library is ready!" -ForegroundColor Green
}

# Step 7: Update launch.json dynamic paths
$launchJsonPath = "$vscodeDir\launch.json"
if (Test-Path $launchJsonPath) {
    $launchContent = [IO.File]::ReadAllText($launchJsonPath)
    $forwardSlashDir = $currentDir -replace '\\', '/'
    $launchContent = $launchContent.Replace("c:/Users/ahmed/Downloads/asm", $forwardSlashDir)
    [IO.File]::WriteAllText($launchJsonPath, $launchContent)
}

# Step 8: Verify Installation
Write-Host "--------------------------------------"
Write-Host "Verification:" -ForegroundColor Cyan
if (Test-Path "C:\msys64\ucrt64\bin\gcc.exe") {
    & "C:\msys64\ucrt64\bin\gcc.exe" --version | Select-Object -First 1
}
Write-Host "Environment Setup Complete!" -ForegroundColor Green

# Step 9: Download Frhed Hex Editor
Write-Host "--------------------------------------"
$frhedAnswer = Read-Host "Download Frhed Hex Editor? (y/n)"
if ($frhedAnswer.Trim().ToLower() -eq "y") {
    $frhedDestFolder = "C:\Frhed-1.7.1-exe"
    $dirsToCreate = @($frhedDestFolder, "$frhedDestFolder\Docs", "$frhedDestFolder\Languages")
    foreach ($dir in $dirsToCreate) { if (-not (Test-Path $dir)) { [Void](New-Item -ItemType Directory -Path $dir -Force) } }

    $githubFrhedUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/main/Frhed_Folder/Frhed-1.7.1-exe/"
    $filesToDownload = @("Frhed.exe", "heksedit.dll", "RAWIO32.dll", "Docs/ChangeLog.txt", "Docs/Contributors.txt", "Docs/Frhed.chm", "Docs/GPL.txt", "Docs/History.txt", "Languages/de.po", "Languages/fr.po", "Languages/heksedit.lng", "Languages/nl.po")

    foreach ($file in $filesToDownload) {
        $cleanName = $file -replace '/', '\'
        Write-Host " -> Fetching $file..." -ForegroundColor Gray
        $webClient.DownloadFile(($githubFrhedUrl + $file), "$frhedDestFolder\$cleanName")
    }
}

# Step 10: Configure Alias for Frhed
$exePath = "C:\Frhed-1.7.1-exe\Frhed.exe"
if (Test-Path $exePath) {
    $profilePath = $PROFILE
    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) { [Void](New-Item -Type Directory -Path $profileDir -Force) }
    
    $aliasContent = "`nfunction ghex { & `"$exePath`" `$args }"
    if (-not (Test-Path $profilePath) -or (Get-Content $profilePath) -notmatch "function ghex") {
        Add-Content -Path $profilePath -Value $aliasContent
    }
    Write-Host "Alias 'ghex' added to profile." -ForegroundColor Magenta
}

# Step 11: Download ASM Examples using WebClient
Write-Host "--------------------------------------"
$downloadExamples = Read-Host "Download example Assembly files? (y/n)"
if ($downloadExamples.Trim().ToLower() -eq "y") {
    $exampleUrls = @(
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux64_start.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux64_main.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux32_start.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/linux32_main.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_std_start.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_std_main.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win64_std_start.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win64_std_main.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_irvine_start.asm",
        "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/win32_irvine_main.asm"
    )
    foreach ($url in $exampleUrls) {
        $fileName = $url.Split('/')[-1]
        Write-Host " -> Fetching $fileName..." -ForegroundColor Gray
        $webClient.DownloadFile($url, "$currentDir\$fileName")
    }
}

Write-Host "--------------------------------------"
Write-Host "ALL DONE! Assembly Environment Ready! " -ForegroundColor Magenta
Write-Host "--------------------------------------"