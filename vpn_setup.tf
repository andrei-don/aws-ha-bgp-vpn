resource "aws_customer_gateway" "router_a" {
  bgp_asn    = var.onprem_bgp_asn
  ip_address = aws_eip.onprem_public_a.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "customer-gateway-onprem-router-a"
  }
}

resource "aws_customer_gateway" "router_b" {
  bgp_asn    = var.onprem_bgp_asn
  ip_address = aws_eip.onprem_public_b.public_ip
  type       = "ipsec.1"

  tags = {
    Name = "customer-gateway-onprem-router-b"
  }
}

resource "aws_vpn_connection" "router_a" {
  customer_gateway_id = aws_customer_gateway.router_a.id
  transit_gateway_id  = aws_ec2_transit_gateway.this.id
  type                = aws_customer_gateway.router_a.type
  enable_acceleration = true
}

resource "aws_vpn_connection" "router_b" {
  customer_gateway_id = aws_customer_gateway.router_b.id
  transit_gateway_id  = aws_ec2_transit_gateway.this.id
  type                = aws_customer_gateway.router_b.type
  enable_acceleration = true
}