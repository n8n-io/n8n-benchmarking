# n8n Benchmarking

![n8n.io - Workflow Automation](https://raw.githubusercontent.com/n8n-io/n8n/master/assets/n8n-logo.png)

Customizable and extendable benchmarking framework for n8n.io

## Usage


## Requirements
- AWS console
- terraform

## Steps

1. Install [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

2. Clone this repository, and open `tf/aws` folder in the terminal

3. Run `terraform init`

4. Set [AWS Access keys environment variables](https://learn.hashicorp.com/tutorials/terraform/aws-build#prerequisites) or use any of the authentication methods [provided here](https://www.terraform.io/docs/providers/aws/index.html#environment-variables)

5. Update variables in main.tf as needed

6. Run `terraform apply` and enter 'yes' when propmpted

## How it works

### Concepts
- Runner: An EC2 instance that runs the tests
- Worker: An EC2 instance running n8n being load tested

### Process

Once `terraform apply` is run, it will try to create Runner and Worker instance as configured in the `main.tf` file.

Runner will wait for the worker instances to be ready, and then run tests as defined in the mode specific tests file (`tests-own`, `tests-main`, `tests-queue`) in the vegeta folder.

After the tests have completed, the results are send via a post call in JSON format, to the endpoint specified in `main.tf` in the variable `resultsRecieverURL`. `resultsRecieverURL` must be an endpoint that accepts POST requests with JSON payload.
