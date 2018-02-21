<#  
.SYNOPSIS  
    Install Graylog to windows server using a Foreach loop and data generated from a SW report
.DESCRIPTION  
    Installs Graylog and sets default settings for windows 
    logging to allow configuration management via Graylog Configuration Manager  
.NOTES  
    File Name   : Windowsgrayloginstallmultiple.ps1  
    Author      : Justin Leopold - 7/18/2017 
    Written on  : Powershell 5.1
.LINK  
#>

#Variables for install
$Computers = "hostname"
$configfile = 'collector_sidecar.yml'
$command = {powershell.exe c:\windows\temp\collector_sidecar.exe /S}
$path = '\\dpsnas01\softwaredepot\Windows\Microsoft\Windows\Utilities\Graylog\collector_sidecar_installer_0.1.3-1.exe'

Foreach ($computer in $Computers) {

    Copy-Item -Path '$path' -Destination "\\$computer\c$\windows\temp\collector_sidecar.exe"

    Invoke-Command -ComputerName $computer -ScriptBlock $command

    Copy-Item -Path $configfile -Destination "\\$computer\c$\program files\Graylog\collector-sidecar" -Force

    Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process 'C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe' -ArgumentList "-service", "install"}
    Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process 'C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe' -ArgumentList "-service", "start"}

}#foreach
