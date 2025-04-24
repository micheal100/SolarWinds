#region initiate
Clear-Host
#$VerbosePreference = "continue"

import-module swispowershell
$server = '10.160.197.34'
$creds = Get-Credential -Message "Enter your SolarWinds credentials" -UserName 'admin'
$swis = Connect-Swis -Hostname $server -Credential $creds


try{
        Write-Verbose "Verifying connection to Orion."

        $swis.Open()
    }
    catch{
        Write-Error $_.Exception.Message
    }
#endregion initiate

#region getnodeinfo
#simple function to get node info for Cisco Devices, including unmanaged status
function get-nodeunmangedinfo{

#Get all nodes
$query  = "SELECT top 10 nodeid, IPAddress, Caption, vendor, UnManaged
FROM Orion.Nodes n where Vendor='Cisco'"

#Execute query, and store in  $results variable
$results = Get-SwisData -Query $query -SwisConnection $swis

#another way to display info
$results | Select-Object NodeID, IPAddress, Caption, Vendor, UnManaged| Format-Table -AutoSize

}

get-nodeunmangedinfo
#endregion getnodeinfo

#region unmanage
#First Build start and finish times
#IMPORTANT! Times are set using UTC
Clear-Host
$StartTime = (Get-Date).ToUniversalTime()
$EndTime = (Get-Date).ToUniversalTime().AddHours(1)

#Uses native methods, but doesn't support bulk updates 
$NodeIDs = Get-SwisData $swis "SELECT NodeId FROM Orion.Nodes WHERE Vendor=@vendor" @{vendor='Cisco'}  

ForEach ($Id in $NodeIDs){
    Invoke-SwisVerb $swis Orion.Nodes Unmanage @("N:$Id",$StartTime,$EndTime, $false)  | Out-Null
}

get-nodeunmangedinfo
#endregion unmanage

#region remanage
#remanage use
clear-host
ForEach ($Id in $NodeIDs){
    Invoke-SwisVerb $swis Orion.Nodes Remanage @("N:$Id") | Out-Null
} 

ForEach ($Id in $NodeIDs){
    Invoke-SwisVerb $swis Orion.Nodes Pollnow @("N:$Id") | Out-Null
}

get-nodeunmangedinfo
#endregion remanage

