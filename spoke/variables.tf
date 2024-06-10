# ---------- spoke/variables.tf ----------

# Project Identifier
variable "identifier" {
  type        = string
  description = "Project Identifier, used as identifer when creating resources."
  default     = "nis342"
}

# AWS Regions
variable "aws_regions" {
  type        = map(string)
  description = "AWS Regions to create the environment."
  default = {
    ireland   = "eu-west-1"
    nvirginia = "us-east-1"
    ohio      = "us-east-2"
  }
}

# Networking AWS Account ID
variable "networking_account_id" {
  type        = string
  description = "Networking AWS Account ID."
}

# VPCs' definition
variable "vpcs" {
  type        = any
  description = "Information about the VPCs to create."

  default = {
    nvirginia = {
      vpc1 = {
        number_azs    = 2
        instance_type = "t2.micro"
      }
    }

    ohio = {
      vpc1 = {
        number_azs    = 2
        instance_type = "t2.micro"
      }
    }

    ireland = {
      vpc1 = {
        number_azs    = 2
        instance_type = "t2.micro"
      }
    }
  }
}