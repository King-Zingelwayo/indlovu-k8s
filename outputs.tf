output "master_asg_name" {
  description = "Master ASG name"
  value       = module.compute.master_asg_name
}

output "worker_asg_name" {
  description = "Worker ASG name"
  value       = module.compute.worker_asg_name
}

output "ssm_connect_master" {
  description = "SSM command for master"
  value       = "aws ssm start-session --target <INSTANCE_ID>"
}

output "ssm_connect_worker" {
  description = "SSM command for worker"
  value       = "aws ssm start-session --target <INSTANCE_ID>"
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = var.cluster_name
}

output "kubernetes_version" {
  description = "Kubernetes version"
  value       = var.kubernetes_version
}

output "pod_network_cidr" {
  description = "Pod network CIDR"
  value       = var.pod_network_cidr
}

output "next_steps" {
  description = "Next steps after deployment"
  value       = <<-EOT
    
    ========================================
    Kubernetes Cluster Deployment Complete!
    ========================================
    
    Master ASG: ${module.compute.master_asg_name}
    Worker ASG: ${module.compute.worker_asg_name}
    
    Connect via SSM:
    1. Get instance IDs:
       aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${module.compute.master_asg_name}
    
    2. Connect to master:
       aws ssm start-session --target <MASTER_INSTANCE_ID>
    
    3. Check cluster:
       kubectl get nodes
       cat /home/ubuntu/join-command.sh
    
    4. Connect to worker and join cluster
    
    See QUICKSTART.md for detailed instructions.
  EOT
}
