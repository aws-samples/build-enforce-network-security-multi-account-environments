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
    "Execution:Runtime/MaliciousFileExecuted",
    "UnauthorizedAccess:EC2/SSHBruteForce",
    "Execution:Runtime/SuspiciousCommand",
    "Recon:EC2/PortProbeUnprotectedPort",
    "Trojan:EC2/DNSDataExfiltration",
    "Backdoor:EC2/C&CActivity.B!DNS",
    "Execution:EC2/MaliciousFile"
  ]
}

# Spoke AWS Account ID
variable "spoke_account_id" {
  type        = string
  description = "Spoke AWS Account ID."
}


