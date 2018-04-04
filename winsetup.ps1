# RDP to the node and use this PowerShell script

#https://docs.microsoft.com/en-us/azure/virtual-machines/windows/attach-disk-ps
$disks = Get-Disk | Where partitionstyle -eq 'raw' | sort number

$letters = 70..89 | ForEach-Object { [char]$_ }
$count = 0
$labels = "data1","data2","data3","data4"

foreach ($disk in $disks) {
    $driveLetter = $letters[$count].ToString()
    $disk | 
    Initialize-Disk -PartitionStyle MBR -PassThru |
    New-Partition -UseMaximumSize -DriveLetter $driveLetter |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] -Confirm:$false -Force
$count++
}

Install-WindowsFeature FS-IscsiTarget-Server
New-IscsiServerTarget -TargetName w1i0

Get-Volume
Get-VirtualDisk
#Remove-VirtualDisk -FriendlyName "diskvol0" -Confirm:$false
Get-Volume | where DriveLetter -eq "F" | fl *
New-IscsiVirtualDisk -Path F:\ivhdx0.vhdx -SizeBytes 10000000000 -UseFixed -DoNotClearData

Get-Volume | where DriveLetter -eq "G" | fl *
New-IscsiVirtualDisk -Path G:\ivhdx1.vhdx -SizeBytes 10000000000 -UseFixed -DoNotClearData

Add-IscsiVirtualDiskTargetMapping -Path F:\ivhdx0.vhdx -TargetName w1i0 -Lun 0
Add-IscsiVirtualDiskTargetMapping -Path G:\ivhdx1.vhdx -TargetName w1i0 -Lun 1

(Get-IscsiServerTarget w1i0).LunMappings

# IQN can be found on intiator: `cat /etc/iscsi/initiatorname.iscsi`
Set-IscsiServerTarget -TargetName w1i0 -InitiatorIds "IQN:iqn.1994-05.com.redhat:c4e37143a6fa"


#NB: this is for dev/test only here, no authentication was added at all

$fwrules = Get-NetFirewallRule -Direction Inbound | where DisplayName -like *ICMPv4-In*
$fwrules | ft -Property DisplayName,Direction,Action,Profiles,Enabled
$fwrules | Set-NetFirewallRule -Enabled True

$fwrules = Get-NetFirewallRule -Direction Inbound | where DisplayName -like *iSCSI*
$fwrules | ft -Property Name,Direction,Action,Profiles,Enabled

Get-Service | where DisplayName -like *iSCSI*
netstat -ano | findstr "3260"

