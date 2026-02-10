variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
