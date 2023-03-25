# TimeTracker

Simple time tracking functionalities within PowerShell. Helps you to track spent
time for different activities during your day to day work. Provides rudimentary
WPF UI in Windows environment.
Allows to start and track multiple tasks at the same time. Rounding up time spent
based on the provided increment. Default increment is 30 minutes. After you stop
time tracking it provides you the Time Tracking report. Can be used as CLI tool
within Windows and Linux environments. In Windows can be used as WPF UI box for
more convenient time and activities tracking.

## Installation

 Module is published to PowerShell Gallery. Use the following command to install
it:

 ```powershell
 Install-Module -Name TimeTrackerApp -AllowPrerelease 
 ```
 
## Usage

Generic workflow is to create/adjust configuration file to suit your needs and 
then start time tracking.

### CLI

* Create default config file
* Update it if needed
* Start time tracking instance(s)
* View started time tracking instance(s)
* Stop started time tracking instance(s)

```powershell
    New-DefaultConfigFile -Verbose
    Get-ConfigFile -Verbose
    Start-TimeTracker -Comment "Reading & replying to email" -Technician "Clark Kent"
    Get-TimeTracker
    Get-TimeTracker | select -ExpandProperty Id | Stop-TimeTracker
```

### GUI

* Create default config file
* Update it if needed
* Start GUI

```powershell
    New-DefaultConfigFile -Verbose
    Get-ConfigFile -Verbose
    Invoke-TimeTracker
```

## Cmdlets

Please refer to the comment-based help for more information about these commands.

### New-DefaultConfigFile

This function is generating default config file used by TimeTracker module.
Default config file:

```json
    {
      "CircularLogging" : true,
      "LoggingLevel":"None",
      "TimeIncrementMins" : 30,
      "OutputFolder": $($env:USERPROFILE),
      "OutputFormat": "CSV",
      "Technician": ""
    }
```

#### Syntax

```powershell
 New-DefaultConfigFile [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Example

```powershell
PS > New-DefaultConfigFile -Verbose
    VERBOSE: Performing the operation "Create New Config File" on target "DefaultConfig".
    VERBOSE: Creating Default Config File
```

This example creates a default config file using predefined template.

### Get-ConfigFile

This function is reading existing config file.

#### Syntax

```powershell
Get-ConfigFile [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Example

```powershell
PS > Get-ConfigFile
      CircularLogging   : True
      OutputFormat      : CSV
      OutputFolder      : C:\Users
      TimeIncrementMins : 30
      Technician        : Mr Test
      LoggingLevel      : None
```

### Test-ConfigFile

Verify validity of the config file

#### Syntax

```powershell
Test-ConfigFile [-ConfigObj] <Object> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Example

```powershell
PS> Get-ConfigFile | Test-ConfigFile
True
```

### Start-TimeTracker

Start TimeTracking instance.

#### Syntax

```powershell
Start-TimeTracker [-Comment] <String> [-Technician <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Example

```powershell
 PS > Start-TimeTracker -Comment "Reading & replying to emails"
```

### Get-TimeTracker

Get TimeTracker instance(s).

#### Syntax

```powershell
Get-TimeTracker [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Example
```powershell
    PS > Get-TimeTracker
    StartTime            Technician Comment        Id
    ---------            ---------- -------        --
    2/7/2023 12:56:40 PM Mr Test    Reading emails 000e67ec-48b9-4244-8f90-006a0afe3929
```

### Stop-TimeTracker

This function is stopping TimeTracking instance based on Id.

#### Syntax

```powershell
Stop-TimeTracker [-Guid] <Object> [-WhatIf] [-Confirm] [<CommonParameters>]
```

#### Example

```powershell
 PS > Stop-TimeTracker -Guid f73e4c31-1e32-4a83-935c-14ac4bd74302 -Verbose
      VERBOSE: Performing the operation "Stopping TimeTracker" on target "'Id: f73e4c31-1e32-4a83-935c-14ac4bd74302'".
      VERBOSE: Stopping new TimeTracker Instance.
      VERBOSE: Config Exists
      VERBOSE: Config has been successfully validated.
      VERBOSE: Checking if C:\Users\test\TimeTracker\f73e4c31-1e32-4a83-935c-14ac4bd74302.track exists.
      VERBOSE: Id: f73e4c31-1e32-4a83-935c-14ac4bd74302 exists
      VERBOSE: TimeTracking stopped: f73e4c31-1e32-4a83-935c-14ac4bd74302
```

**[Timer icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/timer)**