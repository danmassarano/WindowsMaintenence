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

# Only run if previous script has run
if ($config == 1)
{
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

    # Reset run status
    $config | ForEach-Object {$_.NeedsReboot=0}
    $config | ConvertTo-Json -depth 32| set-content -Path config.json

    # TODO: Update Drivers

    # Defragmentation
    if ($config.DataDrives.length -gt 0)
    {
        $DataDrives = $config.DataDrives
        $DataDrives = $DataDrives -split " "
    
        for ($i = 0; $i -lt $DataDrives.length; $i++)
        {
            $DataDrives[$i] = "-v " + $DataDrives[$i]
        }
    
        $Defrag = $DataDrives -join ' '
    
        MyDefrag.exe -r DataDiskWeekly.MyD $Defrag
    }
}