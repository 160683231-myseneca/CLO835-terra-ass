module "web" {
  source        = "../modules/aws_webserver"
  prefix        = var.prefix
  instance_type = var.instance_type
  default_tags  = var.default_tags
}
