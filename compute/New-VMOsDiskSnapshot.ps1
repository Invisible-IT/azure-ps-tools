[CmdletBinding(DefaultParameterSetName)]
param (
        
)

$VmResourceGroupName = "INVISIBLEIT-TEST-LINUX-VM-RG"
$VmName = "test-vm"

Write-Verbose "Retreiving VM properties"
$vm = Get-AzVM -ResourceGroupName $VmResourceGroupName -Name $VmName

Write-Verbose "Retreiving OS Disk properties"
$vmOsDisk = Get-AzResource -ResourceId $vm.StorageProfile.OsDisk.ManagedDisk.Id

$snpNumber = 0
$snapshotName = ("$($vmOsDisk.Name)-snp" + $snpNumber.ToString('000'))

while ($null -ne (Get-AzResource -ResourceGroupName $VmResourceGroupName -Name $snapshotName)) {
    Write-Verbose "Snapshot name $snapshotName is used, generating another one"
    $snpNumber = $snpNumber + 1
    $snapshotName = ("$($vmOsDisk.Name)-snp" + $snpNumber.ToString('000'))
}

Write-Verbose "Snapshot name $snapshotName"

$snapshotConfig = New-AzSnapshotConfig -SourceUri $vm.StorageProfile.OsDisk.ManagedDisk.Id `
                                        -Location $vmOsDisk.Location `
                                        -OsType $vmOsDisk.Properties.osType `
                                        -CreateOption 'Copy' `
                                        -Incremental

Write-Verbose "Creating snapshot $snapshotName"
$snapshot = New-AzSnapshot -Snapshot $snapshotConfig `
                            -SnapshotName $snapshotName `
                            -ResourceGroupName $VmResourceGroupName