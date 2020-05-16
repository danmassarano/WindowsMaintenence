# Windows Maintenance

## Overview

Automate some basic maintenance processes for Windows 10

I do some basic maintenance checks on my PC every few months, mostly a manual process that's time consuming so I'm looking to automate it as much as possible.

I've been working off [this guide on Decent Security](https://decentsecurity.com/#/holiday-tasks/), and working to automate as many of them as possible. Some will still have to remain manual, but we'll see how it goes.

## Maintenance Steps

Out of order from that guide, I'm going with what I can automate first, then figuring out the rest as I go. The ones crossed out are already implemented.

* ~~Test hard drive and review errors~~
* ~~Junk programs uninstall~~
* ~~Windows files clean with cleanmgr.exe~~
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

* TODO: Can I script the setup of this?

If you want to just execute it manually,you can just run the script - navigate to the directory where the script is to run. You'll have to temporarily set permissions to allow it to run, as Windows doesn't allow unsigned PowerShell scripts to run by default:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
.\WindowsMaintenence.ps1
```

This should run the whole script.

Ideally you want it to run in an automated way so it can run as often as possible on a regular schedule. To do this, it needs to be set up in Windows Task Scheduler.

To open Task Scheduler, hit Win+R, and type ```taskschd.msc```.

In the "Actions" window, Click “Create Task” and enter a name and description. Select “Run with the highest privileges” as well as this script needs admin rights. 

I only set this to run when user is logged on, but if you want to have it run when you're not logged on (it might be a good idea to configure it to set it to only start when you log out for example) you can set up a service account to run it.

In the triggers tab you can set a trigger for when this is executed - like on a certain time interval, or on an event like when you sign out or restert. I want this to just run on a weekly basis, and I know when I don't use this PC, so I set it to run on a Monday night. 

Click "New", and in the "Begin the task" dropdown select "On a schedule". Select "Weekly", under "Recur" put 1, and choose a day and start time. Whatever schedule works for you. Under "Advanced settings" I'd set it to stop task if it takes more than a day. Just in case.

Go to the "Actions" tab and click "New". This is where you can set whatever is executed, like start a program, send an email, whatever. In this case, it's run a script.

To start a script, set the following:

* Action: Start a program
* Program\script: powershell
* Add arguments (optional): -File [WindowsMaintenence Directory]\WindowsMaintenence.ps1

Go to the "Conditions" tab - this will set some additinoal conditions for the environment to check whether to run the task. For example, you can set it to not run if you're on battery power. You can leave the defaults, but I'd check the "Start the task only if the computer is idle for:" option and set if for an hour.

In the "settings" tab, you can add any extra settings like allowing the task to be run on demand or stopped on demand. You can leave the defaults.

TODO: That should be it but confirm when I fully set up.

### Maintenance Script

The rest need to be automated in this script or done manually. Thoughts below, but I'm still working out how to do it all.

##### Test hard drive and review errors before starting

Windows has a built in tool to check disk health - ```chkdsk``` - run this for all disks.

* ~~Run ```chkdsk``` on all drives~~
* TODO: Refactor into a loop that checks for all drives
* TODO: Add logging - so that all issues are tracked in a log file
* TODO: If any issues are found, reboot later and run full disk check with ```chkdsk /f /r```

##### Windows files clean with cleanmgr.exe

* ~~Run ```cleanmgr``` on all drives~~
* TODO: Find way of setting this up automatically, or having settings in a config file

Disk Cleanup runs against a preset profile that has saved settings of what it runs against. To configure this, run the following command:

```powershell
cleanmgr /sageset:1
```

This brings up a dialog box showing what tasks will be run by Disk Cleanup. Select everything except 'Downloads' and click 'OK'. This will save the settings for you in a registry key.

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

### Manual Steps

* Junk programs uninstall
