Terraform script that creates Windows instances in AWS and configures it using ansible.
To run this script, the following requirements must be met:
1. The machine running the script must have ansible engine installed
2. AWS CLI installed and authenticated using an account with correct privileges
3. This script was tested using the following version:
    Terraform v0.12.25
    Provider.aws v2.63.0

I have included a sample install_applications.yml which can be used to install more applications. The script currently refers to the ansible playbook to only install Google chrome.