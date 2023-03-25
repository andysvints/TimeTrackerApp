function Invoke-TimeTracker {
       <#
      .SYNOPSIS
      Invoke TimeTracker WPF UI

      .DESCRIPTION
      This function is loading TimeTracker WPF App.

      .EXAMPLE
      Invoke-TimeTracker
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
                        $ModuleVersion=$(Get-Module TimeTrackerApp | Select-Object -ExpandProperty Version).ToString()
                        Write-Verbose "Loading Windows Presentation Foundation"
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
