#-------------------------------------------------------------------------------
# Demo EC2 instance which mounts an EFS system
# This cuts some Terraform corners, but the underlying compute is valid + secure
#-------------------------------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.65.0"
      configuration_aliases = [aws.primary]
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  aws_region = data.aws_region.current.name

  id            = "${var.namespace}-${var.env}-ec2-demo"
  output_prefix = "/${var.namespace}/${var.env}/ec2-demo"

  tags = merge(var.tags, {
    Terraform   = true
    Environment = var.env
    is_prod     = var.is_prod
    module      = "ec2_demo"
  })
}
