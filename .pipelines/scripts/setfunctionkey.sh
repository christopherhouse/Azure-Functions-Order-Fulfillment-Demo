#!/bin/bash
KEY=$($key = az functionapp keys list --resource-group $0 --name $1 --query "functionKeys.default" -o tsv)

az keyvault set --vault-name $2 --name "FunctionAppKey" --value "$KEY"
