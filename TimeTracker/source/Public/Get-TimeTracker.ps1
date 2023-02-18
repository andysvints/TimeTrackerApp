function Get-TimeTracker {
    <#
      .SYNOPSIS
      Get TimeTracker instance

      .DESCRIPTION
      This function is reading all started TimeTracker instances.

      .EXAMPLE
        Get-TimeTracker
        StartTime            Technician Comment        Id
        ---------            ---------- -------        --
        2/7/2023 12:56:40 PM Mr Test    Reading emails 000e67ec-48b9-4244-8f90-006a0afe3929
    #>
        [CmdletBinding(SupportsShouldProcess=$true,
        ConfirmImpact='Medium')]
        param (
        )
        begin {
        }
        process {
            if ($pscmdlet.ShouldProcess("All started time tracking instances", "Get-TimeTracker")){
                $Config=Get-ConfigFile
                $Tracker=Get-ChildItem -Path "$($Config.OutputFolder)\TimeTracker\" -Filter "*.track"
                $TimeTracking=New-Object System.Collections.Generic.List[PSObject]
                foreach ($f in $Tracker) {
                    $TimeTracking.Add($(Get-Content $f.FullName | ConvertFrom-Json )) | Out-Null
                }
                $TimeTracking
            }
        }
        end {
        }
}