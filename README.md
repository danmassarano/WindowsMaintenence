# Windows Maintenance

## Overview

Automate some basic maintenance processes for Windows 10

I do some basic maintenance checks on my PC every few months, mostly a manual process that's time consuming so I'm looking to automate it as much as possible.

I've been working off [this guide on Decent Security](https://decentsecurity.com/#/holiday-tasks/), and working to automate as many of them as possible. Some will still have to remain manual, but we'll see how it goes.

## Maintenance Steps

Out of order from that guide, I'm going with what I can automate first, then figuring out the rest as I go. The ones crossed out are already implemented.

* Test hard drive and review errors
* Junk programs uninstall
* Windows files clean with cleanmgr.exe
* Windows Update cache reset
* Temp file clean with Bleachbit
* ~~Fast virus scan~~
* Malware/Junkware checkup
* ~~Check Windows Update and Firewall~~
* DISM RestoreHealth (Windows 8+)
* ~~Install Windows updates and configure automatic update~~
* WinSxS cleanup ResetBase (Windows 8+)
* ~~Set UAC to full~~
* Windows Search purge and re-initialization
* ~~Enroll into cloud protection for Windows Defender~~
* Update drivers
* Defragmentation

## Setup

### Configure in Windows

These can all be configured in Windows. They only need to be set up once and are pretty simple to set up. Refer to the Decent Security guide above if you're stuck.

* ##### Check Windows Update and Firewall
* ##### Install Windows updates and configure automatic update
* ##### Set UAC to full
* ##### Enroll into cloud protection for Windows Defender
* ##### Fast virus scan

The rest I'm looking to automate in a powershell script that I've set up in Windows Task Scheduler.

### Running Powershell script in Task Scheduler

https://blog.netwrix.com/2018/07/03/how-to-automate-powershell-scripts-with-task-scheduler/

taskschd.msc

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;

### Maintenance Script

The rest need to be automated in this script or done manually. Thoughts below, but I'm still working out how to do it all.

##### Test hard drive and review errors before starting

Windows has a built in tool to check disk health - ```chkdsk``` - run this for all disks.

* ~~Run ```chkdsk``` on all drives~~
* TODO: Refactor into a loop that checks for all drives
* TODO: Add logging - so that all issues are tracked in a log file
* TODO: If any issues are found, reboot later and run full disk check with ```chkdsk /f /r```

##### Junk programs uninstall

Pretty sure this one has to be done manually

##### Windows files clean with cleanmgr.exe

* TODO: This uses built in Windows commands so can likely be included in script

##### Windows Update cache reset

* TODO: This uses built in Windows commands so can likely be included in script

##### Temp file clean with Bleachbit

* TODO: Uses third part software so I'll have to figure out how to download/update and run in script

##### Malware/Junkware checkup

* TODO: Uses third part software so I'll have to figure out how to download/update and run in script

##### DISM RestoreHealth (Windows 8+)

* TODO: This uses built in Windows commands so can likely be included in script

##### WinSxS cleanup ResetBase (Windows 8+)

* TODO: This uses built in Windows commands so can likely be included in script

##### Windows Search purge and re-initialization

* TODO: This uses built in Windows commands so can likely be included in script

##### Update drivers

* TODO: Uses third part software so I'll have to figure out how to download/update and run in script
* TODO: Likely route is to have a list of places to check, log and alert when an update is available and download/install updates where needed

##### Defragmentation

* TODO: Uses third part software so I'll have to figure out how to download/update and run in script

##### Additional

* TODO: Add logging - so that all issues are tracked in a log file
* Have a config file where all variables can be set up (eg drives to check, driver types) so they don't need to be hard-coded