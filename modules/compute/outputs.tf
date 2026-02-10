output "master_asg_name" {
  description = "Master ASG name"
  value       = aws_autoscaling_group.master.name
}

output "worker_asg_name" {
  description = "Worker ASG name"
  value       = aws_autoscaling_group.worker.name
}
