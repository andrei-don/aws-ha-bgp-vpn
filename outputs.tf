output "public_ip_router_a" {
  description = "The public IP of onprem router A"
  value       = aws_eip.onprem_public_a.public_ip
}

output "public_ip_router_b" {
  description = "The public IP of onprem router B"
  value       = aws_eip.onprem_public_b.public_ip
}

output "private_ip_router_a" {
  description = "The private IP of onprem router A"
  value       = aws_network_interface.onprem_public_a.private_ip
}

output "private_ip_router_b" {
  description = "The private IP of onprem router B"
  value       = aws_network_interface.onprem_public_b.private_ip
}