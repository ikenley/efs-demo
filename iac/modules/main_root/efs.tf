#-------------------------------------------------------------------------------
# Core EFS setup
# This is not in the regional module in order to enable replication
#-------------------------------------------------------------------------------

resource "aws_efs_file_system" "primary" {
  provider = aws.primary

  creation_token = local.id

  encrypted = true

  throughput_mode = "elastic"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = merge(local.tags, {
    Name = local.id
  })
}
