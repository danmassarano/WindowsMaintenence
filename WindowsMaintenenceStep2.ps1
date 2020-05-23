function Write-Header {
    param([string]$header)
    Write-Host "############################################################`n"
    Write-Host "$header"
}

function Write-Completed {
    Write-Host "Completed"
}

# DISM RestoreHealth
Write-Header -header "Checking Windows image..."
DISM /Online /Cleanup-Image /RestoreHealth
Write-Completed

# WinSxS cleanup ResetBase
Write-Header -header "Cleaning up WinSxS..."
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase
Write-Completed

# Windows Search purge and re-initialization
Write-Header -header "Purging Windows Search..."
net stop WSearch
Remove-Item /S /Q "C:\ProgramData\Microsoft\Search"
Remove-Item -Path "HKCU:Software\Microsoft\Windows Search" -Recurse
Remove-ItemProperty -Path "HKLM:Software\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully" -WhatIf
Write-Completed

# Update Drivers

# Defragmentation