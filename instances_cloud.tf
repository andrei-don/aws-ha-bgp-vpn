resource "aws_security_group" "cloud" {
  name        = "cloud_sg"
  description = "Allow inbound ssh and onprem networks and all outbound traffic"
  vpc_id      = aws_vpc.cloud.id

  tags = {
    Name = "cloud_sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "cloud_outbound" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_ssh" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 22
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "cloud_inbound_onprem" {
  security_group_id = aws_security_group.cloud.id

  cidr_ipv4   = var.onprem_vpc_cidr
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "cloud_self" {
  security_group_id = aws_security_group.cloud.id

  ip_protocol                  = -1
  referenced_security_group_id = aws_security_group.cloud.id
}

resource "aws_instance" "cloud-instance-a" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  subnet_id              = aws_subnet.cloud_a.id
  vpc_security_group_ids = [aws_security_group.cloud.id]
  tags = {
    Name = "cloud-instance-a"
  }
}

resource "aws_instance" "cloud-instance-b" {
  ami                    = data.aws_ami.this.id
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.profile.name
  subnet_id              = aws_subnet.cloud_b.id
  vpc_security_group_ids = [aws_security_group.cloud.id]
  tags = {
    Name = "cloud-instance-b"
  }
}