Terraform script that creates Windows instances in Azure in a windows domain.

The script deploys a domain controller and then creates and adds 3 windows instances to the domain.

I have split the code in different files for easier readability.

Pre-Requisites:
- Azure CLI: v2.5.1
- Terraform: v0.13.0
- Provider.azurerm: v2.99
- Provider.hashicorp-random: v3.0.0