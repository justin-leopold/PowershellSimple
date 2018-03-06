Function Install-Graylog {
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

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True,
            ValueFromPipeline = $True,
            ValueFromPipelineByPropertyName = $True,
            HelpMessage = "Enter Computer Name(s)")]   
        [Alias('hostname', 'cn')]
        [string[]]$ComputerName
    )

    #Static Variables for install
    #Make config variable based on directory
    $configfile = '\\dpsnas01\softwaredepot\Windows\Microsoft\Windows\Utilities\Graylog\filebeat\collector_sidecar_exchange2010iis.yml'
    $command = {powershell.exe c:\windows\temp\collector_sidecar.exe /S}

        Foreach ($computer in $ComputerName) {

            Copy-Item -Path '\\dpsnas01\softwaredepot\Windows\Microsoft\Windows\Utilities\Graylog\collector_sidecar_installer_0.1.3-1.exe' -Destination "\\$computer\c$\windows\temp\collector_sidecar.exe"

            Invoke-Command -ComputerName $computer -ScriptBlock $command

            Copy-Item -Path $configfile -Destination "\\$computer\c$\program files\Graylog\collector-sidecar" -Force

            Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process 'C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe' -ArgumentList "-service", "install"}
            Invoke-Command -ComputerName $computer -ScriptBlock {Start-Process 'C:\Program Files\graylog\collector-sidecar\graylog-collector-sidecar.exe' -ArgumentList "-service", "start"}

            Remove-Item -Path "\\$computer\c$\program files\Graylog\collector-sidecar\collector_sidecar.yml"
            Rename-Item -Path "\\$computer\c$\program files\Graylog\collector-sidecar\collector_sidecar_exchange2010iis.yml" -NewName "\\$computer\c$\program files\Graylog\collector-sidecar\collector_sidecar.yml"

        }#foreach
    }
