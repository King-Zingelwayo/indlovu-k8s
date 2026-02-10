locals {
  common_tags = {
    Project     = var.cluster_name
    Environment = "development"
    ManagedBy   = "terraform"
  }
}
