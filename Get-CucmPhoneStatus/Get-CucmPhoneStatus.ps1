<#  
.SYNOPSIS  
    Gets all A8004 school security station phones and reports any unregistered phones.  
.DESCRIPTION  
    Gets all A8004 school security station phones and reports any unregistered phones.
    This is built on a SOAP API to the call manager AXL API endpoint.
    Credentials required to access the API. Variables are static.
.NOTES  
    File Name   : Get-CUCMPhoneStatus.ps1  
    Author      : Justin Leopold - 8/10/2018
    Written on  : Powershell 5.1
    Tested on:    Powershell 5.1
.LINK  
#>

function Get-CUCMPhoneStatus {

    $Uri = 'https://server.org:8443/realtimeservice2/services/RISService70?wsdl'
    $Headers = @{"SOAPAction" = "SOAPAction:CUCM:DB ver=11.5"}
    [XML]$SoapWebRequest = 
    '<!--RisPort70 API - SelectCmDevice - Request-->
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap="http://schemas.cisco.com/ast/soap">
   <soapenv:Header/>
   <soapenv:Body>
      <soap:selectCmDevice>
         <soap:StateInfo></soap:StateInfo>
         <soap:CmSelectionCriteria>
            <soap:MaxReturnedDevices>20</soap:MaxReturnedDevices>
            <soap:DeviceClass>Phone</soap:DeviceClass>
            <soap:Model>255</soap:Model>
            <soap:Status>UnRegistered</soap:Status>
            <soap:NodeName></soap:NodeName>
            <soap:SelectBy>Name</soap:SelectBy>
            <soap:SelectItems>
               <!--Zero or more repetitions:-->
               <soap:item>
                  <soap:Item>Filter*</soap:Item>
               </soap:item>
            </soap:SelectItems>
            <soap:Protocol>SIP</soap:Protocol>
            <soap:DownloadStatus>Any</soap:DownloadStatus>
         </soap:CmSelectionCriteria>
      </soap:selectCmDevice>
   </soapenv:Body>
</soapenv:Envelope>'

    #Get the data and manipulate it
    #$CucmCredential = Get-Credential
    $User = 'user'
    $File = 'path'
    $CucmCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)  
    [xml]$xmldataunformatted = Invoke-WebRequest $Uri -Method Post -ContentType 'text/xml' -Body $SoapWebRequest -Headers $Headers -Credential $CucmCredential
    #$xmldataformatted = $xmldataunformatted | ConvertTo-xml
    #[xml]$outstring = $xmldataunformatted.Content

    #this is the info we want, SORT somehow before production!
    $phonenames = $xmldataunformatted.Envelope.Body.selectCmDeviceResponse.selectCmDeviceReturn.SelectCmDeviceResult.CmNodes.item.cmdevices.childnodes
    
    #put it in a hash table, loop and send an e-mail as needed
    Foreach ($phone in $phonenames) {

        $PhoneTable = [ordered]@{'Name' = $Phone.Name
            'Status' = $Phone.Status                              
            'Description' = $Phone.Description
            'IP' = $phone.IPAddress.childnodes.IP
        }#close hash table

        $PhoneTableObject = New-Object -TypeName PSObject -Property $PhoneTable
        #Write-Output $PhoneTableObject
        #$PhoneTableObject | Export-Csv Path -append -NoTypeInformation
    
        #act on hash table and loop data 
        if ($PhoneTableObject.status -eq "Registered") {
            Write-Host $PhoneTableObject.Name is $PhoneTableObject.Status at $PhoneTableObject.IP
        }
        else {
            $TestConnection = Test-Connection $PhoneTableObject.IP -Quiet
            If ($TestConnection -eq $true) {
                #Create Email
                $MailParams = @{
                    #To =  $emailto
                    To = "people@humans.org"
                    #Cc = ""
                    From = "emailaddress"
                    Subject = "Down Phones: "
                    #Body = $EmailBody
                    SmtpServer = "mailrelay"
                    }
                    $NameString = $PhoneTableObject.Name.ToString()
                    $DescriptionString = $PhoneTableObject.Description.ToString()
                    $StatusString = $PhoneTableObject.Status.ToString().ToLower()
                    $IpString = $PhoneTableObject.IP.ToString()
                $EmailBody = "Phone $NameString with description $DescriptionString is $StatusString and can still be pinged at $IpString"
                Send-MailMessage @MailParams -BodyAsHtml -Body $EmailBody
            }#close nested if construct
        }#Close else

    }#close for each

}#close Function

Get-CUCMPhoneStatus

<#Turn off cert validation, do not use unless in test

if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
 }
[ServerCertificateValidationCallback]::Ignore()
#>