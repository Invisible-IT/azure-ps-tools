[CmdletBinding(DefaultParameterSetName)]
param (
        
)

$VmResourceGroupName = "INVISIBLEIT-TEST-LINUX-VM-RG"
$VmName = "test-vm"
$OsDiskName = "test-vm-osdisk"
$OsDiskSnapshotName = "test-vm-osdisk-snp001"

Write-Verbose "Retreiving VM properties"
$vm = Get-AzVM -ResourceGroupName $VmResourceGroupName -Name $VmName

Write-Verbose "Retreiving VM OS Disk properties"
$vmOsDiskResource = Get-AzResource -ResourceId $vm.StorageProfile.OsDisk.ManagedDisk.Id
$vmOsDisk   = Get-AzDisk -ResourceGroupName $vmOsDiskResource.ResourceGroupName -DiskName $vmOsDiskResource.Name

Write-Verbose "Removing VM instance"
Remove-AzResource -ResourceGroupName $VmResourceGroupName -ResourceName $VmName -ResourceType "Microsoft.Compute/virtualMachines" -Force

Write-Verbose "Removing VM OS Disk"
Remove-AzResource -ResourceId $vm.StorageProfile.OsDisk.ManagedDisk.Id -Force

Write-Verbose "Restoring VM OS Disk from Snapshot with the same name and configuration"
$vmOsDiskSnapshot = Get-AzSnapshot -ResourceGroupName $VmResourceGroupName -SnapshotName $OsDiskSnapshotName

$vmOsDiskConfig = New-AzDiskConfig -AccountType $vmOsDisk.Sku `
                                    -Location $vmOsDisk.Location `
                                    -SourceResourceId $vmOsDiskSnapshot.Id `
                                    -CreateOption Copy

$vmOsDisk = New-AzDisk -Disk $vmOsDiskConfig `
                        -ResourceGroupName $VmResourceGroupName `
                        -DiskName $OsDiskName

Write-Verbose "Redeploying VM instance with temporary OS Disk with different name from restored OS disk"

# TODO: Replay the same VM template, but different os disk name

Write-Verbose "Swapping VM OS Disk"
$vm = Get-AzVM -ResourceGroupName $VmResourceGroupName -Name $VmName
$vmOsDisk = Get-AzDisk -ResourceGroupName $VmResourceGroupName -DiskName $OsDiskName
$vm | Set-AzVMOSDisk -ManagedDiskId $vmOsDisk.Id -Name $vmOsDisk.Name | Update-AzVM

Write-Verbose "Removing VM temporary OS Disk"
$vmTemporaryOsDiskResource    = Get-AzResource -ResourceId $vm.StorageProfile.OsDisk.ManagedDisk.Id
$vmTemporaryOsDisk   = Get-AzDisk -ResourceGroupName $vmTemporaryOsDiskResource.ResourceGroupName -DiskName $vmTemporaryOsDiskResource.Name
Remove-AzDisk -ResourceGroupName $vmTemporaryOsDisk.ResourceGroupName -DiskName $vmTemporaryOsDisk.Name -Force