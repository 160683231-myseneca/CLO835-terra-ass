module "nw" {
  source             = "../modules/aws_network"
  vpc_cidr           = var.vpc_cidr
  public_cidr_blocks = var.public_cidr_blocks
  prefix             = var.prefix
  default_tags       = var.default_tags
}
