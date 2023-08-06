#!/bin/bash
KEY=$($key = az functionapp keys list --resource-group $1 --name $2 --query "functionKeys.default" -o tsv)

echo "##vso[task.setvariable variable=FUNCTION_KEY]$functionKey"
