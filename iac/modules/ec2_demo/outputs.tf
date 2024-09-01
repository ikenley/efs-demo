#------------------------------------------------------------------------------
# ec2.tf
#------------------------------------------------------------------------------

resource "aws_ssm_parameter" "demo_iam_role_arn" {
  name  = "${local.output_prefix}/demo_iam_role_arn"
  type  = "String"
  value = aws_iam_role.demo.arn
  tags  = local.tags
}

resource "aws_ssm_parameter" "demo_iam_role_name" {
  name  = "${local.output_prefix}/demo_iam_role_name"
  type  = "String"
  value = aws_iam_role.demo.name
  tags  = local.tags
}

resource "aws_ssm_parameter" "demo_instance_profile_arn" {
  name  = "${local.output_prefix}/demo_instance_profile_arn"
  type  = "String"
  value = aws_iam_instance_profile.demo.arn
  tags  = local.tags
}

resource "aws_ssm_parameter" "demo_instance_profile_id" {
  name  = "${local.output_prefix}/demo_instance_profile_id"
  type  = "String"
  value = aws_iam_instance_profile.demo.id
  tags  = local.tags
}

resource "aws_ssm_parameter" "key_pair_key_pem" {
  name        = "${local.output_prefix}/key_pair_key_pem"
  description = "${local.id}-ec2-nat-instance ssh key"
  type        = "SecureString"
  value       = tls_private_key.demo.private_key_pem
  tags        = local.tags
}

