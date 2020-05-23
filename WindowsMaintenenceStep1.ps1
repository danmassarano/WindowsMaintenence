function Write-Header {
    param([string]$header)
    Write-Host "############################################################`n"
    Write-Host "$header"
}

function Write-Completed {
    Write-Host "Completed"
}

# Test hard drives and review errors
# TODO: Refactor into a loop that checks for all drives
# TODO: Add logging - so that all issues are tracked in a log file
# TODO: If any issues are found, reboot later and run full disk check with ```chkdsk /f /r```
Write-Header -header "Scanning hard drives for faults..."
chkdsk C:
chkdsk F:
chkdsk G:
chkdsk H:
chkdsk J:
Write-Completed

# Windows file clean
# TODO: Find way of setting up preset profile automatically, or having settings in a config file
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

# Reboot on completion
#Restart-Computer