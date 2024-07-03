resource "aws_network_interface" "onprem_public_a" {
  subnet_id         = aws_subnet.onprem_public.id
  source_dest_check = false
  security_groups   = [aws_security_group.onprem.id]
  description       = "Public interface for instance router a"
  tags = {
    Name = "onprem-router-eni-public-a"
  }
}

resource "aws_network_interface" "onprem_private_a" {
  subnet_id         = aws_subnet.onprem_a.id
  source_dest_check = false
  security_groups   = [aws_security_group.onprem.id]
  description       = "Private interface for instance router a"
  tags = {
    Name = "onprem-router-eni-private-a"
  }
}

resource "aws_network_interface" "onprem_public_b" {
  subnet_id         = aws_subnet.onprem_public.id
  source_dest_check = false
  security_groups   = [aws_security_group.onprem.id]
  description       = "Public interface for instance router b"
  tags = {
    Name = "onprem-router-eni-public-b"
  }
}

resource "aws_network_interface" "onprem_private_b" {
  subnet_id         = aws_subnet.onprem_b.id
  source_dest_check = false
  security_groups   = [aws_security_group.onprem.id]
  description       = "Private interface for instance router b"
  tags = {
    Name = "onprem-router-eni-private-b"
  }
}

resource "aws_eip" "onprem_public_a" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.onprem]
}

resource "aws_eip_association" "onprem_public_a" {
  network_interface_id = aws_network_interface.onprem_public_a.id
  allocation_id        = aws_eip.onprem_public_a.id
}

resource "aws_eip" "onprem_public_b" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.onprem]
}

resource "aws_eip_association" "onprem_public_b" {
  network_interface_id = aws_network_interface.onprem_public_b.id
  allocation_id        = aws_eip.onprem_public_b.id
}

resource "aws_security_group" "onprem" {
  name        = "onprem_sg"
  description = "Allow all inbound from cloud networks and all outbound traffic"
  vpc_id      = aws_vpc.onprem.id

  tags = {
    Name = "onprem_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "onprem_outbound" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "onprem_inbound_cloud" {
  security_group_id = aws_security_group.onprem.id

  cidr_ipv4   = var.cloud_vpc_cidr
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "onprem_self" {
  security_group_id = aws_security_group.onprem.id

  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.onprem.id
}


resource "aws_instance" "onprem-router-a" {
  ami                  = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type        = "t3.small"
  iam_instance_profile = aws_iam_instance_profile.profile.name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.onprem_public_a.id
  }
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.onprem_private_a.id
  }
  user_data = file("${path.module}/user_data/user_data.tftpl")
  tags = {
    Name = "onprem-router-a"
  }
  depends_on = [aws_eip_association.onprem_public_a]
}

resource "aws_instance" "onprem-router-b" {
  ami                  = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type        = "t3.small"
  iam_instance_profile = aws_iam_instance_profile.profile.name
  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.onprem_public_b.id
  }
  network_interface {
    device_index         = 1
    network_interface_id = aws_network_interface.onprem_private_b.id
  }
  user_data = file("${path.module}/user_data/user_data.tftpl")
  tags = {
    Name = "onprem-router-b"
  }
  depends_on = [aws_eip_association.onprem_public_b]
}

resource "aws_instance" "onprem-instance-a" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  subnet_id              = aws_subnet.onprem_a.id
  vpc_security_group_ids = [aws_security_group.onprem.id]
  tags = {
    Name = "onprem-instance-a"
  }
}

resource "aws_instance" "onprem-instance-b" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  subnet_id              = aws_subnet.onprem_b.id
  vpc_security_group_ids = [aws_security_group.onprem.id]
  tags = {
    Name = "onprem-instance-b"
  }
}