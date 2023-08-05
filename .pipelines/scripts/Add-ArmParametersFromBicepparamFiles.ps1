# GitHub Co-Pilot Prompt used to build the initial script:
########################################################################
# I need a powershell scrip that loops though all the .bicepparam files
# in the current directory and for each matching file, it should run the
# following command: bicep build-params [current file name]
# [current file name] should be the current file name in the loop
########################################################################
$files = Get-ChildItem -Path .\*.bicepparam -Recurse

foreach ($file in $files) {
    $outputFileName = $file.Name.Replace(".bicepparam", ".json")
    $inputFileName = $file.Name
    Write-Host "Generating file $outputFileName from $inputFileName"
    bicep build-params $file
}
