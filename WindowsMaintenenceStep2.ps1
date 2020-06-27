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

# Check if any disks need to be fixed
if ($config.NeedsReboot -eq 1 -And $config.HasDiskErrors -eq 1)
{
    Write-Header -header "Fixing disc faults..."

    $DisksWithErrors = $config.DisksWithErrors
    $DisksWithErrors = $DisksWithErrors -split " "

    for ($i = 0; $i -lt $DisksWithErrors.length; $i++)
    {
        chkdsk $DisksWithErrors[$i] /f /r
    }
    Write-Completed

    $config | ForEach-Object {$_.HasDiskErrors=""}
    $config | ForEach-Object {$_.HasDiskErrors=0}
    $config | ConvertTo-Json -depth 32| set-content -Path config.json
    Write-Completed
    #Restart-Computer
}

# Only run if previous script has run
elseif ($config.NeedsReboot -eq 1)
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
    Remove-Item -Path "C:\ProgramData\Microsoft\Search" -Recurse
    Remove-Item -Path "HKCU:Software\Microsoft\Windows Search" -Recurse
    Remove-ItemProperty -Path "HKLM:Software\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully"
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