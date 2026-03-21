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
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

locals {
  tags = {
    env         = "automation"
    Environment = "Prod"
    Service     = "barlow-automation"
  }
}
