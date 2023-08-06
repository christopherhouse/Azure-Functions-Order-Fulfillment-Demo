#!/bin/bash
KEY=$(az functionapp keys list --resource-group $1 --name $2 --query "functionKeys.default" -o tsv)

az keyvault secret set --vault-name $3 --name "FunctionAppKey" --value $KEY
