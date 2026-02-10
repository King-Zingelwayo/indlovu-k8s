output "master_asg_name" {
  description = "Master ASG name"
  value       = module.compute.master_asg_name
}

output "worker_asg_name" {
  description = "Worker ASG name"
  value       = module.compute.worker_asg_name
}

output "ssm_connect_master" {
  description = "Command to connect to master via SSM"
  value       = "MASTER_ID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${module.compute.master_asg_name} --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text) && aws ssm start-session --target $MASTER_ID"
}

output "ssm_connect_worker" {
  description = "Command to connect to worker via SSM"
  value       = "WORKER_ID=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${module.compute.worker_asg_name} --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text) && aws ssm start-session --target $WORKER_ID"
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
    
    1. Get master instance ID:
       MASTER_ID=$(aws autoscaling describe-auto-scaling-groups \
         --auto-scaling-group-names ${module.compute.master_asg_name} \
         --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)
    
    2. Connect to master:
       aws ssm start-session --target $MASTER_ID
    
    3. Check cluster status:
       kubectl get nodes
       cat /home/ubuntu/join-command.sh
    
    4. Get worker instance ID and join cluster:
       WORKER_ID=$(aws autoscaling describe-auto-scaling-groups \
         --auto-scaling-group-names ${module.compute.worker_asg_name} \
         --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)
       
       aws ssm start-session --target $WORKER_ID
       sudo $(cat /home/ubuntu/join-command.sh)
    
    5. Verify cluster:
       kubectl get nodes
       kubectl get pods -A
  EOT
}
