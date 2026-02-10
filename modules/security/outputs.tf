output "nat_sg_id" {
  description = "NAT security group ID"
  value       = aws_security_group.nat.id
}

output "k8s_sg_id" {
  description = "Kubernetes security group ID"
  value       = aws_security_group.k8s.id
}

output "ssm_profile_name" {
  description = "SSM instance profile name"
  value       = aws_iam_instance_profile.ssm_profile.name
}
