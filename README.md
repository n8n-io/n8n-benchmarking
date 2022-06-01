# n8n Benchmarking

![n8n.io - Workflow Automation](https://raw.githubusercontent.com/n8n-io/n8n/master/assets/n8n-logo.png)

Customizable and extendable benchmarking framework for n8n.io

## Requirements
- terraform
- AWS account access

## Usage

1. Install [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started)

2. Clone this repository

3. Using a terminal, navigate to `n8n-benchmarking/tf/aws` folder and init terraform
```
$ cd n8n-benchmarking/tf/aws
$ terraform init
```

4. Set [AWS Access keys environment variables](https://learn.hashicorp.com/tutorials/terraform/aws-build#prerequisites) or use any of the authentication methods [provided here](https://www.terraform.io/docs/providers/aws/index.html#environment-variables)

5. Apply terraform config and follow the prompts
```
$ terraform apply
var.aws_default_region
  AWS region

  Enter a value: eu-central-1

var.results_reciever_url
  Endpoint to post test results

  Enter a value: https://ahsan.app.n8n.cloud/webhook/submit-result

data.cloudinit_config.main_worker_init: Reading...
...
...
Plan: 12 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_security_group.allow_n8n_ssh: Creating...
...
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
```
6. Wait for the tests to finish and results to be recieved by the provided endpoint.

## Concept

Deploy and run n8n benchmarking tests using [Vegeta](https://github.com/tsenart/vegeta).

The n8n instances are setup and tests workflows are injected and activated. The workflows are then triggered by Vegeta attacks at various rates.

The results are collected in the runner instances. Once all the tests have completed, the results are sent to the provided endpoint via POST request, in JSON format.

### Output JSON

```
[
  {
    "Workflow": "2",
    "Mode": "main",
    "Instance": "c5a.large",
    "Rate": 5.008350546196305,
    "Mean": 2872085230,
    "P50": 2842767034,
    "P90": 3491964331,
    "P95": 3653984585,
    "P99": 3950485875,
    "Max": 4147902974,
    "Min": 2131704885,
    "SuccessRate": 1,
    "Throughput": 4.88118787907983,
    "status_codes": {
      "200": 600
    },
    "errors": []
  }
]
```

## Tests
Tests are defined in tests file for each of the modes in `vegeta` folder.

```
1 100 120 100
1 110 120 100
```

Each line in the test file defines a test run.
```
<workflowId> <rate> <duration in seconds> <timeout in seconds>
```

For more details on how these values are used, check out [Vegeta docs](https://github.com/tsenart/vegeta).

## Workflows
The workflows injected and used to run tests with can be found in `n8n/workflows` folder.

To update, simply create a workflow with webhook node in any n8n instance, download it in a file and paste the contents / replace the file. Make sure the webhook `path` is `workflow-<id>`, where id is the number of the workflow.

It is possible to add more than 2 workflows by modifying the scripts, and tf config.

## Setup

### Instances

Running the terraform apply command would trigger creation of ec2 instances for workers and runners for 3 different modes of n8n:
- [Own mode](https://docs.n8n.io/hosting/scaling/execution-modes-processes/#own)
    - 1 Runner instance
    - 1 Worker instance
- [Main mode](https://docs.n8n.io/hosting/scaling/execution-modes-processes/#main)
    - 1 Runner instance
    - 1 Worker instance
- [Queue mode](https://docs.n8n.io/hosting/scaling/queue-mode/)
    - 1 Runner instance
    - 1 Worker instance for main process running:
        - n8n main process
        - postgres server
        - redis server
    - 3 Worker instances running n8n queue mode worker
    - 2 Worker instances running n8n queue mode webhook

### Security Group

An AWS security group will also be created to allow traffic between the instances.

### AWS Image

The worker and runner instances use publicly available AMI `n8n Benchmark AMI` (ami-01bcb21f02a5da66f) created by n8n.

This AMI has docker, docker-compose etc installed.

<br>

## Process

All instances run the relevant start script on initialization via cloud-init. All relevant files are injected through terraform.

### Worker instance
- Creates .env file for n8n docker-compose
- Runs docker-compose

### Runner instances
- Downloads and sets up Vegeta
- Checks for worker health
- Injects and activates workflows into the worker n8n instance
- Checks workflow health
- Initializes tests
- Formats and posts tests results

## Hooks

Once the tests have completed, results will be posted to the provided endpoint.

### Teardown

It is important to teardown the infrastructure once its not needed anymore. That can be done using terraform destroy command.

```
$ terraform destroy                
aws_security_group.allow_n8n_ssh: Refreshing state... 
...
Plan: 0 to add, 0 to change, 12 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
  ...
Destroy complete! Resources: 12 destroyed.
```
