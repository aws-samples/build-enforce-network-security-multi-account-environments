# ---------- network/modules/retreive_parameters/variables.tf ----------

variable "parameters" {
  description = "List of parameters to retrieve."
  type        = list(string)
}

variable "account_id" {
  description = "AWS Account ID (that shared the parameters)."
  type        = string
}