$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Test-ConfigFile {


        Context 'Return values' {

            BeforeEach {
                $ConfigFile="{`"CircularLogging`" : true,`"LoggingLevel`":`"None`",`"TimeIncrementMins`" : 30,`"OutputFolder`": `"$($home.replace('\',"\\"))`",`"OutputFormat`": `"CSV`",`"Technician`": `" `"}"
                $return = Test-ConfigFile -ConfigObj $($ConfigFile | ConvertFrom-Json)
            }

            It 'Returns a single object' {
                ($return | Measure-Object).Count | Should -Be 1
            }

            It 'Returns a true for a valid config file'{
                $return | Should -Be $true
            }


        }


        Context 'ShouldProcess' {
            BeforeEach {
                $ConfigFile="{`"CircularLogging`" : true,`"LoggingLevel`":`"None`",`"TimeIncrementMins`" : 30,`"OutputFolder`": `"C:\\users`",`"OutputFormat`": `"CSV`",`"Technician`": `" `"}"
                $return = Test-ConfigFile -ConfigObj $($ConfigFile | ConvertFrom-Json)
            }
            It 'Supports WhatIf' {
                (Get-Command Test-ConfigFile).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { Test-ConfigFile -ConfigObj $($ConfigFile | ConvertFrom-Json) -WhatIf } | Should -Not -Throw
            }
        }
    }
}
