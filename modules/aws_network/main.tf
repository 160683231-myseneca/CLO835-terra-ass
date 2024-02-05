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
  profile = "default"
  region  = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "custom_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-vpc"
    }
  )
}

resource "aws_subnet" "public_subnets" {
  count             = min(length(var.public_cidr_blocks), length(data.aws_availability_zones.available.names))
  vpc_id            = aws_vpc.custom_vpc.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index}",
      "IsPublic"  = true 
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = merge(var.default_tags, {
    "Name" = "${var.prefix}-igw"
  })
}

resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.custom_vpc.id
  tags = merge(var.default_tags, {
    "Name" = "${var.prefix}-public-route"
  })
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_routes.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public_cidr_blocks)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_routes.id
}
