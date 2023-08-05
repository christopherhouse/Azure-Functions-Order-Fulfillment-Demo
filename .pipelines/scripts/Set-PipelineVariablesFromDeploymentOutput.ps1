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

# Set variable with Function app name from deployment output.  This will be used
# as input for the Function deploy step
Write-Output "##vso[task.setvariable variable=functionAppName;]$functionAppName"
