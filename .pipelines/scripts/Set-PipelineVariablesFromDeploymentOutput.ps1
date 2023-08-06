[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $armOutputString
)

Write-Output "Deployment output is $armOutputString"
$outputObj = $armOutputString | ConvertFrom-Json
$functionAppName = $outputObj.functionAppName.value
$keyVaultName = $outputObj.keyVaultName.value

# Set variable with Function app name from deployment output.  This will be used
# as input for the Function deploy step
Write-Output "##vso[task.setvariable variable=functionAppName;]$functionAppName"

# Set variable for Key Vault name.  This is used in a script to update a kv secret
Write-Output "##vso[task.setvariable variable=keyVaultName;]$keyVaultName"