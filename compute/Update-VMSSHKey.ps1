[CmdletBinding(DefaultParameterSetName)]
param (
        
)

$VmResourceGroupName = "INVISIBLEIT-TEST-LINUX-VM-RG"
$VmName = "test-vm"
$AdminUsername = "testadm"

ssh-keygen.exe -t rsa -C "example@invisibleit.io" -N '""' -f .\linux_ssh_key

$sshPublicKey = Get-Content .\linux_ssh_key.pub -Encoding ascii -Raw

# TODO: put in secret Vault
$sshPrivateKey = Get-Content .\linux_ssh_key -Encoding ascii -Raw

Remove-Item .\linux_ssh_key
Remove-Item .\linux_ssh_key.pub

# TODO: remove any extension of type VMAccessForLinux
# Remove-AzVMExtension -ResourceGroupName $VmResourceGroupName -VMName $VmName -Name 'update-ssh-key' -Force

$protectedSettings = @{
    "username" = $AdminUsername
    "ssh_key" = $sshPublicKey.ToString()
}

Set-AzVMExtension -ResourceGroupName $VmResourceGroupName `
                    -VMName $VmName `
                    -Location 'northeurope' `
                    -Name 'update-ssh-key' `
                    -ExtensionType 'VMAccessForLinux' `
                    -Publisher 'Microsoft.OSTCExtensions' `
                    -Version '1.5' `
                    -ProtectedSettingString ($protectedSettings | ConvertTo-Json)

Remove-AzVMExtension -ResourceGroupName $VmResourceGroupName -VMName $VmName -Name 'update-ssh-key' -Force


