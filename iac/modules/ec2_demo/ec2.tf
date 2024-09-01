#-------------------------------------------------------------------------------
# EC2 resources
#-------------------------------------------------------------------------------

locals {
  efs_mount_point = "/mnt/efs/fs1"
  instances       = toset(["x", "y"])
}

# TODO make two instances and verify they share a file system
resource "aws_instance" "demo" {
  for_each = local.instances

  instance_type        = "t3.nano"
  key_name             = aws_key_pair.demo.key_name
  ami                  = data.aws_ami.amazon_linux.id
  iam_instance_profile = aws_iam_instance_profile.demo.name

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
- printf "\n${var.file_system_id}:/ ${local.efs_mount_point} efs tls,_netdev\n" >> /etc/fstab
- test -f "/sbin/mount.efs" && grep -ozP 'client-info]\nsource' '/etc/amazon/efs/efs-utils.conf'; if [[ $? == 1 ]]; then printf "\n[client-info]\nsource=liw\n" >> /etc/amazon/efs/efs-utils.conf; fi;
- retryCnt=15; waitTime=30; while true; do mount -a -t efs,nfs4 defaults; if [ $? = 0 ] || [ $retryCnt -lt 1 ]; then echo File system mounted successfully; break; fi; echo File system not available, retrying to mount.; ((retryCnt--)); sleep $waitTime; done;
  EOF

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.demo[each.key].id
  }

  tags = merge(local.tags, {
    Name = "${local.id}-${each.value}"
  })
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


#-------------------------------------------------------------------------------
# Network
#-------------------------------------------------------------------------------

resource "aws_security_group" "demo" {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  name   = local.id

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

resource "aws_network_interface" "demo" {
  for_each = local.instances

  source_dest_check = false
  subnet_id         = local.private_subnets[0]
  security_groups   = [aws_security_group.demo.id]

  tags = {
    Name = "${local.id}-${each.key}"
  }
}

#-------------------------------------------------------------------------------
# IAM
#-------------------------------------------------------------------------------

resource "aws_iam_role" "demo" {
  name = local.id
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Effect" : "Allow",
      "Principal" : { "Service" : "ec2.amazonaws.com" },
      "Action" : "sts:AssumeRole"
    }
  })
}

resource "aws_iam_role_policy_attachment" "demo" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.demo.name
}

resource "aws_iam_instance_profile" "demo" {
  name = local.id
  role = aws_iam_role.demo.name
}

# resource "aws_network_interface" "network_interface" {
#   source_dest_check = false
#   subnet_id         = var.public_subnets_ids[0]
#   security_groups   = [aws_security_group.nat_instance_sg.id]

#   tags = {
#     Name = "${local.id}-nat-instance-network-interface"
#   }
# }

#-------------------------------------------------------------------------------
# Key pair
#-------------------------------------------------------------------------------

resource "tls_private_key" "demo" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "demo" {
  key_name   = local.id
  public_key = tls_private_key.demo.public_key_openssh
}
