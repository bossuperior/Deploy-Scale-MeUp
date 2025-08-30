# PowerShell script to install k6, run the load test, and keep the window open

# Function to check if k6 is installed
function Test-K6Installed {
    try {
        $k6Version = k6 version 2>&1
        Write-Host "k6 is already installed: $k6Version"
        return $true
    } catch {
        Write-Host "k6 is not installed."
        return $false
    }
}

# Function to check if running as admin (Windows only)
function Test-IsAdmin {
    if ($IsWin) {
        $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    return $false
}

# Function to install Chocolatey (Windows only)
function Install-Chocolatey {
    Write-Host "Installing Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installed successfully."
    } catch {
        Write-Host "Failed to install Chocolatey: $_"
        Write-Host "Please install Chocolatey manually: https://chocolatey.org/install"
        exit 1
    }
}

# Function to install k6 (platform-specific)
function Install-K6 {
    if ($IsWin) {
        # Check for admin privileges on Windows
        if (-not (Test-IsAdmin)) {
            Write-Host "ERROR: Installing k6 via Chocolatey requires administrative privileges."
            Write-Host "Please run this script as Administrator (right-click PowerShell and select 'Run as Administrator')."
            exit 1
        }
        Write-Host "Installing k6 via Chocolatey..."
        choco install k6 -y
        if ($LASTEXITCODE -eq 0) {
            Write-Host "k6 installed successfully."
        } else {
            Write-Host "Failed to install k6. Please install k6 manually: https://k6.io/docs/getting-started/installation/"
            exit 1
        }
    } elseif ($IsMac) {
        Write-Host "Installing k6 on macOS using Homebrew..."
        try {
            brew install k6
            Write-Host "k6 installed successfully."
        } catch {
            Write-Host "Failed to install k6. Ensure Homebrew is installed and try again: https://brew.sh/"
            Write-Host "Alternatively, install k6 manually: https://k6.io/docs/getting-started/installation/"
            exit 1
        }
    } elseif ($IsLin) {
        Write-Host "Installing k6 on Linux..."
        Write-Host "Please install k6 manually using the instructions for your distribution: https://k6.io/docs/getting-started/installation/"
        Write-Host "For example, on Debian/Ubuntu, you can use:"
        Write-Host "  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5AD17C747825496"
        Write-Host "  echo 'deb https://dl.k6.io/deb stable main' | sudo tee /etc/apt/sources.list.d/k6.list"
        Write-Host "  sudo apt-get update && sudo apt-get install k6"
        exit 1
    } else {
        Write-Host "Unsupported operating system. Please install k6 manually: https://k6.io/docs/getting-started/installation/"
        exit 1
    }
}

# Main script
Write-Host "Starting k6 load test setup at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')..."

# Detect operating system
$IsWin = $PSVersionTable.Platform -eq "Win32NT" -or $PSVersionTable.PSEdition -eq "Desktop"
$IsMac = $PSVersionTable.Platform -eq "Unix" -and (uname -s) -eq "Darwin"
$IsLin = $PSVersionTable.Platform -eq "Unix" -and (uname -s) -eq "Linux"

# Check if k6 is installed
if (-not (Test-K6Installed)) {
    if ($IsWin) {
        # Check if Chocolatey is installed
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Install-Chocolatey
        } else {
            Write-Host "Chocolatey is already installed."
        }
    }
    Install-K6
} else {
    Write-Host "Skipping k6 installation as it is already present."
}

# Check if K6_LoadingTest.js exists
if (-not (Test-Path -Path "K6_LoadingTest.js")) {
    Write-Host "ERROR: K6_LoadingTest.js not found in the current directory."
    Write-Host "Please ensure the script file is present and try again."
    Read-Host -Prompt "Press Enter to exit"
    exit 1
}

# Run the k6 command
Write-Host "Running k6 load test..."
$k6Command = "k6 run -e BASE_URL=http://scalemeup-node-alb-609231817.ap-southeast-1.elb.amazonaws.com -e PATH=/api/posts -o json=results.json K6_LoadingTest.js"
try {
    Invoke-Expression $k6Command
    if ($LASTEXITCODE -eq 0) {
        Write-Host "k6 load test completed successfully. Results saved to results.json."
    } else {
        Write-Host "k6 load test failed. Check the output above for details."
    }
} catch {
    Write-Host "An error occurred while running k6: $_"
}

# Keep the window open
Write-Host "`nNote: The --summary-export flag was omitted as it is not a standard k6 option. Check results.json or console output for summary metrics."
Read-Host -Prompt "Press Enter to exit"