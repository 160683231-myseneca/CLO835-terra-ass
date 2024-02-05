terraform {
  backend "s3" {
    bucket = "bucket-sanah"
    key    = "webserver/terraform.tfstate"
    region = "us-east-1"
  }
}
