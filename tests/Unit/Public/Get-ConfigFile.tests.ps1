$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Get-ConfigFile {
        Context 'Config File do not exist'{
            It "Cannot find config file"{
                $return =Get-ConfigFile -ErrorAction SilentlyContinue 
                $return| Should -Be $null
            }            
        }

        Context "Invalid Config file"{
            BeforeEach{
                $Config=@{
                    "CircularLogging" = $true
                    "Logging"="None"
                    "TimeIncrementMins" = 30
                    "Folder"= $($env:USERPROFILE)
                    "OutputFormat"= "CSV"
                    "Technician"= ""
                }
                $Config |ConvertTo-Json| Out-File $PSScriptRoot\TimeTracker.config
            }

            It "Config file structure is invalid" {
                $return=Get-ConfigFile -ErrorAction SilentlyContinue -Verbose 4>&1
                $return.message[-1] | Should -Be "Please run New-ConfigFile cmdlet"
            }
        }
        Context 'Return values' {
            BeforeEach {
                New-DefaultConfigFile
               $return = Get-ConfigFile
            }

            It 'Returns a single object' {
                ($return | Measure-Object).Count | Should -Be 1
            } 
        }

        Context 'ShouldProcess' {
            It 'Supports WhatIf' {
                (Get-Command Get-ConfigFile).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { Get-ConfigFile -WhatIf } | Should -Not -Throw
            }
        }
    }
}
