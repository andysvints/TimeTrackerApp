$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe New-DefaultConfigFile {

        Context 'Not return values' {
            BeforeEach {
                $return = New-DefaultConfigFile
            }

            It 'Not returns a single object' {
                ($return | Measure-Object).Count | Should -Be 0
            }
        }

        Context 'ShouldProcess' {
            It 'Supports WhatIf' {
                (Get-Command New-DefaultConfigFile).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { New-DefaultConfigFile -WhatIf } | Should -Not -Throw
            }

        }
    }
}
