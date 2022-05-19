# n8n Benchmarking

![n8n.io - Workflow Automation](https://raw.githubusercontent.com/n8n-io/n8n/master/assets/n8n-logo.png)

Customizable and extendable benchmarking framework for n8n.io

## Requirements
- terraform
- AWS account access

## Usage

1. Install [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

2. Clone this repository

3. Using a terminal, navigate to `n8n-benchmarking/tf/aws` folder and run `terraform init`

4. Set [AWS Access keys environment variables](https://learn.hashicorp.com/tutorials/terraform/aws-build#prerequisites) or use any of the authentication methods [provided here](https://www.terraform.io/docs/providers/aws/index.html#environment-variables)

5. Run `terraform apply` and follow the prompts


## How it works

Some keywords:
- Runner: Instance running the tests
- Worker: Instance running n8n being load tested

More details and complete readme comming soon...