function Get-ConfigFile {
     <#
      .SYNOPSIS
      Get config file

      .DESCRIPTION
      This function is reading existing config file.

      .EXAMPLE
      Get-ConfigFile
        CircularLogging   : True
        OutputFormat      : CSV
        OutputFolder      : C:\Users
        TimeIncrementMins : 30
        Technician        : Mr Test
        LoggingLevel      : None
    #>
        [CmdletBinding(SupportsShouldProcess=$true,
        ConfirmImpact='Medium')]
        param (
        )
        begin {
        }
        process {
            if ($pscmdlet.ShouldProcess("$PSScriptRoot\TimeTracker.config", "Get-ConfigFile")){
                if(Test-Path -Path $PSScriptRoot\TimeTracker.config){
                    Write-Verbose "Config Exists"
                    $Config=Get-Content "$PSScriptRoot\TimeTracker.config" | ConvertFrom-Json
                    if(Test-ConfigFile $Config){
                        Write-Verbose "Config has been successfully validated."
                        $Config
                    }else{
                        Write-Error "Config File is invalid."
                        Write-Verbose "Please run New-ConfigFile cmdlet or remove error(s) in existing configuration file."
                    }
                }else {
                    Write-Error "Config Not Found"
                    Write-Verbose "Please run New-ConfigFile cmdlet"
                }
            }
        }
        end {
        }
    }