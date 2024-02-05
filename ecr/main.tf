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
  name            = "mysql_image"

  image_scanning_configuration {
    scan_on_push  = true
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
  name            = "app_image"

  image_scanning_configuration {
    scan_on_push  = true
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
  name            = "proxy_image"

  image_scanning_configuration {
    scan_on_push  = true
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

resource "aws_ecr_repository_policy" "mysql_image_policy" {
  repository  = aws_ecr_repository.mysql_image.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "ecr:GetDownloadUrlForLayer",
        Resource  = aws_ecr_repository.mysql_image.arn
      }
    ]
  })
}


resource "aws_ecr_repository_policy" "app_image_policy" {
  repository  = aws_ecr_repository.app_image.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "ecr:GetDownloadUrlForLayer",
        Resource  = aws_ecr_repository.app_image.arn
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "proxy_image_policy" {
  repository  = aws_ecr_repository.proxy_image.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicAccess",
        Effect    = "Allow",
        Principal = "*",
        Action    = "ecr:GetDownloadUrlForLayer",
        Resource  = aws_ecr_repository.proxy_image.arn
      }
    ]
  })
}