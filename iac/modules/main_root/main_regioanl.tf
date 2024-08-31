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

  file_system_id = aws_efs_file_system.primary.id
}
