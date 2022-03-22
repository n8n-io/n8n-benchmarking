terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

variable "ami-worker" {
  default = "ami-0d2c65fedcacc5f45"
}

variable "ami-runner" {
  default = "ami-0bf65bd445cd54014"
}

variable "instance-type-small" {
  default = "t3.small"
}

variable "instance-type-large" {
  default = "t3.large"
}

variable "resultsRecieverURL" {
  default = "https://ahsan.app.n8n.cloud/webhook/submit-result"
}

// MAIN_MODE

locals {
  worker_main_ip           = aws_instance.worker-main.private_ip

  benchmark_scripts_main = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/home/ubuntu/vegeta/tests"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/tests-main")
    },
    {
      path        = "/home/ubuntu/vegeta/workers_health.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/workers_health.sh")
    },
    {
      path        = "/home/ubuntu/vegeta/results_to_csv.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/results_to_csv.sh")
    },
    {
      path        = "/home/ubuntu/vegeta/run_tests.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/run_tests.sh")
    },
  ]
})}
  END
}

data "cloudinit_config" "runner_init_main" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "benchmark_scripts_main"
    content      = local.benchmark_scripts_main
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "example.sh"
    content = templatefile("${path.module}/script-templates/runner/start_script.tftpl", {
      workerIp           = "${local.worker_main_ip}:5678",
      testFile           = "tests-main",
      n8nMode            = "main",
      workerInstanceSize = "${var.instance-type-large}",
      resultsRecieverURL = "${var.resultsRecieverURL}",
      queueWorkerIp1 = "",
      queueWorkerIp2 = "",
      queueWorkerIp3 = ""
    })
  }
}

resource "aws_instance" "runner-main" {
  ami           = var.ami-runner
  instance_type = var.instance-type-small
  key_name      = "aws-test-instance-01-keypair"
  user_data     = data.cloudinit_config.runner_init_main.rendered
  tags = {
    Name = "n8n-benchmark_runner_main-mode"
  }
}

resource "aws_instance" "worker-main" {
  ami           = var.ami-worker
  instance_type = var.instance-type-large
  key_name      = "aws-test-instance-01-keypair"
  user_data = templatefile("${path.module}/script-templates/worker/worker_start_script.tftpl", {
    n8nExecutionsProcess = "main",
    n8nExecutionsMode    = "regular",
    n8nVersion           = "0.174.0"
  })

  tags = {
    Name = "n8n-benchmark_worker_main-mode"
  }
}

// OWN_MODE

locals {
  worker_own_ip           = aws_instance.worker-own.private_ip

  benchmark_scripts_own = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/home/ubuntu/vegeta/tests"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/tests-own")
    },
    {
      path        = "/home/ubuntu/vegeta/workers_health.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/workers_health.sh")
    },
    {
      path        = "/home/ubuntu/vegeta/results_to_csv.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/results_to_csv.sh")
    },
    {
      path        = "/home/ubuntu/vegeta/run_tests.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/run_tests.sh")
    },
  ]
})}
  END
}

data "cloudinit_config" "runner_init_own" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "benchmark_scripts_own"
    content      = local.benchmark_scripts_own
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "example.sh"
    content = templatefile("${path.module}/script-templates/runner/start_script.tftpl", {
      workerIp           = "${local.worker_own_ip}:5678",
      testFile           = "tests-own",
      n8nMode            = "own",
      workerInstanceSize = "${var.instance-type-large}",
      resultsRecieverURL = "${var.resultsRecieverURL}",
      queueWorkerIp1 = "",
      queueWorkerIp2 = "",
      queueWorkerIp3 = ""
    })
  }
}


resource "aws_instance" "runner-own" {
  ami           = var.ami-runner
  instance_type = var.instance-type-small
  key_name      = "aws-test-instance-01-keypair"
  user_data     = data.cloudinit_config.runner_init_own.rendered
  tags = {
    Name = "n8n-benchmark_runner_own-mode"
  }
}

resource "aws_instance" "worker-own" {
  ami           = var.ami-worker
  instance_type = var.instance-type-large
  key_name      = "aws-test-instance-01-keypair"
  user_data = templatefile("${path.module}/script-templates/worker/worker_start_script.tftpl", {
    n8nExecutionsProcess = "own",
    n8nExecutionsMode    = "regular",
    n8nVersion           = "0.174.0"
  })

  tags = {
    Name = "n8n-benchmark_worker_own-mode"
  }
}

// QUEUE_MODE

locals {
  worker_queue_main_ip           = aws_instance.worker-queue-main.private_ip
  worker_queue_worker_1_ip           = aws_instance.worker-queue-worker-1.private_ip
  worker_queue_worker_2_ip           = aws_instance.worker-queue-worker-2.private_ip
  worker_queue_worker_3_ip           = aws_instance.worker-queue-worker-3.private_ip

  benchmark_scripts_queue = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/home/ubuntu/vegeta/tests"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/tests-queue")
    },
    {
      path        = "/home/ubuntu/vegeta/workers_health.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/workers_health.sh")
    },
    {
      path        = "/home/ubuntu/vegeta/results_to_csv.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/results_to_csv.sh")
    },
    {
      path        = "/home/ubuntu/vegeta/run_tests.sh"
      permissions = "0755"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../vegeta/run_tests.sh")
    },
  ]
})}
  END
}

data "cloudinit_config" "runner_init_queue" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "benchmark_scripts_queue"
    content      = local.benchmark_scripts_queue
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "example.sh"
    content = templatefile("${path.module}/script-templates/runner/start_script.tftpl", {
      workerIp           = "${local.worker_queue_main_ip}:5678",
      testFile           = "tests-own",
      n8nMode            = "own",
      workerInstanceSize = "${var.instance-type-large}",
      resultsRecieverURL = "${var.resultsRecieverURL}",
      queueWorkerIp1 = "${local.worker_queue_worker_1_ip}:5679",
      queueWorkerIp2 = "${local.worker_queue_worker_2_ip}:5679",
      queueWorkerIp3 = "${local.worker_queue_worker_3_ip}:5679"
    })
  }
}


resource "aws_instance" "runner-queue" {
  ami           = var.ami-runner
  instance_type = var.instance-type-small
  key_name      = "aws-test-instance-01-keypair"
  user_data     = data.cloudinit_config.runner_init_queue.rendered
  tags = {
    Name = "n8n-benchmark_runner_queue-mode"
  }
}

# resource "aws_instance" "runner-queue" {
#   ami           = var.ami-runner
#   instance_type = var.instance-type-small
#   key_name      = "aws-test-instance-01-keypair"
#   user_data = templatefile("${path.module}/script-templates/runner/start_script.tftpl", {
#     workerIp           = local.worker_queue_main_ip,
#     queueWorkerIp1     = local.worker_queue_worker_1_ip,
#     queueWorkerIp2     = local.worker_queue_worker_2_ip,
#     queueWorkerIp3     = local.worker_queue_worker_3_ip,
#     testFile           = "tests-queue",
#     n8nMode            = "queue",
#     workerInstanceSize = "${var.instance-type-large}",
#     resultsRecieverURL = "${var.resultsRecieverURL}"
#   })
#   tags = {
#     Name = "n8n-benchmark_runner_queue-mode"
#   }
# }

locals {
  n8n_test_workflows = <<-END
    #cloud-config
    ${jsonencode({
  write_files = [
    {
      path        = "/home/ubuntu/n8n/appdata/workflows/workflow-1.json"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../n8n/workflows/workflow-1.json")
    },
    {
      path        = "/home/ubuntu/n8n/appdata/workflows/workflow-2.json"
      permissions = "0644"
      owner       = "root:root"
      encoding    = "b64"
      content     = filebase64("${path.module}/../../n8n/workflows/workflow-2.json")
    },
  ]
})}
  END
}

data "cloudinit_config" "worker_init" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "workflows"
    content      = local.n8n_test_workflows
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "example.sh"
    content = templatefile("${path.module}/script-templates/worker/queue_main_worker_start_script.tftpl", {
      postgresHost = "postgres",
      redisHost    = "redis",
      n8nVersion   = "0.174.0"
    })
  }
}

resource "aws_instance" "worker-queue-main" {
  ami           = var.ami-worker
  instance_type = var.instance-type-large
  key_name      = "aws-test-instance-01-keypair"
  user_data     = data.cloudinit_config.worker_init.rendered

  tags = {
    Name = "n8n-benchmark_worker_queue-main"
  }
}

resource "aws_instance" "worker-queue-worker-1" {
  ami           = var.ami-worker
  instance_type = var.instance-type-large
  key_name      = "aws-test-instance-01-keypair"
  user_data = templatefile("${path.module}/script-templates/worker/queue_worker_start_script.tftpl", {
    postgresHost = "${local.worker_queue_main_ip}",
    redisHost    = "${local.worker_queue_main_ip}",
    n8nVersion   = "0.174.0"
  })

  tags = {
    Name = "n8n-benchmark_worker_queue-worker-1"
  }
}

resource "aws_instance" "worker-queue-worker-2" {
  ami           = var.ami-worker
  instance_type = var.instance-type-large
  key_name      = "aws-test-instance-01-keypair"
  user_data = templatefile("${path.module}/script-templates/worker/queue_worker_start_script.tftpl", {
    postgresHost = "${local.worker_queue_main_ip}",
    redisHost    = "${local.worker_queue_main_ip}",
    n8nVersion   = "0.174.0"
  })

  tags = {
    Name = "n8n-benchmark_worker_queue-worker-2"
  }
}

resource "aws_instance" "worker-queue-worker-3" {
  ami           = var.ami-worker
  instance_type = var.instance-type-large
  key_name      = "aws-test-instance-01-keypair"
  user_data = templatefile("${path.module}/script-templates/worker/queue_worker_start_script.tftpl", {
    postgresHost = "${local.worker_queue_main_ip}",
    redisHost    = "${local.worker_queue_main_ip}",
    n8nVersion   = "0.174.0"
  })

  tags = {
    Name = "n8n-benchmark_worker_queue-worker-3"
  }
}
