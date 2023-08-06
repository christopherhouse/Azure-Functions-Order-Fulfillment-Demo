[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $functionAppName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $keyVaultName
)

Write-Host "Getting deafult key for Function App $functionAppName"
$key = az functionapp keys list --resource-group $resourceGroupName --name $functionAppName --query "functionKeys.default" -o tsv

Write-Host "Setting secret value in Key Vault $keyVaultName"
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "functionAppKey" -SecretValue $key

Write-Host "Done!"