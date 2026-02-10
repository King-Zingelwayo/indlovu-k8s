output "nat_instance_id" {
  description = "NAT instance ID"
  value       = aws_instance.nat.id
}

output "nat_primary_network_interface_id" {
  description = "NAT primary network interface ID"
  value       = aws_instance.nat.primary_network_interface_id
}
