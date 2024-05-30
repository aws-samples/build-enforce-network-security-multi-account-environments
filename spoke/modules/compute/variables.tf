# --- spoke/modules/compute/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC where the EC2 instance(s) are created."
}

variable "vpc" {
  type        = any
  description = "VPC resources."
}

variable "vpc_information" {
  type        = any
  description = "VPC information (defined in root variables.tf file)."
}