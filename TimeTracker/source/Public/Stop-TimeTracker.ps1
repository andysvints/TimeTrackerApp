function Stop-TimeTracker {
     <#
      .SYNOPSIS
      Stop TimeTracking instance

      .DESCRIPTION
      This function is stopping TimeTracking intance based on Id.

      .EXAMPLE
      Stop-TimeTracker -Guid f73e4c31-1e32-4a83-935c-14ac4bd74302 -Verbose
        VERBOSE: Performing the operation "Stopping TimeTracker" on target "'Id: f73e4c31-1e32-4a83-935c-14ac4bd74302'".
        VERBOSE: Stopping new TimeTracker Instance.
        VERBOSE: Config Exists
        VERBOSE: Config has been successfully validated.
        VERBOSE: Checking if C:\Users\test\TimeTracker\f73e4c31-1e32-4a83-935c-14ac4bd74302.track exists.
        VERBOSE: Id: f73e4c31-1e32-4a83-935c-14ac4bd74302 exists
        VERBOSE: TimeTracking stopped: f73e4c31-1e32-4a83-935c-14ac4bd74302

      .PARAMETER Guid
      Id of the TimeTracking instance that need to be stopped.b
    #>
        [CmdletBinding(SupportsShouldProcess=$true,
        ConfirmImpact='Medium')]
        param (
            [Parameter(Mandatory=$true,
                       ValueFromPipeline=$true,
                       ValueFromPipelineByPropertyName=$true,
                       ValueFromRemainingArguments=$false,
                       Position=0)]
            [ValidateNotNull()]
            [ValidateNotNullOrEmpty()]
            [Alias("Id")]
            $Guid
        )
        begin {
        }
        process {
            if ($pscmdlet.ShouldProcess("'Id: $($Guid)'", "Stopping TimeTracker"))
            {
                $EndDate=Get-Date
                Write-Verbose "Stopping new TimeTracker Instance."
                $Config=Get-ConfigFile
                Write-Verbose "Checking if $($Config.OutputFolder)\TimeTracker\$($Guid).track exists."
                if((Test-Path -Path "$($Config.OutputFolder)\TimeTracker\$($Guid).track" -PathType Leaf)){
                    Write-Verbose "Id: $Guid exists"
                    $TrackingFile=Get-Content "$($Config.OutputFolder)\TimeTracker\$($Guid).track" | ConvertFrom-Json
                    $TrackingFile | Add-Member -NotePropertyName "EndTime"  -NotePropertyValue $EndDate
                    $TimeElapsed=$($EndDate-$($TrackingFile.StartTime))
                    $MinutesSpent=$TimeElapsed.TotalMinutes -lt $Config.TimeIncrementMins ? $Config.TimeIncrementMins : $TimeElapsed.TotalMinutes
                    $TrackingFile | Add-Member -NotePropertyName "MinutesElapsed" -NotePropertyValue $MinutesSpent
                    $TrackingFile | Select-Object Id,StartTime,EndTime,MinutesElapsed,Comment,Technician | Export-csv -Path "$($Config.OutputFolder)\TimeTracker\TimeTrackingReport.csv" -NoTypeInformation -Append
                    Remove-item "$($Config.OutputFolder)\TimeTracker\$($Guid).track"
                    Write-Verbose "TimeTracking stopped: $Guid"
                }else{
                    Write-Error "Id: $Guid is not found"
                }
            }
        }
        end {
        }
    }