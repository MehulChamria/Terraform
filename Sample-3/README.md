Terraform script that creates Windows instances in Azure in a windows domain.

The script deploys a domain controller and then creates and adds 3 windows instances to the domain.

I have split the code in different files for easier readability.

This script was tested with the configuration below:
- Azure CLI: v2.5.1
- Terraform: v0.13.0
- Provider.azurerm: v2.99
- Provider.hashicorp-random: v3.0.0
- Windows 10: 21H2
- Powershell: 7.2.5 (CMD or PS 5.0 can also be used)

To run the script:
1. Open a shell and navigate to the script directory
2. Run 'az login' and sign in with your credentials
3. Run 'az account set --subscription "SUBSCRIPTION NAME"' to set the subscription to deploy the resources in
4. Run 'terraform init' to initialize terraform in the script directory
5. Run 'terraform validate' to validate the code for any syntax errors
6. Run 'terraform apply' to apply the configuration and type 'Yes' when approval is requested

To destroy the resources:
1. Run 'terraform destroy' and type 'Yes' when approval is requested
2. If terraform times out or fails to delete the Recovery Service Vault, login to azure to manaully delete the vault. Instructions to delete a vault can be found [here](https://docs.microsoft.com/en-us/azure/backup/backup-azure-delete-vault?tabs=portal). Once deleted, rerun the destroy command and terraform should be able to destroy the remaining resources, if any.