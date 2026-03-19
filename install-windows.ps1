# Set Execution Policy to bypass for the current process to ensure the script runs without errors
Set-ExecutionPolicy Bypass -Scope Process -Force

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Initial path configurations
$msysDir = "C:\msys64"
$pacmanExe = Join-Path $msysDir "usr\bin\pacman.exe"
$currentDir = Get-Location
$destination = Join-Path $currentDir "msys2.exe"
$pathDoneFile = Join-Path $currentDir "add-to-path.txt"

Write-Host "Checking for existing MSYS2 installation..." -ForegroundColor Cyan

# Step 0: Check if MSYS2 is already installed
if (Test-Path $pacmanExe) {
    Write-Host "MSYS2 is already installed in $msysDir. Skipping download and installation!" -ForegroundColor Green
} else {
    # Step 1: Download and Install MSYS2
    Write-Host "Fetching the latest MSYS2 download link from GitHub..." -ForegroundColor Cyan
    $releaseData = Invoke-RestMethod -Uri "https://api.github.com/repos/msys2/msys2-installer/releases/latest"
    $url = $releaseData.assets | Where-Object { $_.name -match "^msys2-x86_64-\d+\.exe$" } | Select-Object -ExpandProperty browser_download_url

    if (-not $url) {
        $url = "https://repo.msys2.org/distrib/msys2-x86_64-latest.exe"
    }

    Write-Host "Downloading MSYS2..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $url -OutFile $destination

    $answer = Read-Host "Do you want to install MSYS2 now? (y/n)"
    if ($answer.Trim().ToLower() -eq "y") {
        Write-Host "Installing MSYS2... please wait for the wizard to finish." -ForegroundColor Cyan
        Start-Process -FilePath $destination -ArgumentList "in --confirm-command --accept-messages --root $msysDir" -Wait
    }
}

# Step 2: Add MSYS2 Binaries to System PATH
if (-not (Test-Path $pathDoneFile)) {
    Write-Host "Adding MSYS2 directories to PATH..." -ForegroundColor Cyan
    $pathsToAdd = @("C:\msys64\usr\bin", "C:\msys64\mingw64\bin", "C:\msys64\mingw32\bin", "C:\msys64\ucrt64\bin")
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    foreach ($p in $pathsToAdd) {
        if (-not ($currentPath -split ";" | Where-Object { $_ -eq $p })) { $currentPath += ";$p" }
    }
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
    $env:Path = $currentPath
    Set-Content -Path $pathDoneFile -Value "1"
    Write-Host "Paths added successfully." -ForegroundColor Green
}

# Step 3: Update Pacman and Install Assembly Tools
Write-Host "--------------------------------------"
$installPackagesAnswer = Read-Host "Do you want to install required MSYS2 packages (gcc, gdb, nasm, make, uasm)? (y/n)"
if ($installPackagesAnswer.Trim().ToLower() -eq "y") {
    Write-Host "Syncing pacman databases and installing packages..." -ForegroundColor Cyan
    & $pacmanExe -Sy --noconfirm
    & $pacmanExe -S --noconfirm mingw-w64-i686-gcc mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb mingw-w64-x86_64-nasm make p7zip
    & $pacmanExe -S --noconfirm mingw-w64-x86_64-uasm --overwrite "/mingw64/bin/jwasm.exe,/mingw64/share/licenses/uasm/LICENSE"
    Write-Host "Packages installed successfully!" -ForegroundColor Green
}

# Step 4: VS Code Environment Configuration
Write-Host "Setting up VS Code environment..." -ForegroundColor Cyan
$vscodeDir = Join-Path $currentDir ".vscode"
if (-not (Test-Path $vscodeDir)) { New-Item -ItemType Directory -Path $vscodeDir | Out-Null }
$jsonFiles = @("c_cpp_properties.json", "launch.json", "settings.json", "tasks.json")
$githubBaseUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows/"

foreach ($file in $jsonFiles) {
    Write-Host "Downloading $file..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri ($githubBaseUrl + $file) -OutFile (Join-Path $vscodeDir $file)
}

# Step 5: Download and Extract Irvine32 Library
Write-Host "--------------------------------------"
$irvineAnswer = Read-Host "Do you want to download and extract the Irvine library? (y/n)"
if ($irvineAnswer.Trim().ToLower() -eq "y") {
    $irvineUrl = "http://www.asmirvine.com/gettingStartedVS2019/Irvine.zip"
    Invoke-WebRequest -Uri $irvineUrl -OutFile (Join-Path $currentDir "Irvine.zip")
    Expand-Archive -Path (Join-Path $currentDir "Irvine.zip") -DestinationPath $currentDir -Force
    Remove-Item -Path (Join-Path $currentDir "Irvine.zip") -Force
    Write-Host "Irvine library is ready!" -ForegroundColor Green
}

# Step 7: Update launch.json dynamic paths
$launchJsonPath = Join-Path $vscodeDir "launch.json"
if (Test-Path $launchJsonPath) {
    $launchContent = Get-Content $launchJsonPath -Raw
    $forwardSlashDir = $currentDir -replace '\\', '/'
    $launchContent = $launchContent -ireplace "c:/Users/ahmed/Downloads/asm", $forwardSlashDir
    Set-Content -Path $launchJsonPath -Value $launchContent -Encoding UTF8
}

# Step 8: Verify Installation of Main Tools
Write-Host "--------------------------------------"
Write-Host "Step 8: Verify Installation of Main Tools" -ForegroundColor Magenta
Write-Host "--------------------------------------"
Write-Host "Verification:" -ForegroundColor Cyan
& "C:\msys64\ucrt64\bin\gcc.exe" --version | Select-Object -First 1
& "C:\msys64\mingw64\bin\nasm.exe" --version | Select-Object -First 1
& "C:\msys64\mingw64\bin\uasm.exe" --version | Select-Object -First 1
& "C:\msys64\mingw64\bin\make.exe" --version | Select-Object -First 1
Write-Host "Environment Setup Complete! 🚀" -ForegroundColor Green

# Step 9: Download Frhed Hex Editor (Directly from GitHub)
Write-Host "--------------------------------------"
Write-Host "Step 9: Download Frhed Hex Editor (Directly from GitHub)" -ForegroundColor Magenta
Write-Host "--------------------------------------"
$frhedAnswer = Read-Host "Do you want to download and setup Frhed Hex Editor? (y/n)"
if ($frhedAnswer.Trim().ToLower() -eq "y") {
    $frhedDestFolder = "C:\Frhed-1.7.1-exe"
    $dirsToCreate = @($frhedDestFolder, "$frhedDestFolder\Docs", "$frhedDestFolder\Languages")
    foreach ($dir in $dirsToCreate) { if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null } }

    $githubFrhedUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/main/Frhed_Folder/Frhed-1.7.1-exe/"
    $filesToDownload = @("Frhed.exe", "heksedit.dll", "RAWIO32.dll", "Docs/ChangeLog.txt", "Docs/Contributors.txt", "Docs/Frhed.chm", "Docs/GPL.txt", "Languages/de.po", "Languages/fr.po", "Languages/heksedit.lng", "Languages/nl.po")

    foreach ($file in $filesToDownload) {
        Write-Host " -> Fetching $file..." -ForegroundColor Gray
        Invoke-WebRequest -Uri ($githubFrhedUrl + $file) -OutFile (Join-Path $frhedDestFolder ($file -replace '/', '\')) -UseBasicParsing
    }
    Write-Host "Frhed installed successfully!" -ForegroundColor Green
}

# Step 10: Configure PowerShell Alias for Frhed
Write-Host "--------------------------------------"
Write-Host "tep 10: Configure PowerShell Alias for Frhed" -ForegroundColor Magenta
Write-Host "--------------------------------------"
$exePath = "C:\Frhed-1.7.1-exe\Frhed.exe"
if (Test-Path $exePath) {
    $profilePath = $PROFILE
    if (-not (Test-Path (Split-Path $profilePath))) { New-Item -Type Directory -Path (Split-Path $profilePath) -Force | Out-Null }
    $aliasContent = "`nfunction ghex { & `"$exePath`" `$args }"
    if (-not (Test-Path $profilePath) -or (Get-Content $profilePath -Raw) -notmatch "function ghex") {
        Add-Content -Path $profilePath -Value $aliasContent -Encoding UTF8
        Invoke-Expression $aliasContent
    }
    Write-Host "Step 10 completed! 'ghex' alias is now active." -ForegroundColor Magenta
}

# Step 11: Download ASM Examples using Native curl.exe
Write-Host "--------------------------------------"
Write-Host "Step 11: Download ASM Examples using Native curl.exe" -ForegroundColor Magenta
Write-Host "--------------------------------------"
$downloadExamples = Read-Host "Do you want to download example Assembly files? (y/n)"
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
        Write-Host " -> Fetching $fileName via curl..." -ForegroundColor Gray
        & curl.exe -L -o (Join-Path $currentDir $fileName) $url
    }
}

Write-Host "--------------------------------------"
Write-Host "🎉 ALL DONE! Your Ultimate Assembly Environment is 100% Ready! 🚀" -ForegroundColor Magenta
Write-Host "--------------------------------------"