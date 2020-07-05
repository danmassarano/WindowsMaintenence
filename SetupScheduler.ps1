$config = Get-Content -Raw -Path config.json | ConvertFrom-Json
$location = Get-Location

$Argument = $location.Path + "\WindowsMaintenenceStep1.ps1"
$Trigger = New-ScheduledTaskTrigger -Weekly -WeeksInterval $config.WeeksInterval -DaysOfWeek $config.DaysOfWeek -At $config.TimeToTRun
$User = $env:UserDomain + '\' + $env:UserName
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $Argument
Register-ScheduledTask -TaskName "WindowsMaintenenceStep1" -Trigger $Trigger -User $User -Action $Action

$Argument = $location.Path + "\WindowsMaintenenceStep2.ps1"
$Trigger = New-ScheduledTaskTrigger -AtStartup
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $Argument
Register-ScheduledTask -TaskName "WindowsMaintenenceStep2" -Trigger $Trigger -User $User -Action $Action