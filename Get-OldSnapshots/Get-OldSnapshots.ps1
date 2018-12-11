<#  
.SYNOPSIS  
    Connects to vCenter and gets a list of active snapshots that are not tied to Veeam.   
.DESCRIPTION  
    Connects to vCenter and gets a list of active snapshots that are not tied to Veeam
    and that are older than 1 day. Designed to build from gitlab CI/CD pipeline.
.NOTES  
    File Name   : Get-OldSnapshots.ps1  
    Author      : Justin Leopold - 12/11/2018
    Written on  : Powershell 5.1
    Tested on:    Powershell 5.1
.LINK  
#>

#Connect and gather
#Connect-VIServer -Server "vcenter"
$User = 'user'
$File = 'c:\store\vcenter.txt'
$VCenterCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, (Get-Content $file | ConvertTo-SecureString)
Connect-VIServer -Server "server" -Credential $VCenterCredential

$Snapshots = Get-VM | Get-Snapshot | Where-Object Description -notlike "*Veeam*" | Select-Object VM,Name,Description,SizeGB,Created
$SnapshotsString = $Snapshots | Out-String

#Create Email
$MailParams = @{
To = "recipient"
#Cc = "alternative"
From = "emailaddress"
Subject = "Old Snapshots Report: "
Body = $SnapshotsString
SmtpServer = "mailrelay"
}

Send-MailMessage @MailParams
