terraform {
  required_version = ">= 1.10"

  backend "s3" {
    bucket       = "barlow-terraform"
    key          = "barlow/automation/terraform.tfstate"
    region       = "ap-northeast-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "archive_file" "ack" {
  type        = "zip"
  source_dir  = "${path.module}/functions/ack"
  output_path = "${path.module}/.build/ack.zip"
}

data "archive_file" "worker" {
  type        = "zip"
  source_dir  = "${path.module}/functions/worker"
  output_path = "${path.module}/.build/worker.zip"
}
