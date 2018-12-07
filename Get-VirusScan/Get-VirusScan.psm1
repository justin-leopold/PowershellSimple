<#  
.SYNOPSIS  
    Gets all AD computers and pulls virus scan info in. Exports to a file.  
.DESCRIPTION  
    Gets AD Computers and uses those names to gather information in a loop and put it into a hash table. 
    Inclucdes a Try/Catch/Finally blocks to catch errors for PCs that are not online.
    Does not require any specific modules. No user inputs.
.NOTES  
    File Name   : Get-VirusScan.ps1  
    Author      : Justin Leopold - 3/2/2018
    Written on  : Powershell 5.1
    Tested on:    Powershell 4.0
.LINK  
#>
Function Get-VirusScan {
    [CmdletBinding()]
    #Could be configured to accept pipeline input for program name and computer name, only static for this use
    $credentials = Get-Credential
    $ADComputers = (Get-ADComputer -Filter * -Server domain.org -credential $credentials).name


    Foreach ($computer in $ADComputers) {
    
        TRY {
            $SCEP = Get-WmiObject -Class win32_product -ComputerName $computer  -Credential $credentials -ErrorAction Stop | Where-Object name -like "*ForeFront Endpoint Protection*" 
            $Trend = Get-WmiObject -Class win32_product -ComputerName $computer  -Credential $credentials -ErrorAction stop | Where-Object name -like "*Trend*"
            $Computertable = [ordered]@{Computername = $computer
                                    Status = 'Virus Scan Installed'                                
                                    SCEPname = ($SCEP.name | Out-String).Trim()
                                    SCEPVersion = ($SCEP.Version | Out-String).Trim()
                                    Trendname = ($Trend.name | Out-String).Trim()
                                    TrendVersion = ($Trend.Version | Out-String).Trim()
                                    }#close hash table
      }  CATCH {
            $Computertable = [ordered]@{Computername = $computer
                                    Status = 'Connection Failed'
                                    SCEPname = $null
                                    SCEPVersion = $null
                                    Trendname = $null
                                    TrendVersion = $null
                                    }#close hash table
      } FINALLY {                             
       
            $computerobjecttable = New-Object -TypeName PSObject -Property $Computertable
            Write-Output $computerobjecttable
            $computerobjecttable | Export-Csv C:\thisisfolder -append -NoTypeInformation

        }
    }#close for each
} #close function
