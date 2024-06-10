# ---------- network/modules/vpc_endpoints/variables.tf ----------

variable "service_endpoints" {
  type        = list(string)
  description = "List of AWS services to create VPC endpoints."
}

variable "vpc_information" {
  type        = any
  description = "VPC information."
}