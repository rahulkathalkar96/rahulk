variable "env" {
  description = "Environment prefix for all resources."
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets0" {
  description = "A list of secondary private subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets1" {
  description = "A list of secondary private subnets inside the VPC"
  type        = list(string)
}
