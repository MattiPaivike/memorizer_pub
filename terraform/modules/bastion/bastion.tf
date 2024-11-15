data "aws_iam_policy_document" "instance_connect" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_connect" {
  name               = "${var.prefix}-BastionInstanceConnect"
  description        = "Privileges to use EC2 instance connect"
  assume_role_policy = data.aws_iam_policy_document.instance_connect.json

}

resource "aws_iam_role_policy_attachment" "instance_connect" {
  role       = aws_iam_role.instance_connect.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance_connect" {
  name = "${var.prefix}-BastionInstanceConnect"
  role = aws_iam_role.instance_connect.name

}

resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role       = aws_iam_role.instance_connect.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "ec2_instance_connect" {
  statement {
    actions   = ["ec2-instance-connect:SendSSHPublicKey"]
    resources = [aws_instance.bastion.arn]

    condition {
      test     = "StringEquals"
      variable = "ec2:osuser"
      values   = ["ec2-user", "ssm-user"]
    }
  }

  statement {
    actions = ["ssm:StartSession"]
    resources = [
      aws_instance.bastion.arn,
      "arn:aws:ssm:*:*:document/AWS-StartSSHSession",
      "arn:aws:ssm:*::document/AWS-StartPortForwardingSession",
    ]
  }

  statement {
    actions   = ["ssm:TerminateSession"]
    resources = ["arn:aws:ssm:*:*:session/&{aws:username}-*"]
  }

  statement {
    actions   = ["ec2:DescribeInstances"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_instance_connect" {
  name   = "${var.prefix}-BastionEC2InstanceConnect"
  policy = data.aws_iam_policy_document.ec2_instance_connect.json

}

data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.bastion_connections_security_groups

  iam_instance_profile        = aws_iam_instance_profile.instance_connect.name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 10
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    "Name" = "${var.instance_name}"
  }

  user_data = <<EOF
#!/bin/bash
yum update -y -q
yum install ec2-instance-connect
yum install postgresql
amazon-linux-extras install -y docker
systemctl enable docker.service
systemctl start docker.service
usermod -aG docker ec2-user
EOF
}

resource "aws_eip" "bastion_public_ip" {
  domain = "vpc"

  tags = {
    "Name" = "${var.instance_name}"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_public_ip.id
}