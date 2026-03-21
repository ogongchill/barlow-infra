variable "aws_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "env" {
  type    = string
  default = "prod"
  validation {
    condition     = contains(["prod", "test", "common"], var.env)
    error_message = "env must be one of: prod, test, common"
  }
}
