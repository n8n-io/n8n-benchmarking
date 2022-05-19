# n8n Benchmarking

![n8n.io - Workflow Automation](https://raw.githubusercontent.com/n8n-io/n8n/master/assets/n8n-logo.png)

Customizable and extendable benchmarking framework for n8n.io

## Usage


### Requirements
- AWS console
- terraform

### Steps

1. Install [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

2. Clone this repository, and open `tf/aws` folder in the terminal

3. Run `terraform init`

4. Set [AWS Access keys environment variables](https://learn.hashicorp.com/tutorials/terraform/aws-build#prerequisites) or use any of the authentication methods [provided here](https://www.terraform.io/docs/providers/aws/index.html#environment-variables)

5. Update variables in main.tf as needed

6. Run `terraform apply` and enter 'yes' when propmpted

### How it works





