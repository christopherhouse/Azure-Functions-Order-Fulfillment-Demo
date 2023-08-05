[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]
    $armOutputString
)

Write-Output "Deployment output is $armOutputString"
$outputObj = $armOutputString | ConvertFrom-Json

Write-Output "##vso[task.setvariable variable=functionAppName;]$outputObj.functionAppName"
