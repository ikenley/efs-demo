#-------------------------------------------------------------------------------
# Regional EFS resources
#-------------------------------------------------------------------------------

resource "aws_efs_mount_target" "this" {
  for_each = local.private_subnets

  file_system_id = var.file_system_id
  subnet_id      = each.value

  security_groups = [aws_security_group.efs_mount_target.id]
}

#-------------------------------------------------------------------------------
# Security groups
#-------------------------------------------------------------------------------
resource "aws_efs_file_system_policy" "this" {
  file_system_id = var.file_system_id
  # TODO require IAM authentication + add in specific roles for 
  policy = <<EOF
{
   "Version":"2012-10-17",
   "Id":"efs-policy-wizard-fb09a7d8-fbaf-44ec-a350-769ee0df9926",
   "Statement":[
      {
         "Sid":"RequireSsl",
         "Effect":"Deny",
         "Principal":{
            "AWS":"*"
         },
         "Action":"*",
         "Resource":"${var.file_system_arn}",
         "Condition":{
            "Bool":{
               "aws:SecureTransport":"false"
            }
         }
      }
   ]
}
  EOF
}

#-------------------------------------------------------------------------------
# Security groups
#-------------------------------------------------------------------------------

resource "aws_security_group" "efs_mount_target" {
  name        = "${local.id}-efs-mount-target"
  description = "Inbound traffic from private subnets"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value

  tags = {
    Name = "${local.id}-efs-mount-target"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_nfs_private_subnet" {
  for_each = data.aws_subnet.private_subnets

  description = "Allow NFS from ${each.value.tags["Name"]}"

  security_group_id = aws_security_group.efs_mount_target.id
  cidr_ipv4         = each.value.cidr_block
  from_port         = 2049
  ip_protocol       = "tcp"
  to_port           = 2049

  tags = merge(local.tags, {
    Name = "nfs-from-${each.value.id}"
  })
}

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   security_group_id = aws_security_group.allow_tls.id
#   cidr_ipv4         = "0.0.0.0/0"
#   ip_protocol       = "-1" # semantically equivalent to all ports
# }
