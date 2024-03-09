provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_s3_bucket" "my_bucket" {
  bucket = "bucket-sanah"
}

# locals {
#   base_dir = "${path.module}/../../CLO835-manifest"

#   directories = [
#     "", 
#     "kubChart/",
#     "kubChart/templates/",
#     "kubChart/charts/",
#     "kubManifest/",
#   ]

#   all_files = toset(flatten([
#     for dir in local.directories : fileset("${local.base_dir}/${dir}", "*")
#   ]))
# }


# resource "aws_s3_object" "remote_object2" {
#   for_each = local.all_files

#   bucket = data.aws_s3_bucket.my_bucket.bucket
#   key    = substr(each.value, 6, length(each.value)) 
#   source = each.value
#   etag   = filemd5(each.value)
# }

data "terraform_remote_state" "remote_network_state" {
  backend = "s3"
  config = {
    bucket = data.aws_s3_bucket.my_bucket.bucket
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "ec2_instance" {
  count                       = length(data.terraform_remote_state.remote_network_state.outputs.public_subnet_ids)
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.rsa_key.key_name
  subnet_id                   = data.terraform_remote_state.remote_network_state.outputs.public_subnet_ids[count.index]
  security_groups             = [aws_security_group.security_group_ec2.id]
  iam_instance_profile        = "LabInstanceProfile"
  user_data = templatefile("/home/ec2-user/environment/CLO835-terra-ass/modules/aws_webserver/bashscript.sh.tpl",{})
  associate_public_ip_address = true
  root_block_device {
    encrypted = false
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = merge(var.default_tags, { "Name" = "${var.prefix}-EC2-Machine-${count.index}" })
}

resource "aws_key_pair" "rsa_key" {
  key_name   = "${var.prefix}key"
  public_key = file("~/.ssh/${var.prefix}key.pub")
}

resource "aws_security_group" "security_group_ec2" {
  name        = "${var.prefix}-security-group"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.remote_network_state.outputs.vpc_id
  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    ingress {
    description      = "HTTPS from everywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "HTTP on additional ports"
    from_port        = 30000
    to_port          = 31000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "HTTP on additional ports"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(var.default_tags, { "Name" = "${var.prefix}-SG" })
}
