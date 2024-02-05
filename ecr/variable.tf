variable "prefix" {
  default     = "sanah"
  type        = string
  description = "Name prefix"
}

variable "default_tags" {
  default = {
    Owner = "sanah",
    App   = "Web"
  }
  type        = map(any)
  description = "Default tags for all AWS resources"
}