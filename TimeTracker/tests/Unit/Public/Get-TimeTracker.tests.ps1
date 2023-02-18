$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Get-TimeTracker {
        Context 'Return values' {
            BeforeEach {
                Start-TimeTracker -Comment "Running Unit tests"
                $return = Get-TimeTracker
            }

            It 'Returns a single object' {
                ($return | Measure-Object).Count | Should -BeGreaterOrEqual 1
            }

            It 'Return a valid TimeTracking instance obj' {
                $props=$return | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}
                $props.Name | Should -Contain "Id"
                $props.Name | Should -Contain "Comment"
                $props.Name | Should -Contain "StartTime"
                $props.Name | Should -Contain "Technician"
            }

            AfterAll{
                Get-timeTracker | Select-Object  -ExpandProperty Id | Stop-TimeTracker
            }

        }
        Context 'ShouldProcess' {
            It 'Supports WhatIf' {
                (Get-Command Get-TimeTracker).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { Get-TimeTracker -WhatIf } | Should -Not -Throw
            }
        }
    }
}
