# This code demonstrates the use of Windows Forms in PowerShell
# Created by Jun Ye (jellun@hotmail.com)
# Added Active Directory integration - 01/02/2021

# Load WinForm libraries
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# Import Active Directory Module
Import-Module -Name ActiveDirectory

#Global Variables
$global:Agent = ""

# Some File Servers do not support PSCredential
# $global:secureStr = ConvertTo-SecureString $global:mypasswords -AsPlainText -Force
# $global:credsToAccessFileServer = New-Object System.Management.Automation.PSCredential ( $global:Agent, $global:secureStr )
# For debug
# $global:BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR( $global:secureStr)
# $global:UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto( $global:BSTR)

$global:YEAR = get-date -Format yyyy
$global:PDATE = get-date –format MMdd

# Map Z: drive as the workspace
#$global:NetDrive = new-object -ComObject WScript.Network
$global:FSO = new-object -ComObject Scripting.FileSystemObject

# Load GUI
$global:Form = New-Object System.Windows.Forms.Form
$global:Form.Size = New-Object System.Drawing.Size(495,316)
$global:Form.Text = "Windows Forms App in PowerShell"

$global:DropDownBox01 = New-Object System.Windows.Forms.ComboBox
$global:DropDownBox01.Location = New-Object System.Drawing.Size(18,38)
$global:DropDownBox01.Size = New-Object System.Drawing.Size(150,20)
$global:DropDownBox01.DropDownHeight = 182
$global:DropDownBox01.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Bold)
$global:DropDownBox01.Add_SelectionChangeCommitted({DropDownBox01EventHandler})
$global:Form.Controls.Add($global:DropDownBox01)

$global:DropDownBox02 = New-Object System.Windows.Forms.ComboBox
$global:DropDownBox02.Location = New-Object System.Drawing.Size(180,38)
$global:DropDownBox02.Size = New-Object System.Drawing.Size(150,20)
$global:DropDownBox02.DropDownHeight = 182
$global:DropDownBox02.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Bold)
$global:DropDownBox02.Add_SelectionChangeCommitted({DropDownBox02EventHandler})
$global:Form.Controls.Add($global:DropDownBox02)

$global:LeftList = @("Item1","Item2","Item3")
$global:Agent1SubList = @("Item1-A","Item1-B","Item1-C","Item1-D","Item1-E")
$global:Agent2SubList = @("Item2-A","Item2-B","Item2-C","Item2-D","Item2-E","Item2-D")
$global:Agent3SubList = @("Item3-A","Item3-B")

foreach ( $anItem in $global:LeftList )
{
    $global:DropDownBox01.Items.Add( $anItem )  | out-null
}

<#
#The following code shows basic Active Directory integration
$global:OrgADGroups = Get-ADPrincipalGroupMembership $env:UserName | where name -like "DG-ACC-PPD*" | select name
foreach ( $anItem in $global:OrgADGroups )
{
	if($anItem.name -like "DG-ACC-AAA*")
	{
		if (!($global:DropDownBox01.Items.Contains("Item1")))
		{
			$global:DropDownBox01.Items.Add("Item1") | out-null
		}
	}
	elseif($anItem.name -like "DG-ACC-BBB*")
	{
		if (!($global:DropDownBox01.Items.Contains("Item2")))
		{
			$global:DropDownBox01.Items.Add("Item2") | out-null
		}
	}
}
#>

$global:LabelFirstSuffix = New-Object System.Windows.Forms.Label
$global:LabelFirstSuffix.Text = "Project Suffix"
$global:LabelFirstSuffix.AutoSize = $True
$global:LabelFirstSuffix.Location = New-Object System.Drawing.Size(18,70)
$global:LabelFirstSuffix.Visible = $False
$global:Form.Controls.Add( $global:LabelFirstSuffix )

$global:textBoxFirstSuffix = New-Object System.Windows.Forms.TextBox
$global:textBoxFirstSuffix.Location = New-Object System.Drawing.Size(18,90)
$global:textBoxFirstSuffix.Size = New-Object System.Drawing.Size(310,20)
$global:textBoxFirstSuffix.MultiLine = $False
$global:textBoxFirstSuffix.Visible = $False
$global:textBoxFirstSuffix.Add_TextChanged({$global:ProjectSuffix = $global:textBoxFirstSuffix.Text.Trim().ToUpper()})
$global:Form.Controls.Add( $global:textBoxFirstSuffix )

$global:LabelSecondSuffix = New-Object System.Windows.Forms.Label
$global:LabelSecondSuffix.Text = "User Name"
$global:LabelSecondSuffix.AutoSize = $True
$global:LabelSecondSuffix.Location = New-Object System.Drawing.Size(18,122)
$global:LabelSecondSuffix.Visible = $False
$global:Form.Controls.Add( $global:LabelSecondSuffix )

$global:textBoxSecondSuffix = New-Object System.Windows.Forms.TextBox
$global:textBoxSecondSuffix.Location = New-Object System.Drawing.Size(18,142)
$global:textBoxSecondSuffix.Size = New-Object System.Drawing.Size(310,20)
$global:textBoxSecondSuffix.MultiLine = $False
$global:textBoxSecondSuffix.Visible = $False
$global:textBoxSecondSuffix.Add_TextChanged({$global:ProducerSuffix = $global:textBoxSecondSuffix.Text.Trim().ToUpper()})
$global:Form.Controls.Add( $global:textBoxSecondSuffix )

$global:LabelNotification = New-Object System.Windows.Forms.Label
$global:LabelNotification.Text = "Notification"
$global:LabelNotification.AutoSize = $True
$global:LabelNotification.Location = New-Object System.Drawing.Size(18,174)
$global:Form.Controls.Add( $global:LabelNotification )

$global:textBoxNotification = New-Object System.Windows.Forms.TextBox
$global:textBoxNotification.Location = New-Object System.Drawing.Size(18,194)
$global:textBoxNotification.Size = New-Object System.Drawing.Size(450,75)
$global:textBoxNotification.BackColor = [System.Drawing.Color]::Silver
$global:textBoxNotification.ReadOnly = $True
$global:textBoxNotification.MultiLine = $True
$global:textBoxNotification.ScrollBars = "Vertical"
$global:Form.Controls.Add( $global:textBoxNotification )

$global:Button = New-Object System.Windows.Forms.Button 
$global:Button.Location = New-Object System.Drawing.Size(350,23) 
$global:Button.Size = New-Object System.Drawing.Size(120,50) 
$global:Button.Text = "Copy A2B"
$global:Button.Add_Click({CopyA2BFunction}) 
$global:Form.Controls.Add( $global:Button )

$global:LabelLeftList = New-Object System.Windows.Forms.Label
$global:LabelLeftList.Text = "Main List"
$global:LabelLeftList.AutoSize = $True
$global:LabelLeftList.Location = New-Object System.Drawing.Size(18,18)
$global:Form.Controls.Add( $global:LabelLeftList )

$global:LabelRightList = New-Object System.Windows.Forms.Label
$global:LabelRightList.Text = "Sub List"
$global:LabelRightList.AutoSize = $True
$global:LabelRightList.Location = New-Object System.Drawing.Size(180,18)
$global:Form.Controls.Add( $global:LabelRightList )

function DropDownBox02EventHandler
{
	$global:ProjectType = $global:DropDownBox02.SelectedItem
	$global:ProjectSuffix = ""
	$global:ProducerSuffix = ""
	
	$global:textBoxFirstSuffix.Text = ""
	$global:textBoxSecondSuffix.Text = ""
	$global:LabelFirstSuffix.Text = ""
	$global:LabelSecondSuffix.Text = ""
	$global:LabelFirstSuffix.Visible = $False
	$global:textBoxFirstSuffix.Visible = $False
	$global:LabelSecondSuffix.Visible = $False
	$global:textBoxSecondSuffix.Visible = $False
	
	if ( $global:DropDownBox01.SelectedItem -eq "Item1" )
	{
		$global:LabelFirstSuffix.Text = "Subject Code"
		$global:LabelFirstSuffix.Visible = $True
		$global:textBoxFirstSuffix.Visible = $True
	}
	elseif ( $global:DropDownBox01.SelectedItem -eq "Item2" )
	{
			$global:LabelFirstSuffix.Text = "Project Name"
			$global:LabelSecondSuffix.Text = "User Name"
			$global:LabelFirstSuffix.Visible = $True
			$global:textBoxFirstSuffix.Visible = $True
			$global:LabelSecondSuffix.Visible = $True
			$global:textBoxSecondSuffix.Visible = $True
	}
	elseif ( $global:DropDownBox01.SelectedItem -eq "Item3" )
	{
	}
	UpdateNotification("Project type selected: $global:ProjectType")
}

function DropDownBox01EventHandler
{
	$global:Agent = $global:DropDownBox01.SelectedItem
	
	$global:textBoxFirstSuffix.Text = ""
	$global:textBoxSecondSuffix.Text = ""
	$global:LabelFirstSuffix.Text = ""
	$global:LabelSecondSuffix.Text = ""
	$global:LabelFirstSuffix.Visible = $False
	$global:textBoxFirstSuffix.Visible = $False
	$global:LabelSecondSuffix.Visible = $False
	$global:textBoxSecondSuffix.Visible = $False
	$global:DropDownBox02.Items.Clear()
	
	UpdateNotification("Project selected: $global:Agent")

	if ( $global:DropDownBox01.SelectedItem -eq "Item1" )
	{
		foreach ( $aProjectType in $global:Agent1SubList )
		{
			$global:DropDownBox02.Items.Add( $aProjectType ) | out-null
		}
		$global:DropDownBox02.SelectedIndex = 0
	}
	elseif ( $global:DropDownBox01.SelectedItem -eq "Item2" )
	{
		foreach ( $aProjectType in $global:Agent2SubList )
		{
			$global:DropDownBox02.Items.Add( $aProjectType ) | out-null
		}
		$global:DropDownBox02.SelectedIndex = 0
	}
	elseif ( $global:DropDownBox01.SelectedItem -eq "Item3" )
	{
		foreach ( $aProjectType in $global:Agent3SubList )
		{
			$global:DropDownBox02.Items.Add( $aProjectType ) | out-null
		}
		$global:DropDownBox02.SelectedIndex = 0
	}
	DropDownBox02EventHandler
}

function UpdateNotification( $message )
{
	$global:textBoxNotification.Invoke([action]{$global:textBoxNotification.AppendText( $message + "`r`n" )})
}

function CopyA2BFunction
{
	#If ( $global:FSO.DriveExists("Z:") )
	#{
	#	$global:NetDrive.RemoveNetworkDrive("Z:", "True", "True")
	#}
	#$global:NetDrive.MapNetworkDrive("Z:", "\\" + $global:FileServerFQDN + "\" + $global:ProjectWorkspace, $False, "xxxxxxUserName", "xxxxxxPassword")
	
	#Or use "net use" command to cache the credentials
	#net use ("\\" + $global:FileServerFQDN) "xxxxxxPassword" /USER:DomainName\xxxxxxUserName
	
	UpdateNotification("Agent: $global:Agent")
	UpdateNotification("Type: $global:ProjectType")

	#Item1
	if ( $global:Agent -eq "Item1" )
	{
		if ( $global:ProjectType -eq "Item1-A" )
		{
			$global:projectname = $global:YEAR + "_" + $global:ProjectSuffix
			#Add other TODOs
		}
		UpdateNotification("ProjectSuffix: $global:ProjectSuffix")
	}
	#Item2
	elseif ( $global:Agent -eq "Item2" )
	{
		if ( $global:ProjectType -eq "Item2-A" )
		{
			$global:projectname = $global:YEAR + "_" + $global:ProjectSuffix + "_" + $global:ProducerSuffix
			#Add other TODOs
		}
		elseif ( $global:ProjectType -eq "Item2-B" )
		{
			$global:projectname = $global:YEAR + "_" + $global:ProjectSuffix + "_" + $global:ProducerSuffix
			#Add other TODOs
		}
		elseif ( $global:ProjectType -eq "Item2-C" )
		{
			$global:projectname = $global:YEAR + "_" + $global:ProjectSuffix + "_" + $global:ProducerSuffix
			#Add other TODOs
		}
		elseif ( $global:ProjectType -eq "Item2-D" )
		{
			$global:projectname = $global:YEAR + "_" + $global:ProjectSuffix + "_" + $global:ProducerSuffix
			#Add other TODOs
		}
		UpdateNotification("ProjectSuffix: $global:ProjectSuffix")
		UpdateNotification("ProducerSuffix: $global:ProducerSuffix")
	}
	#Item3
	elseif ( $global:Agent -eq "Item3" )
	{
		#Add TODOs
	}

	#Copy the project
	#Copy-Item -Force $global:SourceFiles -destination $global:projectname -recurse
	UpdateNotification("Project : $global:projectname created")

	# unmount Workspace
	#If ( $global:FSO.DriveExists("Z:") )
	#{
	#	$global:NetDrive.RemoveNetworkDrive("Z:", "True", "True")
	#}
	#net use /delete ("\\" + $global:FileServerFQDN)
	
	UpdateNotification("CopyA2B command completed successfully")
}

$global:Form.Add_Shown({$global:Form.Activate()})
[void] $global:Form.ShowDialog()