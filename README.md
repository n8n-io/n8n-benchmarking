# n8n Benchmarking

![n8n.io - Workflow Automation](https://raw.githubusercontent.com/n8n-io/n8n/master/assets/n8n-logo.png)

Customizable and extendable benchmarking framework for n8n.io

## Requirements

- Terraform
- AWS account access

## Usage

1. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started).

2. Clone this repository.

3. Using a terminal, navigate to `n8n-benchmarking/tf/aws` folder and start Terraform.

```
$ cd n8n-benchmarking/tf/aws
$ terraform init
```

4. Set [AWS Access keys environment variables](https://learn.hashicorp.com/tutorials/terraform/aws-build#prerequisites) or use any of the authentication methods [provided here](https://www.terraform.io/docs/providers/aws/index.html#environment-variables).

5. Apply Terraform config and follow the prompts

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

6. Wait for the tests to finish. The endpoint you provided should receive results.

## Concept

Deploy and run n8n benchmarking tests using [Vegeta](https://github.com/tsenart/vegeta).

Terraform sets up the n8n instances, then loads and activates the tests workflows. The workflows are then triggered by Vegeta attacks at various rates.

The runner instances collect the results. Once all the tests have completed, Terraform sends the results to the provided endpoint using a POST request, in JSON format.

## Tests

Tests are defined in tests file for each of the modes in the `vegeta` folder.

```
1 100 120 100
1 110 120 100
```

Each line in the test file defines a test run.

```
<workflowId> <rate> <duration in seconds> <timeout in seconds>
```

## Workflows

The workflows used in the tests are in the `n8n/workflows` folder.

To update, create a workflow with a webhook node in any n8n instance, download it as JSON and paste the contents / replace the file. Make sure the webhook `path` is `workflow-<id>`, where `id` is the number of the workflow.

It is possible to add more than two workflows by modifying the scripts and the Terraform config.

## Results

The results are generated and saved in the runner instance under `/home/ubuntu/vegeta/results`.

Once the test runs have finsished on each runner, the results are POSTed to the provided endpoint.

The posted results is an array of results of each run, as described in the `tests-<mode>` file.

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

For more information on how to interpret these results, check out the [Vegeta docs](https://github.com/tsenart/vegeta).

## Setup

### Instances

Running the Terraform apply command triggers creation of ec2 instances for workers and runners for three different modes of n8n:

- [Own mode](https://docs.n8n.io/hosting/scaling/execution-modes-processes/#own)
    - One runner instance
    - One worker instance
- [Main mode](https://docs.n8n.io/hosting/scaling/execution-modes-processes/#main)
    - One runner instance
    - One worker instance
- [Queue mode](https://docs.n8n.io/hosting/scaling/queue-mode/)
    - One runner instance
    - One worker instance for main process running:
        - n8n main process
        - postgres server
        - redis server
    - Three worker instances running n8n queue mode worker
    - Two worker instances running n8n queue mode webhook

### Security group

An AWS security group will also be created to allow traffic between the instances.

### AWS image

The worker and runner instances use a publicly available AMI `n8n Benchmark AMI` (ami-01bcb21f02a5da66f) created by n8n.

This AMI has docker, docker-compose and so on installed.


## Process

All instances run the relevant start script on initialization using cloud-init. All relevant files are injected through Terraform.

### Worker instance

- Creates a `.env` file for n8n docker-compose
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

## Teardown

It is important to teardown the infrastructure once it's not needed anymore. That can be done using the Terraform destroy command.

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
