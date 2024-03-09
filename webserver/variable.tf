variable "instance_type" {
  default     = "c1.medium"
  description = "Type of instance"
  type        = string
}

variable "default_tags" {
  default = {
    Owner = "sanah",
    App   = "Web"
  }
  type        = map(any)
  description = "Default tags for all AWS resources"
}

variable "prefix" {
  default     = "sanah"
  type        = string
  description = "Name prefix"
}
