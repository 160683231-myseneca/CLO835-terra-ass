terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">=0.14"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "mysql_image" {
  name = "mysql_image"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-MySql_Image"
    }
  )
}

resource "aws_ecr_repository" "app_image" {
  name = "app_image"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-App_Image"
    }
  )
}

resource "aws_ecr_repository" "proxy_image" {
  name = "proxy_image"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-Proxy_Image"
    }
  )
}