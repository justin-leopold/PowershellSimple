Function Get-VMDisks {  
    <#  
    .SYNOPSIS  
        Gets all Computers from a file and finds disk information for them. Exports to a spreadsheet. 
    .DESCRIPTION  
        Gets a list of computers and finds disk and places them in a hash table. Error handling included for 
        computers that don't connect via WMI. Exports to a hash table and/or CSV. Should be backwards compatible to 3.0.
    .NOTES  
        File Name   : Get-VMDisks.ps1  
        Author      : Justin Leopold - 3/8/2018
        Written on  : Powershell 5.1    
        Tested on:    Powershell 5.1
    .LINK  
    #>

    $computerlist = get-content c:\psdrive\devtest.csv
    $Credentials = Get-Credential

        Foreach($Comp in $computerlist){
            TRY{
            #$session = New-CimSession -Credential $Credentials -ComputerName $Comp -ErrorAction Stop
            #$disks = Get-Disk -CimSession $session
                $disks = Get-WmiObject -Class Win32_logicaldisk -ComputerName $comp -Credential $Credentials | Where-Object size -gt 0
                $Disktable =[ordered]@{
                    ComputerName = $Comp
                    Status = 'Connected'
                    Disk0 = $disks.size[0]
                    Disk1 = $disks.size[1]
                    Disk2 = $disks.size[2]
                    Disk3 = $disks.size[3]
                    Disk4 = $disks.size[4]}
        } CATCH {
                $Disktable =[ordered]@{
                    ComputerName = $Comp
                    Status = 'Connected'
                    Disk0 = $null
                    Disk1 = $null
                    Disk2 = $null
                    Disk3 = $null
                    Disk4 = $null}

        } FINALLY {
                $diskobject = New-Object -TypeName psobject -Property $disktable
                Write-Output $diskobject
                $diskobject | Export-Csv C:\Psdrive\devtestdrives.csv -append -NoTypeInformation -Force
        }
                
        }#foreach
}
