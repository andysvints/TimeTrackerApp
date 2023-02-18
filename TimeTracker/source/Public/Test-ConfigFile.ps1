function Test-ConfigFile
{
    <#
      .SYNOPSIS
      Verify validity of the config file

      .DESCRIPTION
      This function is reading existing config file and validating it is valid.

      .EXAMPLE
      Test-ConfigFile -ConfigObj $ConfigObj

      .PARAMETER ConfigObj
      Config file object that has to be validated


    #>
    [CmdletBinding(SupportsShouldProcess=$true,
    ConfirmImpact='Medium')]
    [OutputType([Bool])]
    param (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromRemainingArguments=$false,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("cfg")]
        $ConfigObj
    )
    begin {
    }
    process {
        if ($pscmdlet.ShouldProcess("Config: '$($ConfigObj)'", "Validate Config"))
        {
            <#DefaultConfig Template
                "LoggingLevel": "Verbose"
                "CircularLogging" = $true
                "TimeIncrementMins" = 30
                "OutputFolder"= $($env:USERPROFILE)
                "OutputFormat"= "CSV"
                "Technician"= ""
            #>
            switch ($ConfigObj) {
                {$ConfigObj.LoggingLevel -ne "Verbose" -and $ConfigObj.LoggingLevel -ne "None"} {
                    Write-Verbose "LoggingLevel key is not present or contains invalid value."
                    return $false
                    break
                }
                {$ConfigObj.CircularLogging -ne $true -and $ConfigObj.CircularLogging -ne $false } {
                    Write-Verbose "CircularLogging key is not present or contains invalid value."
                    return $false
                    break
                }
                {$ConfigObj.TimeIncrementMins -ne 30 -and $ConfigObj.TimeIncrementMins -ne 60 } {
                    Write-Verbose "TimeIncrementMins key is not present or contains invalid value."
                    return $false
                    break
                }
                {!(Test-Path -Path $ConfigObj.OutputFolder)} {
                    Write-Verbose "OutputFolder key is not present or contains invalid value."
                    return $false
                    break
                }
                Default {
                    return $true
                }
            }

        }
    }
    end {
    }
}