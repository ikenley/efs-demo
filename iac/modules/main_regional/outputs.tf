#------------------------------------------------------------------------------
# todo.tf
#------------------------------------------------------------------------------

resource "aws_ssm_parameter" "file_system_arn" {
  name  = "${local.output_prefix}/file_system_arn"
  type  = "String"
  value = var.file_system_arn
}

resource "aws_ssm_parameter" "file_system_id" {
  name  = "${local.output_prefix}/file_system_id"
  type  = "String"
  value = var.file_system_id
}

resource "aws_ssm_parameter" "efs_mount_target_security_group_arn" {
  name  = "${local.output_prefix}/efs_mount_target_security_group_arn"
  type  = "String"
  value = aws_security_group.efs_mount_target.arn
}

resource "aws_ssm_parameter" "efs_mount_target_security_group_id" {
  name  = "${local.output_prefix}/efs_mount_target_security_group_id"
  type  = "String"
  value = aws_security_group.efs_mount_target.id
}
