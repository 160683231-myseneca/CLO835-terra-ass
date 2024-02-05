variable "default_tags" {
  default = {
    Owner = "sanah",
    App   = "Web"
  }
  type        = map(any)
  description = "Default tags for all AWS resources"
}

variable "prefix" {
  default     = ""
  type        = string
  description = "Name prefix"
}

variable "vpc_cidr" {
  default     = ""
  type        = string
  description = "VPC CIDR"
}

variable "public_cidr_blocks" {
  default     = []
  type        = list(string)
  description = "Public Subnet CIDRs"
}