function Start-TimeTracker
{
    <#
      .SYNOPSIS
      Start TimeTracking instance.

      .DESCRIPTION
      This function is starting time tracking instance which relates to a specific actitivy.

      .EXAMPLE
      Start-TimeTracker -Comment "Reading & replying to emails"

      .PARAMETER Comment
      Description of the activity that you are treacking time for.

      .PARAMETER Technician
      Name of the Technician the is performing the activity. Is optional as it can be configured in config file.


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
            [Alias("c")]
            [string]$Comment,
            [string]$Technician

        )

        begin {

        }

        process {
            if ($pscmdlet.ShouldProcess("Comment: '$($Comment)'", "Starting TimeTracker"))
            {
                $StartDate=Get-Date
                $Id=New-Guid | Select-Object -ExpandProperty Guid
                Write-Verbose "Starting new TimeTracker Instance."
                $Config=Get-ConfigFile
                if(!(Test-Path -Path "$($Config.OutputFolder)\TimeTracker")){
                    New-Item -ItemType Directory -Name "TimeTracker" -Path $($Config.OutputFolder)
                }

                $p=@{
                    Id=$Id
                    StartTime=$StartDate
                    Comment=$Comment
                    Technician=if($Technician){$Technician}else{$($Config.Technician)}
                }
                $p | ConvertTo-Json | Out-File "$($Config.OutputFolder)\TimeTracker\$Id.track"
                Write-Verbose "TimeTracking started: $id"
            }
        }

        end {

        }
    }
