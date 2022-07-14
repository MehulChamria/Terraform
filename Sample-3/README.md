Terraform script that creates Windows instances in Azure in a windows domain.

The script deploys a domain controller and then creates and adds 3 windows instances to the domain.

I have split the code in different files for easier readability.

To run this script, the following requirements must be met:
1. AWS CLI installed and authenticated using an account with correct privileges
2. This script was tested using the following version:
    Terraform v0.13.0
    Provider.azurerm v2.99
    Provider.hashicorp-random v3.0.0