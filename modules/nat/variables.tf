variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "nat_sg_id" {
  description = "NAT security group ID"
  type        = string
}

variable "ssm_profile_name" {
  description = "SSM instance profile name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
