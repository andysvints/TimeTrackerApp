$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe Invoke-TimeTracker {
        Context "XAML Syntax check for WPF Windows"{
            BeforeEach{
                Import-Module TimeTrackerApp
                $ModuleRawCode=Get-Content -Path $(Get-Module TimeTrackerApp).Path
                $Count=0
                $MainWindowStartLine=0
                $MainWindowEndLine=0
                $CommentsWindowStartLine=0
                $CommentsWindowEndLine=0
                foreach($l in $ModuleRawCode){
                    if($l -like "*MainWindowXAML = @`"" ){
                        $MainWindowStartLine=$Count
                    }
                    if($l -eq "`"@"){
                        $MainWindowEndLine=$Count
                    }
                    if($l -like "*CommentWindowXAML = @'"){
                        $CommentsWindowStartLine=$Count
                    }
                    if($l -eq "'@"){
                        $CommentsWindowEndLine=$Count
                    }
                    $Count++
                }
            }

            It 'Correct main Window syntax'{
                $MainWindowXAML =[xml]$ModuleRawCode[$($MainWindowStartLine+1)..$($MainWindowEndLine-1)]
                $MainWindowXAML.GetType() | Select-Object -ExpandProperty name | Should -Be 'XmlDocument'
            }

            It 'Correct comments window syntax'{
                $CommentWindowXAML=[xml]$ModuleRawCode[$($CommentsWindowStartLine+1)..$($CommentsWindowEndLine-1)]
                $CommentWindowXAML.GetType() | Select-Object -ExpandProperty name | Should -Be 'XmlDocument'
            }

        }


        Context 'ShouldProcess' {
            It 'Supports WhatIf' {
                (Get-Command Invoke-TimeTracker).Parameters.ContainsKey('WhatIf') | Should -Be $true
                { Invoke-TimeTracker -WhatIf } | Should -Not -Throw
            }
        }
    }
}
