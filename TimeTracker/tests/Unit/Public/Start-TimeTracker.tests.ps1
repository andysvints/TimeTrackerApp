$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName -Verbose

InModuleScope $ProjectName {
    Describe Start-TimeTracker {
        Context 'No return values' {
            BeforeEach {
                New-DefaultConfigFile
                $return = Start-TimeTracker -Comment "Reading emails"
            }

            It 'Not returns a single object' {
                ($return | Measure-Object).Count | Should -Be 0
            }
            
            AfterAll{
                Get-timeTracker | Select-Object  -ExpandProperty Id | Stop-TimeTracker
            }
        }
        Context 'ShouldProcess' {
            It 'Supports WhatIf' {
                (Get-Command Start-TimeTracker).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { Start-TimeTracker -Comment "Reading emails" -WhatIf } | Should -Not -Throw
            }
        }
    }
}
