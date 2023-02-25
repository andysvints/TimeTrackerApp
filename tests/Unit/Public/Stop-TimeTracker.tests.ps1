$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Stop-TimeTracker {

        Context 'Not return values' {
            BeforeEach {
                Start-TimeTracker -Comment "Running Unit tests"
                $Id=$(Get-TimeTracker | Select-Object -ExpandProperty Id -First 1)
                $return = Stop-TimeTracker -Guid $Id
            }

            It 'Not returns a single object' {
                ($return | Measure-Object).Count | Should -Be 0
            }

        }

        Context 'Pipeline' {
            BeforeEach {
                Start-TimeTracker -Comment "Running Unit tests"
                Start-TimeTracker -Comment "Running additional Unit tests"
                $Id=$(Get-TimeTracker | Select-Object -ExpandProperty Id -First 2)
            }

            It 'Accepts values from the pipeline by value' {
                $return = $Id[0],$Id[1] | Stop-TimeTracker
                Get-TimeTracker | Where-Object {$_.Id -eq $Id[0] -and $_.Id -eq $Id[1]}  | Should -Be $null
                
            }

        }

        Context 'ShouldProcess' {
            It 'Supports WhatIf' {
                (Get-Command Stop-TimeTracker).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { Stop-TimeTracker -Guid 'ac890657-a58c-45b7-91da-06da9dfd3796' -WhatIf } | Should -Not -Throw
            }

        }
    }
}
