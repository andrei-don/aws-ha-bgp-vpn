resource "aws_vpc" "cloud" {
  cidr_block           = var.cloud_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "cloud_vpc"
  }
}

resource "aws_subnet" "cloud_a" {
  vpc_id            = aws_vpc.cloud.id
  cidr_block        = var.cloud_subnet_cidr_a
  availability_zone = "${var.region}a"
  tags = {
    Name = "cloud_subnet_a"
  }
}

resource "aws_subnet" "cloud_b" {
  vpc_id            = aws_vpc.cloud.id
  cidr_block        = var.cloud_subnet_cidr_b
  availability_zone = "${var.region}b"
  tags = {
    Name = "cloud_subnet_b"
  }
}

resource "aws_route_table" "cloud" {
  vpc_id = aws_vpc.cloud.id

  tags = {
    Name = "cloud_rt"
  }
}

resource "aws_route_table_association" "cloud_a" {
  subnet_id      = aws_subnet.cloud_a.id
  route_table_id = aws_route_table.cloud.id
}

resource "aws_route_table_association" "cloud_b" {
  subnet_id      = aws_subnet.cloud_b.id
  route_table_id = aws_route_table.cloud.id
}

resource "aws_ec2_transit_gateway" "this" {
  description                     = "TGW for VPN setup"
  amazon_side_asn                 = 64512
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc" {
  subnet_ids         = [aws_subnet.cloud_a.id, aws_subnet.cloud_b.id]
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = aws_vpc.cloud.id
  tags = {
    Name = "cloud-vpc-attachment"
  }
}

resource "aws_route" "cloud_to_onprem" {
  route_table_id         = aws_route_table.cloud.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.this.id
}

resource "aws_vpc_endpoint" "cloud_ssm" {
  vpc_id              = aws_vpc.cloud.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = [aws_subnet.cloud_a.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.cloud.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloud_ec2messages" {
  vpc_id              = aws_vpc.cloud.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  subnet_ids          = [aws_subnet.cloud_a.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.cloud.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "cloud_ssmmessages" {
  vpc_id              = aws_vpc.cloud.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = [aws_subnet.cloud_a.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.cloud.id]
  private_dns_enabled = true
}



