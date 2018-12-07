Function Get-ConversationDNS {
<#  
.SYNOPSIS  
    Gets a list of IPs talking to a machine and performs a reverse dns lookup. 
.DESCRIPTION  
   Gets a list of IPs talking to a machine and performs a reverse dns lookup. Catches any resolution
   errors and marks them accordingly. 
.NOTES  
    File Name   : Get-ConversationDNS.ps1  
    Author      : Justin Leopold - 3/2/2018
    Written on  : Powershell 5.1
    Tested on:    Powershell 5.1
.LINK  
#>
    $ComputerIPAddress = Get-Content "W:\AD Project\conversations.csv"

    Foreach ($computerip in $ComputerIPAddress) {
        TRY {
            $DNSName = (Resolve-DnsName -Type PTR -Name $computerip -ErrorAction Stop).namehost

            $Hostinfo = [ordered]@{
                Status = 'DNS Record Exists'                                
                "Computer Name" = $DNSName.ToString()
                "IP Address" = $computerip
            }#close hash table

        }
        CATCH {
            $Hostinfo = [ordered]@{
                Status = 'DNS Record Not Present'                                
                "Computer Name" = $null
                "IP Address" = $computerip
            }#close hash table
        }
        FINALLY {
            $Conversationtable = New-Object -TypeName PSObject -Property $hostinfo
            Write-Output $Conversationtable
            $Conversationtable | Export-Csv C:\Psdrive\userad04conversations.csv -append -NoTypeInformation
        }    
    } #foreach

}
