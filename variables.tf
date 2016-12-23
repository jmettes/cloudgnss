data "aws_caller_identity" "current" { }

variable "aws_region" {
  description = "AWS region"
  default = "ap-southeast-2"
}

variable "aws_profile" {
  description = "AWS profile"
  default = "default"
}