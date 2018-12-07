<#  
.SYNOPSIS  
 Reads the job engine log file on a main solarwinds poller and restarts the engine after error     
.DESCRIPTION  
  Reads the job engine log file on a main solarwinds poller and restarts the engine after errors
  are encountered in the log file in the last 30 entries. Intended to run as a simple job.   
.NOTES  
    File Name   : Get-JobEngineStatus.ps1  
    Author      : Justin Leopold - 12/7/2018
    Written on  : Powershell 5.1
    Tested on:    Powershell 5.1
.LINK  
#>

#Static variables and session creation
$swinds = servername
$Events = Get-Content -Path \\$swinds\c$\ProgramData\SolarWinds\JobEngine.v2\Logs\SolarWinds.JobEngineService_v2_13.log -Tail 30 | Select-String "ERROR"
$CimSession = New-CimSession -ComputerName $swinds

If($Events -like "*ERROR*" ){
    Invoke-Command -SessionName $CimSession -ScriptBlock{Restart-service -Name SWJobEngineSvc2}
    $MailParams = @{
                    #To =  $emailto
                    To = "email"
                    #Cc = ""
                    From = "recipient@alerts.change"
                    Subject = "Job Engine Restart: "
                    #Body = $EmailBody
                    SmtpServer = "mailserver"
                    }
                $EmailBody = "Job Engine V2 Service has encountered an error and has been restared. Verify jobs are running."
                Send-MailMessage @MailParams -BodyAsHtml -Body $EmailBody   
    }
