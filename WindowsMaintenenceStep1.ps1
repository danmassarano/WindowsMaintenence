function Write-Header {
    param([string]$header)
    Write-Host "############################################################`n"
    Write-Host "$header"
}

function Write-Completed {
    Write-Host "Completed"
}

# Import config file for input variables for script
Write-Header -header "Importing configuration..."
$config = Get-Content -Raw -Path config.json | ConvertFrom-Json
Write-Completed

# Test hard drives and review errors
# TODO: Add logging - so that all issues are tracked in a log file
# TODO: If any issues are found when testing hard drives, reboot later and run full disk check with ```chkdsk /f /r```
Write-Header -header "Scanning hard drives for faults..."

$SystemDrives = $config.SystemDrives
$DataDrives = $config.DataDrives
$SystemDrives = $SystemDrives -split " "
$DataDrives = $DataDrives -split " "
$Drives = $SystemDrives + $DataDrives

for ($i = 0; $i -lt $Drives.length; $i++)
{
	Write-Host chkdsk $Drives[$i]
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
