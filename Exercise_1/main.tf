# TODO: Designate a cloud provider, region, and credentials


# TODO: provision 4 AWS t2.micro EC2 instances named Udacity T2


# TODO: provision 2 m4.large EC2 instances named Udacity M4
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "udacity_t2" {
  count = "4"
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"

  tags = {
    Name = var.t2_instance_name
  }
}

resource "aws_instance" "udacity_m4" {
  count = "2"
  ami           = "ami-007855ac798b5175e"
  instance_type = "m4.large"

  tags = {
    Name = var.m4_instance_name
  }
}
