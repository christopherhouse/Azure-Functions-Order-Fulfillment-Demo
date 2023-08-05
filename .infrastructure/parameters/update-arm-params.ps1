# I need a powershell scrip that loops though all the .bicepparam files
# in the current directory and for each matching file, it should run the
# following command: bicep build-params [current file name]
# [current file name] should be the current file name in the loop

$files = Get-ChildItem -Path .\*.bicepparam -Recurse

foreach ($file in $files) {
    bicep build-params $file
}
