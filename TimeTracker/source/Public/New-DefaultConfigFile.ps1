function New-DefaultConfigFile
{
    <#
      .SYNOPSIS
      Create default config file,

      .DESCRIPTION
      This function is generating default config file used by TimeTracker module. Default config file:
      {
        "CircularLogging" : true,
        "LoggingLevel":"None",
        "TimeIncrementMins" : 30,
        "OutputFolder": $($env:USERPROFILE),
        "OutputFormat": "CSV",
        "Technician": ""
      }

      .EXAMPLE
      New-DefaultConfigFile -Verbose
      VERBOSE: Performing the operation "Create New Config File" on target "DefaultConfig".
      VERBOSE: Creating Default Config File

    #>
        [CmdletBinding(SupportsShouldProcess=$true,
        ConfirmImpact='Medium')]
        param (

        )

        begin {
        }

        process {
            if ($pscmdlet.ShouldProcess("DefaultConfig", "Create New Config File"))
            {
                Write-Verbose "Creating Default Config File"
                $Config=@{
                    "CircularLogging" = $true
                    "LoggingLevel"="None"
                    "TimeIncrementMins" = 30
                    "OutputFolder"= $($env:USERPROFILE)
                    "OutputFormat"= "CSV"
                    "Technician"= ""
                }
                Write-Verbose "Config File Location: $PSScriptRoot\TimeTracker.config"
                $Config |ConvertTo-Json| Out-File $PSScriptRoot\TimeTracker.config

            }

        }

        end {

        }
}
