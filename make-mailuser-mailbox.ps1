#Adds the AD module and (if it's not already added Exchange Management PS Snappin
Import-Module ActiveDirectory
$exchangeSnapinTest = Get-PSSnapin | Select-String "Microsoft.Exchange.Management.PowerShell.E2010"
if ($exchangeSnapinTest -eq $null) { Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 }

#prompt the admin for information on the target user - username, target mailbox database, and whether or not the user's mail should be un-forwarded
$user= read-host "enter the username of the mailuser to convert to a mailbox"
$database = read-host "enter the target mailbox database"
$unforwardemail= read-host "do you want to remove mail forwarding for the user?  (Y/N)"

#get the current target address where mail is being sent, to remove from the user
$externalemailaddress= get-mailuser $user | select ExternalEmailAddress

#convert the mailuser to a mailbox
Get-MailUser $user | enable-mailbox -Database $database
#if the user's e-mail forwarding is to be removed, this will remove the mail forwarding and the proxy addresses for the external address 
if $unforwardemail -eq "Y" 
{

    #unforward e-mail (minor piece waiting to be updated)


    #remove proxy address

    $ldapfilter = "(&(samaccountname=" + $user + "))"
    $mailUser = Get-ADObject -LDAPFilter $ldapfilter -properties *

    #remove ProxyAddress
    Set-ADObject $mailUser -Remove @{proxyAddresses="$externalemailaddress"}
}   

#grants access to Exchange Service / Server accounts
Add-MailboxPermission -Identity $user -user 'exchange servers' -AccessRights FullAccess -InheritanceType all 
Add-MailboxPermission -Identity $user -user 'Exchange Services' -AccessRights FullAccess -InheritanceType all 
Add-MailboxPermission -Identity $user -user 'Exchange Trusted Subsystem' -AccessRights FullAccess -InheritanceType all 
#grants access to Blackberry service accounts
Add-MailboxPermission -Identity $user -user 'besadmin-kohai' -AccessRights FullAccess -InheritanceType all 
Add-MailboxPermission -Identity $user -user 'blackberryadmin' -AccessRights FullAccess -InheritanceType all 
