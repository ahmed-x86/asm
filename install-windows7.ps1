# --- Configuration & Variables Section ---
$msysDir = "C:\msys64"
$pacmanExe = "$msysDir\usr\bin\pacman.exe"
$currentDir = (Get-Location).Path
$destination = "$currentDir\msys2.exe"
$pathDoneFile = "$currentDir\add-to-path.txt"
$msys2Url = "https://repo.msys2.org/distrib/msys2-x86_64-latest.exe"

$vscodeDir = "$currentDir\.vscode"
$jsonFiles = @("c_cpp_properties.json", "launch.json", "settings.json", "tasks.json")
$githubBaseUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows/"

$irvineZip = "$currentDir\Irvine.zip"
$irvineUrl = "http://www.asmirvine.com/gettingStartedVS2019/Irvine.zip"

$frhedDestFolder = "C:\Frhed-1.7.1-exe"
$githubFrhedUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/main/Frhed_Folder/Frhed-1.7.1-exe/"
$filesToDownload = @("Frhed.exe", "heksedit.dll", "RAWIO32.dll", "Docs/ChangeLog.txt", "Docs/Contributors.txt", "Docs/Frhed.chm", "Docs/GPL.txt", "Languages/de.po", "Languages/fr.po", "Languages/heksedit.lng", "Languages/nl.po")
$exePath = "$frhedDestFolder\Frhed.exe"

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

$msysBinDir = "C:\msys64\usr\bin"
$targetPath = "$msysBinDir\asm-run.exe"
$urlAsmRun = "https://github.com/ahmed-x86/asm/raw/refs/heads/main/asm-run.exe"

# --- Script Logic Starts Here ---

# Set Execution Policy to bypass for the current process
Set-ExecutionPolicy Bypass -Scope Process -Force

# Enable TLS 1.2 for modern web downloads (Crucial for Windows 7/PS 2.0)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Initialize WebClient for legacy downloads
$webClient = New-Object System.Net.WebClient

Write-Host "--------------------------------------"
Write-Host "Step 1: Download and Install MSYS2" -ForegroundColor Magenta
Write-Host "--------------------------------------"
Write-Host "Checking for existing MSYS2 installation..." -ForegroundColor Cyan

# Step 0/1: Check and Download MSYS2
if (Test-Path $pacmanExe) {
    Write-Host "MSYS2 is already installed in $msysDir. Skipping download!" -ForegroundColor Green
} else {

    Write-Host "Downloading MSYS2 installer..." -ForegroundColor Cyan

    try {
        $webClient.DownloadFile($msys2Url, $destination)
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
Write-Host "--------------------------------------"
Write-Host "Step 2: Add MSYS2 Binaries to System PATH" -ForegroundColor Magenta
Write-Host "--------------------------------------"
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
Write-Host "Step 3: Update Pacman and Install Assembly Tools" -ForegroundColor Magenta
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
Write-Host "--------------------------------------"
Write-Host "Step 4: VS Code Environment Configuration" -ForegroundColor Magenta
Write-Host "--------------------------------------"
Write-Host "Setting up VS Code environment..." -ForegroundColor Cyan

if (-not (Test-Path $vscodeDir)) { [Void](New-Item -ItemType Directory -Path $vscodeDir) }



foreach ($file in $jsonFiles) {
    Write-Host "Downloading $file..." -ForegroundColor Gray
    $webClient.DownloadFile(($githubBaseUrl + $file), "$vscodeDir\$file")
}

# Step 5: Download and Extract Irvine32 Library (Legacy method for ZIP)
Write-Host "--------------------------------------"
Write-Host "Step 5: Download and Extract Irvine32 Library" -ForegroundColor Magenta
Write-Host "--------------------------------------"
$irvineAnswer = Read-Host "Download and extract Irvine library? (y/n)"

if ($irvineAnswer.Trim().ToLower() -eq "y") {

    Write-Host "Downloading Irvine.zip..." -ForegroundColor Cyan
    $webClient.DownloadFile($irvineUrl, $irvineZip)
    
    Write-Host "Extracting ZIP..." -ForegroundColor Cyan
    $shell = New-Object -ComObject Shell.Application
    $zipFile = $shell.NameSpace($irvineZip)
    $destFolder = $shell.NameSpace($currentDir)
    $destFolder.CopyHere($zipFile.Items(), 0x10)
    
    Remove-Item $irvineZip -Force
    Write-Host "Irvine library is ready!" -ForegroundColor Green
}

# Step 7: Update launch.json dynamic paths (Note: Skipped step 6 in Win7 version)
Write-Host "--------------------------------------"
Write-Host "Step 7: Update launch.json dynamic paths" -ForegroundColor Magenta
Write-Host "--------------------------------------"
$launchJsonPath = "$vscodeDir\launch.json"
if (Test-Path $launchJsonPath) {
    $launchContent = [IO.File]::ReadAllText($launchJsonPath)
    $forwardSlashDir = $currentDir -replace '\\', '/'
    $launchContent = $launchContent.Replace("c:/Users/ahmed/Downloads/asm", $forwardSlashDir)
    [IO.File]::WriteAllText($launchJsonPath, $launchContent)
    Write-Host "launch.json paths updated." -ForegroundColor Green
}

# Step 8: Verify Installation
Write-Host "--------------------------------------"
Write-Host "Step 8: Verify Installation of Main Tools" -ForegroundColor Magenta
Write-Host "--------------------------------------"
Write-Host "Verification:" -ForegroundColor Cyan
if (Test-Path "C:\msys64\ucrt64\bin\gcc.exe") {
    & "C:\msys64\ucrt64\bin\gcc.exe" --version | Select-Object -First 1
}
Write-Host "Environment Setup Complete!" -ForegroundColor Green

# Step 9: Download Frhed Hex Editor
Write-Host "--------------------------------------"
Write-Host "Step 9: Download Frhed Hex Editor" -ForegroundColor Magenta
Write-Host "--------------------------------------"
$frhedAnswer = Read-Host "Download Frhed Hex Editor? (y/n)"
if ($frhedAnswer.Trim().ToLower() -eq "y") {

    $dirsToCreate = @($frhedDestFolder, "$frhedDestFolder\Docs", "$frhedDestFolder\Languages")
    foreach ($dir in $dirsToCreate) { if (-not (Test-Path $dir)) { [Void](New-Item -ItemType Directory -Path $dir -Force) } }


    foreach ($file in $filesToDownload) {
        $cleanName = $file -replace '/', '\'
        Write-Host " -> Fetching $file..." -ForegroundColor Gray
        $webClient.DownloadFile(($githubFrhedUrl + $file), "$frhedDestFolder\$cleanName")
    }
    Write-Host "Frhed installed successfully!" -ForegroundColor Green
}

# Step 10: Configure Alias for Frhed
Write-Host "--------------------------------------"
Write-Host "Step 10: Configure PowerShell Alias for Frhed" -ForegroundColor Magenta
Write-Host "--------------------------------------"
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
Write-Host "Step 11: Download ASM Examples" -ForegroundColor Magenta
Write-Host "--------------------------------------"
$downloadExamples = Read-Host "Download example Assembly files? (y/n)"
if ($downloadExamples.Trim().ToLower() -eq "y") {

    foreach ($url in $exampleUrls) {
        $fileName = $url.Split('/')[-1]
        Write-Host " -> Fetching $fileName..." -ForegroundColor Gray
        $webClient.DownloadFile($url, "$currentDir\$fileName")
    }
}

# Step 12: Setup asm-run command
Write-Host "--------------------------------------"
Write-Host "Step 12: Setup asm-run command" -ForegroundColor Magenta
Write-Host "--------------------------------------"
Write-Host "Setting up 'asm-run' for Windows CLI..." -ForegroundColor Cyan

if (-not (Test-Path $msysBinDir)) {
    Write-Host "Warning: MSYS2 bin directory not found at $msysBinDir. Creating it..." -ForegroundColor Yellow
    [Void](New-Item -ItemType Directory -Path $msysBinDir -Force)
}

if (Test-Path "$currentDir\asm-run.exe") {
    Write-Host "Found local asm-run.exe. Copying to $targetPath..." -ForegroundColor Gray
    try {
        Copy-Item -Path "$currentDir\asm-run.exe" -Destination $targetPath -Force -ErrorAction Stop
        Write-Host "Copied successfully! ✅" -ForegroundColor Green
    } catch {
        Write-Host "Error: Could not copy file. Try running PowerShell as Administrator. ❌" -ForegroundColor Red
    }
} else {
    Write-Host "Local asm-run.exe not found. Downloading from GitHub..." -ForegroundColor Gray
    try {
        $webClient.DownloadFile($urlAsmRun, $targetPath)
        Write-Host "Downloaded successfully to $targetPath! ✅" -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to download asm-run.exe. Check your internet connection. ❌" -ForegroundColor Red
    }
}

if (Test-Path $targetPath) {
    Write-Host "Verification: asm-run.exe is now globally accessible. ✨" -ForegroundColor Green
    Write-Host "Now you can type the 'asm-run' command from any terminal followed by your .asm file." -ForegroundColor Cyan
}

Write-Host "--------------------------------------"
Write-Host "🎉 ALL DONE! Your Windows 7 Assembly Environment is 100% Ready! 🚀" -ForegroundColor Magenta
Write-Host "--------------------------------------"