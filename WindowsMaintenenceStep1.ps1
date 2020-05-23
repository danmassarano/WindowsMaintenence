function Write-Header {
    param([string]$header)
    Write-Host "############################################################`n"
    Write-Host "$header"
}

function Write-Completed {
    Write-Host "Completed"
}

# Test hard drives and review errors
Write-Header -header "Scanning hard drives for faults..."
chkdsk C:
chkdsk F:
chkdsk G:
chkdsk H:
chkdsk J:
Write-Completed

# Windows file clean
Write-Header -header "Running Disk Cleanup..."
cleanmgr /sagerun:1
Write-Completed

# Windows Update cache reset



# Temp file clean with Bleachbit