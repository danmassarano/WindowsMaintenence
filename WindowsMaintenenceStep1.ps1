function Get-TimeStamp {
    
    return "[{0:dd-MMM-yy} {0:HH:mm:ss}]" -f (Get-Date)
    
}

function Write-Log {
    param([string]$content)
    Write-Host "$content"
    Write-Output "$(Get-TimeStamp) $content" | Out-file log.txt -append
}

function Write-Header {
    param([string]$header)
    Write-Log -content "############################################################`n"
    Write-Log -content "$header"
}

function Write-Completed {
    Write-Log -content "Completed"
}

# Import config file for input variables for script
Write-Header -header "Importing configuration..."
$config = Get-Content -Raw -Path config.json | ConvertFrom-Json
Write-Completed

# Test hard drives and review errors
Write-Header -header "Scanning hard drives for faults..."

$SystemDrives = $config.SystemDrives
$DataDrives = $config.DataDrives
$SystemDrives = $SystemDrives -split " "
$DataDrives = $DataDrives -split " "
$Drives = $SystemDrives + $DataDrives

$DisksWithErrors = ""

for ($i = 0; $i -lt $Drives.length; $i++)
{
    chkdsk $Drives[$i]
    
    if($LASTEXITCODE -gt 1)
    {
        $message = $Drives[$i] + "\ Completed with errors"
        Write-Log -content $message
        $config | ForEach-Object {$_.HasDiskErrors=1}
        $DisksWithErrors += " "
        $DisksWithErrors += $Drives[$i]
    }
    $config | ForEach-Object {$_.DisksWithErrors=$DisksWithErrors}
}

Write-Completed

# Windows file clean
Write-Header -header "Running Disk Cleanup..."
cleanmgr /sagerun:1
Write-Completed

# Windows Update cache reset
Write-Header -header "Resetting Windows Update cache..."
Get-Service -DisplayName "Background Intelligent Transfer Service" | Stop-Service
Get-Service -DisplayName "Windows Update" | Stop-Service
Remove-Item -path C:\Windows\SoftwareDistribution -Recurse
Write-Completed

# Temp file clean with Bleachbit
Write-Header -header "Bleachit is cleaning up temp files..."
bleachbit_console.exe --clean flash.* internet_explorer.* firefox.* system.logs system.memory_dump system.recycle_bin system.tmp
Write-Completed

# Reboot on completion and flag that next step needs to run
$config | ForEach-Object {$_.NeedsReboot=1}
$config | ConvertTo-Json -depth 32| set-content -Path config.json
#Restart-Computer