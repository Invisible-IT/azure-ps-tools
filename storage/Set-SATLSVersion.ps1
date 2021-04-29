[CmdletBinding(DefaultParameterSetName)]
param (
        
)

$SaResourceGroup = "INVISIBLEIT-TEST-STORAGE-RG"
$SaName = "teststghg2envu5wgwm"

Set-AzStorageAccount -AccountName $SaName `
                     -ResourceGroupName $SaResourceGroup `
                     -MinimumTlsVersion TLS1_2