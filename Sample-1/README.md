Terraform script that creates Windows instances in AWS and configures it using ansible. To configure multiple instances, change the count value in the variable file.

I have split the code in different files for easier readability. You can use a single consolidated version by going to the Consolidated folder, should you prefer.

The script creates a subnet in each availability zone and then splits the instances across different subnets. It will create a subnet in each AZ regardless of the instance count. Please edit the code for subnet section if you wish to deploy a single subnet.

To run this script, the following requirements must be met:
1. The machine running the script must have ansible engine installed
2. AWS CLI installed and authenticated using an account with correct privileges
3. This script was tested using the following version:
    Terraform v0.12.25
    Provider.aws v2.63.0

I have included a sample install_applications.yml which can be used to install more applications. The script currently refers to the ansible playbook to only install Google chrome.