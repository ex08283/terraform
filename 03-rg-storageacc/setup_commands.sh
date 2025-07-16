az login

unset ARM_CLIENT_ID
unset ARM_CLIENT_SECRET
unset ARM_SUBSCRIPTION_ID
unset ARM_TENANT_ID

az ad sp create-for-rbac --name "az-demo" --role Contributor --scopes /subscriptions/$(az account show --query id -o tsv) --sdk-auth > azureauth.json

tf init

tf validate

tf plan 