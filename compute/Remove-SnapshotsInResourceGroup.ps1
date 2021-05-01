[CmdletBinding(DefaultParameterSetName)]
param (

)

$VmResourceGroupName = "INVISIBLEIT-TEST-LINUX-VM-RG"

Write-Verbose "Retreiving resource list from $VmResourceGroupName"
$resources = Get-AzResource -ResourceGroupName $VmResourceGroupName

foreach ($resource in $resources) {
    if ($resource.ResourceType -eq "Microsoft.Compute/snapshots") {
        Write-Verbose "Removing snapshot $($resource.ResourceGroupName) / $($resource.ResourceName)"

        Remove-AzResource -ResourceGroupName $resource.ResourceGroupName `
                            -ResourceName $resource.ResourceName `
                            -ResourceType $resource.ResourceType `
                            -Force
    }
}