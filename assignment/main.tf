module "vpc" {
  source                          = "./assignment1/modules/network/vpc"
  env                             = var.env
  public_subnets                  = var.public_subnets
  private_subnets                 = var.private_subnets
  private_subnets0 = var.secondary_cidr_private_subnets0
  private_subnets1 = var.secondary_cidr_private_subnets1
}
