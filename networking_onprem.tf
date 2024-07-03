resource "aws_vpc" "onprem" {
  cidr_block           = var.onprem_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "onprem_vpc"
  }
}

resource "aws_internet_gateway" "onprem" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem-igw"
  }
}


resource "aws_subnet" "onprem_public" {
  vpc_id                  = aws_vpc.onprem.id
  cidr_block              = var.onprem_subnet_public_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "onprem_public_subnet"
  }
}

resource "aws_subnet" "onprem_a" {
  vpc_id            = aws_vpc.onprem.id
  cidr_block        = var.onprem_subnet_cidr_a
  availability_zone = "${var.region}a"
  tags = {
    Name = "onprem_private_a"
  }
}

resource "aws_subnet" "onprem_b" {
  vpc_id            = aws_vpc.onprem.id
  cidr_block        = var.onprem_subnet_cidr_b
  availability_zone = "${var.region}a"
  tags = {
    Name = "onprem_private_b"
  }
}

resource "aws_route_table" "onprem_priv_a" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem_private_rt_a"
  }
}

resource "aws_route_table" "onprem_priv_b" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem_private_rt_b"
  }
}


resource "aws_route_table" "onprem_public" {
  vpc_id = aws_vpc.onprem.id

  tags = {
    Name = "onprem_public_rt"
  }
}

#This route is needed for the ec2-based onprem routers to reach the internet
resource "aws_route" "onprem_to_internet" {
  route_table_id         = aws_route_table.onprem_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.onprem.id
}

#the routes below are needed by the onprem servers to reach the cloud instances via the ec2-based routers
resource "aws_route" "onprem_to_cloud_a" {
  route_table_id         = aws_route_table.onprem_priv_a.id
  destination_cidr_block = var.cloud_vpc_cidr
  gateway_id             = aws_internet_gateway.onprem.id
}

resource "aws_route" "onprem_to_cloud_b" {
  route_table_id         = aws_route_table.onprem_priv_b.id
  destination_cidr_block = var.cloud_vpc_cidr
  gateway_id             = aws_internet_gateway.onprem.id
}

resource "aws_route_table_association" "onprem_a" {
  subnet_id      = aws_subnet.onprem_a.id
  route_table_id = aws_route_table.onprem_priv_a.id
}

resource "aws_route_table_association" "onprem_b" {
  subnet_id      = aws_subnet.onprem_b.id
  route_table_id = aws_route_table.onprem_priv_b.id
}

resource "aws_route_table_association" "onprem_public" {
  subnet_id      = aws_subnet.onprem_public.id
  route_table_id = aws_route_table.onprem_public.id
}


resource "aws_vpc_endpoint" "onprem_ssm" {
  vpc_id              = aws_vpc.onprem.id
  service_name        = "com.amazonaws.${var.region}.ssm"
  subnet_ids          = [aws_subnet.onprem_public.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.onprem.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onprem_ec2messages" {
  vpc_id              = aws_vpc.onprem.id
  service_name        = "com.amazonaws.${var.region}.ec2messages"
  subnet_ids          = [aws_subnet.onprem_public.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.onprem.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onprem_ssmmessages" {
  vpc_id              = aws_vpc.onprem.id
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  subnet_ids          = [aws_subnet.onprem_public.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.onprem.id]
  private_dns_enabled = true
}

