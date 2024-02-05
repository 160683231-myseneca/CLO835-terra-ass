terraform {
  backend "s3" {
    bucket = "bucket-sanah"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}
