# Windows Maintenance

## Overview

Automate some basic maintenance processes for Windows 10

I do some basic maintenance checks on my PC every few months, mostly a manual process that's time consuming so I wrote this to automate it as much as possible.

I worked off off [this guide on Decent Security](https://decentsecurity.com/#/holiday-tasks/). Some of these steps have to be done manually, but almost all can be automated.

This has been designed to run in the background, so once it's set up it shouldn't require and manual intervention. However, as some Windows maintenence processes require a reboot, this will reboot the PC at times so is best scheduled for times when the PC isn't in use, such as overnight.

## Operations

This script performs the following:

* Test hard drives and review errors
* Windows file clean
* Windows Update cache reset
* Temp file clean with Bleachbit
* DISM RestoreHealth
* WinSxS cleanup ResetBase
* Windows Search purge and re-initialization
* Defragmentation

## Setup

#### Configure in Windows

These can all be configured in Windows. They only need to be set up once and are pretty simple to set up. Refer to the Decent Security guide above if you're stuck.

* Check Windows Update and Firewall
* Install Windows updates and configure automatic update
* Set UAC to full
* Enroll into cloud protection for Windows Defender
* Fast virus scan

#### Configuring the script

All settings are stored in a ```config.json``` file so can be configured up front rather than altering the script.

The only values that you should change here are ```SystemDrives``` and ```DataDrives```. These are used to tell the program what drives are in use. 

```SystemDrives``` is usually your C drive, but for the purposes of this program put any of your SSD's in there - those will be cleaned up but not defragmented. 

```DataDrives``` refers to any magnetic hard drives, these would need defragmenting so put any hard drives you're using there.

For example, if you only have a single SSD with everything on there (the most usual case), set ```"SystemDrives": "C:"``` and leave ```"DataDrives":``` empty.

Essentially, drives that need defragmenting in ```DataDrives``` and everything else in ```SystemDrives```. Also, make sure to format it like so:

```drivename: drivename:``` eg ```C: D:``` - make sure to put the colon and space in there!

#### Windows files clean with cleanmgr.exe

Disk Cleanup runs against a preset profile that has saved settings of what it runs against. To configure this, run the following command:

```powershell
cleanmgr /sageset:1
```

This brings up a dialog box showing what tasks will be run by Disk Cleanup. Select everything except 'Downloads' and click 'OK'. This will save the settings for you in a registry key.

#### Defragmentation

I'm using [MyDefrag](https://filehippo.com/download_mydefrag/) rather than the inbuilt Windows tool, but this is only needed if you're using HDD's. It shouldn't be needed at all if you're only using a single drive for your system disk - seriously, just get an SSD.

If also have a bunch of data disks, you'll want this step. It does require you to install MyDefrag, and add it to your environment path. Otherwise, just clear the data disk values in the config file and it'll skip this.

#### Running Powershell script in Task Scheduler

TODO: Can I script the setup of this?

If you want to just execute it manually,you can just run the script - navigate to the directory where the script is to run. You'll have to temporarily set permissions to allow it to run, as Windows doesn't allow unsigned PowerShell scripts to run by default:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
.\WindowsMaintenenceStep1.ps1
```

This should run the first script. You can run the second in a similar way, although I would strongly recommend rebooting after running the first. 

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
* Add arguments (optional): -File [WindowsMaintenence Directory]\WindowsMaintenenceStep1.ps1

Go to the "Conditions" tab - this will set some additional conditions for the environment to check whether to run the task. For example, you can set it to not run if you're on battery power. You can leave the defaults, but I'd check the "Start the task only if the computer is idle for:" option and set if for an hour.

In the "settings" tab, you can add any extra settings like allowing the task to be run on demand or stopped on demand. You can leave the defaults.

This will schedule to run the first part of the process on a weekly basis.

Once completed this will force a reboot, with the second part to run afterwards.

To schedule the second process, set up a schedule in the same way you did for the first, but when you get to triggers change the tigger to 'On Startup'. This will allow the script to run after the previous one has completed and rebooted your PC.

This will make the second script run if the first one has completed and triggered a reboot.

#### Troubleshooting
The script is set up to output everything to a log file, ```log.txt```, so if you encounter any issues they will be tracked in there. 

## Additional work to complete

* Update drivers
    * Uses third party software so I'll have to figure out how to download/update and run in script
    * Likely route is to have a list of places to check, log and alert when an update is available and download/install updates where needed