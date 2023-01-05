provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

variable "subnets_cidr" {
  type        = map(any)
  default = {
    "appA" : "10.0.10.0/24",
    "appB" : "10.0.20.0/24"
  }
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "this" {
  for_each = {
    for k, v in var.subnets_cidr : k => v
  }
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value
}

module "main_sg" {
  source = "github.com/terraform-aws-modules/terraform-aws-security-group"

  name        = "main-sg"
  description = "Security group which is used as an argument in complete-sg"
  vpc_id      = aws_vpc.this.id

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["https-443-tcp"]
}

output "vpc_id" {
  value = aws_vpc.this.id
}
