[CmdletBinding(DefaultParameterSetName)]
param (
        
)

$VmResourceGroupName = "INVISIBLEIT-TEST-LINUX-VM-RG"

$resources = Get-AzResource -ResourceGroupName $VmResourceGroupName

foreach ($resource in $resources) {
    if ($resource.ResourceType -eq "Microsoft.Compute/snapshots") {
        Remove-AzResource -ResourceGroupName $resource.ResourceGroupName `
                            -ResourceName $resource.ResourceName `
                            -Force
    }
}