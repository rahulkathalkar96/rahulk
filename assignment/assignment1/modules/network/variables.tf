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

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks."
  type        = bool
  default     = false
}

variable "private_subnets0" {
  description = "A list of secondary private subnets inside the VPC"
  type        = list(string)
}

variable "private_subnets1" {
  description = "A list of secondary private subnets inside the VPC"
  type        = list(string)
}
