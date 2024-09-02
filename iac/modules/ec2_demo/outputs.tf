#------------------------------------------------------------------------------
# ec2.tf
#------------------------------------------------------------------------------

resource "aws_ssm_parameter" "mount_target_iam_role_arn" {
  name  = "${local.output_prefix}/mount_target/iam_role_arn"
  type  = "String"
  value = aws_iam_role.mount_target.arn
  tags  = local.tags
}

output "mount_target_iam_role_arn" {
  value = aws_iam_role.mount_target.arn
}

resource "aws_ssm_parameter" "mount_target_iam_role_name" {
  name  = "${local.output_prefix}/mount_target/iam_role_name"
  type  = "String"
  value = aws_iam_role.mount_target.name
  tags  = local.tags
}

resource "aws_ssm_parameter" "mount_target_instance_profile_arn" {
  name  = "${local.output_prefix}/mount_target/instance_profile_arn"
  type  = "String"
  value = aws_iam_instance_profile.mount_target.arn
  tags  = local.tags
}

resource "aws_ssm_parameter" "mount_target_instance_profile_id" {
  name  = "${local.output_prefix}/mount_target/instance_profile_id"
  type  = "String"
  value = aws_iam_instance_profile.mount_target.id
  tags  = local.tags
}

resource "aws_ssm_parameter" "mount_target_key_pair_key_pem" {
  name        = "${local.output_prefix}/mount_target/key_pair_key_pem"
  description = "${local.id}-ec2-nat-instance ssh key"
  type        = "SecureString"
  value       = tls_private_key.mount_target.private_key_pem
  tags        = local.tags
}


resource "aws_ssm_parameter" "access_point_iam_role_arn" {
  name  = "${local.output_prefix}/access_point/iam_role_arn"
  type  = "String"
  value = aws_iam_role.access_point.arn
  tags  = local.tags
}

output "access_point_iam_role_arn" {
  value = aws_iam_role.access_point.arn
}

resource "aws_ssm_parameter" "access_point_iam_role_name" {
  name  = "${local.output_prefix}/access_point/iam_role_name"
  type  = "String"
  value = aws_iam_role.access_point.name
  tags  = local.tags
}

resource "aws_ssm_parameter" "access_point_instance_profile_arn" {
  name  = "${local.output_prefix}/access_point/instance_profile_arn"
  type  = "String"
  value = aws_iam_instance_profile.access_point.arn
  tags  = local.tags
}

resource "aws_ssm_parameter" "access_point_instance_profile_id" {
  name  = "${local.output_prefix}/access_point/instance_profile_id"
  type  = "String"
  value = aws_iam_instance_profile.access_point.id
  tags  = local.tags
}

resource "aws_ssm_parameter" "access_point_key_pair_key_pem" {
  name        = "${local.output_prefix}/access_point/key_pair_key_pem"
  description = "${local.id}-ec2-nat-instance ssh key"
  type        = "SecureString"
  value       = tls_private_key.access_point.private_key_pem
  tags        = local.tags
}
