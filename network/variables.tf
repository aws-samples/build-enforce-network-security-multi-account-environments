# ---------- network/variables.tf ----------

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

variable "guarduty_finding_names" {
  type        = list(string)
  description = "List of GuardDuty Finding names to filter in EventBridge."
  default = [
    "UnauthorizedAccess:EC2/MaliciousIPCaller.Custom",
    "CryptoCurrency:EC2/BitcoinTool.B!DNS",
    "Execution:Runtime/SuspiciousTool"
  ]
}

# Spoke AWS Account ID
variable "spoke_account_id" {
  type        = string
  description = "Spoke AWS Account ID."
}


