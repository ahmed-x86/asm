[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Set-ExecutionPolicy RemoteSigned -Scope Process -Force -ErrorAction SilentlyContinue

$msysDir = "C:\msys64"
$pacmanExe = Join-Path $msysDir "usr\bin\pacman.exe"
$currentDir = Get-Location
$destination = Join-Path $currentDir "msys2.exe"

# ----------------------------------------------------------------
# دالة التحميل المحصنة (نظام المحاولات التلقائية لتفادي أخطاء الشبكة)
# ----------------------------------------------------------------
function Download-WithCurl {
    param(
        [string]$Url,
        [string]$OutFile
    )
    $curlExe = "C:\Windows\System32\curl.exe"
    if (-not (Test-Path $curlExe)) { $curlExe = "curl.exe" }

    $maxRetries = 3
    $retryCount = 0
    $success = $false

    while (-not $success -and $retryCount -lt $maxRetries) {
        Write-Host "Downloading (Attempt $($retryCount + 1)/$maxRetries)..." -ForegroundColor Gray
        & $curlExe -L -s -o $OutFile $Url
        
        if ($LASTEXITCODE -eq 0 -and (Test-Path $OutFile)) {
            $success = $true
        } else {
            $retryCount++
            if ($retryCount -lt $maxRetries) {
                Write-Host "Network hiccup! Retrying in 2 seconds..." -ForegroundColor Yellow
                Start-Sleep -Seconds 2
            }
        }
    }

    if (-not $success) {
        throw "Curl failed to download file after $maxRetries attempts. Check your internet connection."
    }
}

# ==========================================
# الخطوة 1: تثبيت MSYS2
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 1. MSYS2 Installation" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
    if (Test-Path -Path $msysDir -PathType Container) {
        Write-Host "MSYS2 folder already exists at $msysDir. Skipping download and installation." -ForegroundColor Green
    }
    else {
        $url = "https://repo.msys2.org/distrib/msys2-x86_64-latest.exe"
        Download-WithCurl -Url $url -OutFile $destination
        Write-Host "Download completed successfully." -ForegroundColor Green

        $answer = Read-Host "Do you want to skip installing MSYS2? (y/n)"
        if ($answer.Trim().ToLower() -eq "y") {
            Write-Host "Skipping MSYS2 installation." -ForegroundColor Yellow
        }
        else {
            Write-Host "Opening MSYS2 installer..." -ForegroundColor Cyan
            Write-Host "IMPORTANT: Click Next -> Next -> Finish. Keep the default path (C:\msys64)." -ForegroundColor Yellow
            Write-Host "Waiting for you to finish the installation..." -ForegroundColor Magenta

            Start-Process -FilePath $destination -Wait

            if (-not (Test-Path $pacmanExe)) {
                throw "MSYS2 installation failed or was cancelled. pacman.exe not found."
            }
            Write-Host "MSYS2 installed successfully." -ForegroundColor Green
        }
    }
} catch {
    Write-Host "ERROR IN STEP 1: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# ==========================================
# الخطوة 2: إضافة المسارات لـ PATH
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 2. Add to PATH" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
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
        Write-Host "Paths are already configured." -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR IN STEP 2: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# ==========================================
# الخطوة 3: تحديث وتثبيت الحزم (بما فيها p7zip)
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 3. Install Pacman Packages" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
    Write-Host "Syncing pacman databases and installing packages..." -ForegroundColor Cyan
    & $pacmanExe -Sy --noconfirm
    # تمت إضافة p7zip هنا لتثبيت أداة فك الضغط الخاصة بنا
    & $pacmanExe -S --needed --noconfirm mingw-w64-i686-gcc mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-gdb mingw-w64-x86_64-nasm make p7zip
    & $pacmanExe -S --needed --noconfirm mingw-w64-x86_64-uasm --overwrite "/mingw64/bin/jwasm.exe,/mingw64/share/licenses/uasm/LICENSE"
    Write-Host "Packages installed successfully." -ForegroundColor Green
} catch {
    Write-Host "ERROR IN STEP 3: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# ==========================================
# الخطوة 4: إعداد ملفات VS Code
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 4. VS Code Setup" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
    $vscodeDir = Join-Path $currentDir ".vscode"
    $localSetupDir = Join-Path $currentDir "install-windows"
    $jsonFiles = @("c_cpp_properties.json", "launch.json", "settings.json", "tasks.json")

    if (-not (Test-Path $vscodeDir)) {
        New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
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
        Write-Host "Found local VS Code configs. Copying them..." -ForegroundColor Cyan
        foreach ($file in $jsonFiles) {
            Copy-Item -Path (Join-Path $localSetupDir $file) -Destination (Join-Path $vscodeDir $file) -Force
        }
        Write-Host "Configs copied locally." -ForegroundColor Green
    } else {
        Write-Host "Local configs missing. Downloading from GitHub..." -ForegroundColor Yellow
        $githubBaseUrl = "https://raw.githubusercontent.com/ahmed-x86/asm/refs/heads/main/install-windows/"
        
        foreach ($file in $jsonFiles) {
            $fileUrl = $githubBaseUrl + $file
            $destPath = Join-Path $vscodeDir $file
            Download-WithCurl -Url $fileUrl -OutFile $destPath
        }
        Write-Host "Configs downloaded successfully." -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR IN STEP 4: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# ==========================================
# الخطوة 5: تحميل وفك ضغط مكتبة Irvine
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 5. Irvine Library" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
    $irvineAnswer = Read-Host "Do you want to download and extract the Irvine library? (y/n)"
    if ($irvineAnswer.Trim().ToLower() -eq "y") {
        Write-Host "Downloading Irvine library..." -ForegroundColor Cyan
        $irvineUrl = "http://www.asmirvine.com/gettingStartedVS2019/Irvine.zip"
        $irvineZipPath = Join-Path $currentDir "Irvine.zip"

        Download-WithCurl -Url $irvineUrl -OutFile $irvineZipPath
        Write-Host "Extracting files..." -ForegroundColor Cyan
        
        Expand-Archive -Path $irvineZipPath -DestinationPath $currentDir -Force
        
        Remove-Item -Path $irvineZipPath -Force -ErrorAction SilentlyContinue
        Write-Host "Irvine library is ready!" -ForegroundColor Green
    } else {
        Write-Host "Skipping Irvine library." -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR IN STEP 5: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# ==========================================
# الخطوة 6: تحديث مسار launch.json
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 6. Update launch.json" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
    $launchJsonPath = Join-Path $vscodeDir "launch.json"

    if (Test-Path $launchJsonPath) {
        $launchContent = Get-Content $launchJsonPath -Raw
        $forwardSlashDir = $currentDir -replace '\\', '/'
        $launchContent = $launchContent -ireplace "c:/Users/ahmed/Downloads/asm", $forwardSlashDir
        
        Set-Content -Path $launchJsonPath -Value $launchContent -Encoding UTF8
        Write-Host "launch.json updated successfully with dynamic path." -ForegroundColor Green
    } else {
        Write-Host "launch.json not found to update. (Skipping)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ERROR IN STEP 6: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# ==========================================
# الخطوة 7: تحميل برنامج Frhed (وفك ضغطه بأداة MSYS2)
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 7. Frhed Hex Editor" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
    $frhedUrl = "https://master.dl.sourceforge.net/project/frhed/3.%20Alpha%20Releases/1.7.1/Frhed-1.7.1-exe.7z?viasf=1"
    $frhed7zPath = Join-Path $currentDir "Frhed-1.7.1-exe.7z"
    $frhedExtractDir = $currentDir

    Write-Host "Downloading Frhed hex editor..." -ForegroundColor Cyan
    Download-WithCurl -Url $frhedUrl -OutFile $frhed7zPath
    Write-Host "Frhed downloaded." -ForegroundColor Green

    # استخدام أداة 7z المدمجة التي حملناها عبر MSYS2
    $msys7zExe = "C:\msys64\usr\bin\7z.exe"
    if (-not (Test-Path $msys7zExe)) {
        Write-Host "MSYS2 7z tool not found! Make sure Step 3 completed successfully." -ForegroundColor Yellow
    } else {
        Write-Host "Extracting Frhed using MSYS2's 7z tool..." -ForegroundColor Cyan
        & "$msys7zExe" x $frhed7zPath "-o$frhedExtractDir" -y | Out-Null
        Remove-Item -Path $frhed7zPath -Force -ErrorAction SilentlyContinue
        Write-Host "Frhed extracted successfully." -ForegroundColor Green
    }
} catch {
    Write-Host "ERROR IN STEP 7: $_" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    exit
}

# ==========================================
# الخطوة 8: الاختبار النهائي والأدوات (Verification)
# ==========================================
Write-Host "--------------------------------------"
Write-Host "Verification: 8. Final Tool Check" -ForegroundColor Cyan
Write-Host "--------------------------------------"
try {
    Write-Host "Checking installed tools versions..." -ForegroundColor Yellow
    & "C:\msys64\ucrt64\bin\gcc.exe" --version | Select-Object -First 1
    & "C:\msys64\ucrt64\bin\gdb.exe" --version | Select-Object -First 1
    & "C:\msys64\ucrt64\bin\g++.exe" --version | Select-Object -First 1
    & "C:\msys64\usr\bin\make.exe" --version | Select-Object -First 1
    & "C:\msys64\mingw64\bin\nasm.exe" --version | Select-Object -First 1
    
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "🎉 ALL DONE! Environment Setup Complete! 🚀" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
} catch {
    Write-Host "ERROR IN FINAL CHECK: Some tools might not be in PATH yet." -ForegroundColor Red
}

Write-Host "`nScript execution finished."
Read-Host "Press Enter to exit safely..."