terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.45"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.ec2_availability_zone
}

resource "aws_instance" "app_server" {
  ami           = var.ec2_ami_id
  instance_type = var.ec2_instanc_type

  tags = {
    Name = var.ec2_instance_name
  }
}

module "rds_example_complete-mysql" {
  source  = "terraform-aws-modules/rds/aws//examples/complete-mysql"
  version = "5.6.0"
}
