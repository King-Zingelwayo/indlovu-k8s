variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID"
  type        = string
}

variable "k8s_sg_id" {
  description = "Kubernetes security group ID"
  type        = string
}

variable "ssm_profile_name" {
  description = "SSM instance profile name"
  type        = string
}

variable "master_instance_type" {
  description = "Master instance type"
  type        = string
}

variable "worker_instance_type" {
  description = "Worker instance type"
  type        = string
}

variable "worker_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "worker_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "worker_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "pod_network_cidr" {
  description = "Pod network CIDR"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "master_as_worker" {
  description = "Allow master to run workloads"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
