[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $resourceGroupName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $keyVaultName,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $keyVaultSecretValue
)

Write-Host "Setting secret value in Key Vault $keyVaultName"
Set-AzKeyVaultSecret -VaultName $keyVaultName -Name "functionAppKey" -SecretValue $keyVaultSecretValue

Write-Host "Done!"