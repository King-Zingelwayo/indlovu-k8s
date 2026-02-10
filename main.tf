module "vpc" {
  source       = "./modules/vpc"
  cluster_name = var.cluster_name
  vpc_cidr     = var.vpc_cidr
  tags         = local.common_tags
}

module "security" {
  source       = "./modules/security"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  tags         = local.common_tags
}

module "nat" {
  source           = "./modules/nat"
  cluster_name     = var.cluster_name
  public_subnet_id = module.vpc.public_subnet_id
  nat_sg_id        = module.security.nat_sg_id
  ssm_profile_name = module.security.ssm_profile_name
  tags             = local.common_tags
}

resource "aws_route" "private_nat" {
  route_table_id         = module.vpc.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = module.nat.nat_primary_network_interface_id
}

# module "compute" {
#   source               = "./modules/compute"
#   cluster_name         = var.cluster_name
#   private_subnet_id    = module.vpc.private_subnet_id
#   k8s_sg_id            = module.security.k8s_sg_id
#   ssm_profile_name     = module.security.ssm_profile_name
#   master_instance_type = var.master_instance_type
#   worker_instance_type = var.worker_instance_type
#   worker_count         = var.worker_count
#   worker_min_size      = var.worker_min_size
#   worker_max_size      = var.worker_max_size
#   pod_network_cidr     = var.pod_network_cidr
#   kubernetes_version   = var.kubernetes_version
#   master_as_worker     = var.master_as_worker
#   tags                 = local.common_tags

#   depends_on = [module.nat]
# }
