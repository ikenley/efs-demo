#-------------------------------------------------------------------------------
# EC2 instance which has root-level access and mounts via a Access Point
# https://docs.aws.amazon.com/efs/latest/ug/efs-access-points.html
#-------------------------------------------------------------------------------

locals {
  access_point_id = "${local.id}-access-point"
}

resource "aws_instance" "access_point" {
  instance_type        = "t3.nano"
  key_name             = aws_key_pair.access_point.key_name
  ami                  = data.aws_ami.amazon_linux.id
  iam_instance_profile = aws_iam_instance_profile.access_point.name

  # Configure automatic EFS mounting
  user_data = <<EOF
#cloud-config
package_update: true
package_upgrade: true
runcmd:
- yum install -y amazon-efs-utils
- apt-get -y install amazon-efs-utils
- yum install -y nfs-utils
- apt-get -y install nfs-common
- file_system_id_1=${var.file_system_id}
- efs_mount_point_1=${local.efs_mount_point}
- mkdir -p "${local.efs_mount_point}"
- printf "\n${var.file_system_id}:/ ${local.efs_mount_point} efs tls,iam,_netdev,accesspoint=${var.access_point_id}\n" >> /etc/fstab
- test -f "/sbin/mount.efs" && grep -ozP 'client-info]\nsource' '/etc/amazon/efs/efs-utils.conf'; if [[ $? == 1 ]]; then printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf; fi;
- retryCnt=15; waitTime=30; while true; do mount -a -t efs,nfs4 defaults; if [ $? = 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;
  EOF

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.access_point.id
  }

  tags = merge(local.tags, {
    Name = local.access_point_id
  })
}

#-------------------------------------------------------------------------------
# Network
#-------------------------------------------------------------------------------

resource "aws_security_group" "access_point" {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  name   = local.access_point_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = local.id
  }
}

resource "aws_network_interface" "access_point" {
  source_dest_check = false
  subnet_id         = local.private_subnets[0]
  security_groups   = [aws_security_group.access_point.id]

  tags = {
    Name = local.access_point_id
  }
}

#-------------------------------------------------------------------------------
# IAM
#-------------------------------------------------------------------------------

resource "aws_iam_role" "access_point" {
  name = local.access_point_id
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Principal" : { "Service" : "ec2.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }
  })
}

resource "aws_iam_role_policy_attachment" "access_point" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.access_point.name
}

resource "aws_iam_instance_profile" "access_point" {
  name = local.access_point_id
  role = aws_iam_role.access_point.name
}

#-------------------------------------------------------------------------------
# Key pair
#-------------------------------------------------------------------------------

resource "tls_private_key" "access_point" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "access_point" {
  key_name   = local.access_point_id
  public_key = tls_private_key.access_point.public_key_openssh
}
