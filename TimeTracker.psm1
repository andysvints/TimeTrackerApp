function Start-TimeTracker {
<#

#>
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("c")] 
        [string]$Comment,
        [string]$Technician

    )
    
    begin {
        
    }
    
    process {
        if ($pscmdlet.ShouldProcess("Comment: '$($Comment)'", "Starting TimeTracker"))
        {
            $StartDate=Get-Date
            $Id=New-Guid | Select-Object -ExpandProperty Guid
            Write-Verbose "Starting new TimeTracker Instance."
            $Config=Get-ConfigFile
            if(!(Test-Path -Path "$($Config.OutputFolder)\TimeTracker")){
                New-Item -ItemType Directory -Name "TimeTracker" -Path $($Config.OutputFolder)
            }
            
            $p=@{
                Id=$Id
                StartTime=$StartDate
                Comment=$Comment
                Technician=if($Technician){$Technician}else{$($Config.Technician)}
            }
            $p | ConvertTo-Json | Out-File "$($Config.OutputFolder)\TimeTracker\$Id.track"
            Write-Verbose "TimeTracking started: $id"
        }
    }
    
    end {
        
    }
}

function Stop-TimeTracker {
<#
    
#>
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        $Guid
    )
    
    begin {
        
    }
    
    process {
        if ($pscmdlet.ShouldProcess("'Id: $($Guid)'", "Stopping TimeTracker"))
        {
            $EndDate=Get-Date
            Write-Verbose "Stopping new TimeTracker Instance."
            $Config=Get-ConfigFile
            Write-Verbose "Checking if $($Config.OutputFolder)\TimeTracker\$($Guid).track exists."
            if((Test-Path -Path "$($Config.OutputFolder)\TimeTracker\$($Guid).track" -PathType Leaf)){
                Write-Verbose "Id: $Guid exists"
                $TrackingFile=Get-Content "$($Config.OutputFolder)\TimeTracker\$($Guid).track" | ConvertFrom-Json
                $TrackingFile | Add-Member -NotePropertyName "EndTime"  -NotePropertyValue $EndDate
                #TO DO: Round Up based on Increment
                $TimeElapsed=$($EndDate-$($TrackingFile.StartTime))
                $MinutesSpent=$TimeElapsed.TotalMinutes -lt $Config.TimeIncrementMins ? $Config.TimeIncrementMins : $TimeElapsed.TotalMinutes
                $TrackingFile | Add-Member -NotePropertyName "MinutesElapsed" -NotePropertyValue $MinutesSpent
                $TrackingFile | Select-Object Id,StartTime,EndTime,MinutesElapsed,Comment,Technician | Export-csv -Path "$($Config.OutputFolder)\TimeTracker\TimeTrackingReport.csv" -NoTypeInformation -Append
                #Remove Tracking file
                Remove-item "$($Config.OutputFolder)\TimeTracker\$($Guid).track"
                Write-Verbose "TimeTracking stopped: $Guid"
            }else{
                Write-Error "Id: $Guid is not found"
            }

        }    
    }
    
    end {
        
    }
}

function Invoke-TimeTracker {
<#
    
#>
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param ()
    begin {}
    process {
        if ($pscmdlet.ShouldProcess("Graphic User Interface", "Invoke-TimeTracker"))
        {
            try {
                if($IsWindows){
                    $ModuleVersion=$(Get-Module TimeTracker | Select-Object -ExpandProperty Version).ToString()
                    Write-Verbose "Loading Windows Presentation Foundataion" 
                    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
                    #region WPF Windows Design
                        #region MainWindow
                        [xml]$MainWindowXAML = @"
                        <Window 
                                xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                                xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                                Title="" Height="400" Width="385" Topmost="True" WindowStartupLocation="CenterScreen"  Name="Window" WindowStyle='None' ResizeMode='CanMinimize' >
                            <Grid Background="#2c2c32">
                                <ListView Name="TimeTrackersListView" Background="#2c2c32" BorderThickness="0" Foreground="#F5F5F5" HorizontalAlignment="Left" Margin="30,40,0,0" VerticalAlignment="Top" Height="280" Width="320">
                                    <ListView.ItemContainerStyle>
                                        <Style>
                                            <Style.Triggers>
                                                <Trigger Property="Control.IsMouseOver" Value="True">
                                                    <Setter Property="Control.Background" Value="Transparent" />
                                                </Trigger>
                                            </Style.Triggers>
                                        </Style>
                                    </ListView.ItemContainerStyle>
                                    <ListView.View> 
                                        <GridView AllowsColumnReorder="false" ColumnHeaderToolTip="Time Tracking Information">
                                            <GridViewColumn DisplayMemberBinding="{Binding StartTime}" Header="Start Time" Width="130"/>
                                            <GridViewColumn DisplayMemberBinding="{Binding Comment}" Header="Comment" Width="180"/>
                                        </GridView>
                                    </ListView.View>
                                </ListView>
                                <TextBox Name="TitleTextBox" HorizontalAlignment="Center" Height="31" TextWrapping="Wrap" Text="Time Tracker App" VerticalAlignment="Top" Width="525" Margin="0,-1,-0.2,0" TextAlignment="Center" VerticalContentAlignment="Center" Foreground="#F5F5F5" Background="#585858" FontFamily="Century Gothic" FontSize="14" FontWeight="Bold" IsReadOnly="True" IsEnabled="False"/>
                                <Button Name="btnStartTimer" Content="Start Timer"  HorizontalAlignment="Left" Margin="30,300,0,0" VerticalAlignment="Top" Width="100" Height="54" BorderThickness="0" Foreground="#F5F5F5" Background="#585858" FontSize="14" />
                                <Button Name="btnStopTimer" Content="Stop Timer" HorizontalAlignment="Left" Margin="255,300,0,0" VerticalAlignment="Top" Width="100" Height="54" BorderThickness="0" Foreground="#F5F5F5" Background="#585858" FontSize="14" />
                                <TextBlock Name="VersionTextBlock" HorizontalAlignment="Left" Height="31" TextWrapping="Wrap"  VerticalAlignment="Top" Width="100" Margin="0,370,-0.2,0" TextAlignment="Center" Foreground="#F5F5F5" Background="#2c2c32" FontFamily="Century Gothic" FontSize="12">
                                    <Hyperlink>v$ModuleVersion</Hyperlink>
                                </TextBlock>
                                <TextBlock Name="AuthorTextBlock" HorizontalAlignment="Left" Height="31" VerticalAlignment="Top" Width="150" Margin="235,370,-0.2,0" TextAlignment="Center" Foreground="#F5F5F5" Background="#2c2c32" FontFamily="Century Gothic" FontSize="12">
                                    <Hyperlink>by @andysvints</Hyperlink>
                                </TextBlock>
                                <Button Name="btnClose" Content="X" HorizontalAlignment="Left" Margin="357,3,0,0" VerticalAlignment="Top" Width="25" Height="25" BorderThickness="1" FontWeight="Bold"/>
                                <Button Name="btnMinimize" Content="_" HorizontalAlignment="Left" Margin="332,3,0,0" VerticalAlignment="Top" Width="25" Height="25" BorderThickness="1" FontWeight="Bold"/>
                            </Grid>
                        </Window>
"@
                        
                        #endregion
                        #region Comment Windows
                            [xml]$CommentWindowXAML = @'
                            <Window 
                            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
                            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
                            Title="" Height="189" Width="300" Topmost="True" WindowStartupLocation="CenterScreen"  Name="Window1" WindowStyle='None' ResizeMode='CanMinimize' >
                                <Grid Background="#2c2c32">
                                    <TextBox Name="CommentTitleTextBox" HorizontalAlignment="Center" Height="31" TextWrapping="Wrap" Text="Add Comment" VerticalAlignment="Top" Width="525" Margin="0,-1,-0.2,0" TextAlignment="Center" VerticalContentAlignment="Center" Foreground="#F5F5F5" Background="#585858" FontFamily="Century Gothic" FontSize="14" FontWeight="Bold" IsReadOnly="True" IsEnabled="False"/>
                                    <TextBox Name="CommentTextBox" HorizontalAlignment="Center" TextWrapping="Wrap" AcceptsReturn="True" VerticalAlignment="Top" Height="110" Width="300" Margin="0,35,0,0" Foreground="#F5F5F5" Background="#585858" FontFamily="Century Gothic" FontSize="14" />
                                    <Button Name="btnStart" Content="Start"  HorizontalAlignment="Left" Margin="115,150,0,0" VerticalAlignment="Top" Width="70" Height="34" BorderThickness="0" Foreground="#F5F5F5" Background="#585858" FontSize="14" />
                                    <Button Name="btnCloseBox" Content="X" HorizontalAlignment="Left" Margin="272,3,0,0" VerticalAlignment="Top" Width="25" Height="25" BorderThickness="1" FontWeight="Bold"/>
                                </Grid>
                            </Window>
'@
                        #endregion
                    #endregion
                    Write-Verbose "Reading XAML for Main Window"
                    $MainFormXAMLReader=(New-Object System.Xml.XmlNodeReader $MainWindowXAML)
                    Write-Verbose "Loading Main Window"
                    $MainForm=[Windows.Markup.XamlReader]::Load( $MainFormXAMLReader )
                    Write-Verbose  "Store Main Window Form Objects In PowerShell"
                    $MainWindowXAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $MainForm.FindName($_.Name)}

                    Write-Verbose "Reading XAML for Comments Window"
                    $CommentFormXAMLReader=(New-Object System.Xml.XmlNodeReader $CommentWindowXAML)
                    Write-Verbose "Loading Comments Window"
                    $CommentForm=[Windows.Markup.XamlReader]::Load( $CommentFormXAMLReader )
                    Write-Verbose "Store Comment Window Form Objects In PowerShell"
                    $CommentWindowXAML.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $CommentForm.FindName($_.Name)}


                    #region WPF Form functions
                        $btnClose.Add_Click({
                            $MainForm.Close()
                        })

                        $btnMinimize.Add_Click({

                            $MainForm.WindowState="Minimized"
                        })
                        $MainForm.Add_MouseDown({
                            $MainForm.DragMove()
                        })

                        $MainForm.Add_ContentRendered({
                            $TimeTrackersListView.ItemsSource=@(Get-TimeTracker)
                        })

                        $btnStartTimer.Add_Click({
                            $CommentForm.ShowDialog() | out-null
                            
                        })
                        
                        $CommentForm.Add_MouseDown({
                            $CommentForm.DragMove()
                        })

                        $btnStopTimer.Add_Click({
                            #TODO: Adjust Comment if needed
                            if($TimeTrackersListView.SelectedItems){
                                $TimeTrackingInstance=$TimeTrackersListView.SelectedItems
                                Write-Verbose "Selected: Comment - $($TimeTrackingInstance.Comment)"
                                Stop-TimeTracker -Id $TimeTrackingInstance.Id
                                $TimeTrackersListView.ItemsSource=@(Get-TimeTracker)
                            }else{
                                $MessageText="No TimeTracking Item has been selected."
                                [System.Windows.MessageBox]::Show($MessageText,"",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Warning)
                                Write-Verbose $MessageText
                            }
                        })

                        $AuthorTextBlock.Add_PreviewMouseDown({
                                Start-Process "https://twitter.com/andysvints"
                        })
                        
                        $VersionTextBlock.Add_PreviewMouseDown({
                            $ModuleUrl=$(Get-Module TimeTracker | Select-Object -ExpandProperty ProjectUri).ToString()
                            Start-Process "$ModuleUrl"
                         })
                        $btnStart.Add_Click({
                            Start-TimeTracker -Comment $($CommentTextBox.Text)
                            $TimeTrackersListView.ItemsSource=@(Get-TimeTracker)
                            $CommentForm.Hide()
                            $CommentTextBox.Text=""
                        })
                        

                        $btnCloseBox.Add_Click({
                            $CommentForm.Hide()
                        })
                    #endregion


                    $MainForm.ShowDialog() | out-null


                }else{
                    Write-Information "Graphic User Interface is supported only on Windows Platform."
                }
        
            }
            catch {
                Write-Verbose "Something bad happened. Please review exception message for more details"
                Write-Error ("Catched Exception: - $($_.exception.message)")
            }
            
        }
    }
    
    end {
        
    }
}

function Get-TimeTracker {
<#
    
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
function Get-ConfigFile {
<#
    
#>
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
        
    )
    
    begin {
        $ModulePath=$(Get-Module TimeTracker | Select-Object -ExpandProperty ModuleBase)
    }
    
    process {
        if ($pscmdlet.ShouldProcess("$ModulePath\TimeTracker.config", "Get-ConfigFile")){
            if(Test-Path -Path $ModulePath\TimeTracker.config){
                Write-Verbose "Config Exists"
                $Config=Get-Content "$ModulePath\TimeTracker.config" | ConvertFrom-Json
                #TODO: parse the config & make sure that structure is OK
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
function New-DefaultConfigFile {
<#
    
#>
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
    param (
         
    )
    
    begin {
    }
    
    process {
        if ($pscmdlet.ShouldProcess("DefaultConfig", "Create New Config File"))
        {
            Write-Verbose "Creating Default Config File"
            $Config=@{
                "CircularLogging" = $true
                "LoggingLevel"="None"
                "TimeIncrementMins" = 30
                "OutputFolder"= $($env:USERPROFILE)
                "OutputFormat"= "CSV"
                "Technician"= ""    
            }

            $Config |ConvertTo-Json| Out-File $PSScriptRoot\TimeTracker.config 

        }
        
    }
    
    end {
        
    }
}

function Test-ConfigFile {
    [CmdletBinding(SupportsShouldProcess=$true, 
    ConfirmImpact='Medium')]
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
                "LoggingLevel": "Verbose",
                "CircularLogging" = $true
                "TimeIncrementMins" = 30
                "OutputFolder"= $($env:USERPROFILE)
                "OutputFormat"= "CSV"
                "Technician"= ""  
            #>
            switch ($ConfigObj) {
                {$ConfigObj.LoggingLevel -ne "Verbose" -and $ConfigObj.LoggingLevel -ne "None"}{ 
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