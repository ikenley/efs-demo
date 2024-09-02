#-------------------------------------------------------------------------------
# Main regional resources
#-------------------------------------------------------------------------------

module "regional_primary" {
  source = "../main_regional"

  providers = {
    aws = aws.primary
  }

  namespace = var.namespace
  env       = var.env
  is_prod   = var.is_prod

  read_write_root_role_arns = var.read_write_root_role_arns

  file_system_arn = aws_efs_file_system.primary.arn
  file_system_id  = aws_efs_file_system.primary.id
}
