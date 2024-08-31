#-------------------------------------------------------------------------------
# Regional EFS resources
#-------------------------------------------------------------------------------

resource "aws_efs_mount_target" "this" {
  for_each = local.private_subnets

  file_system_id = var.file_system_id
  subnet_id      = each.value

  security_groups = []
}
