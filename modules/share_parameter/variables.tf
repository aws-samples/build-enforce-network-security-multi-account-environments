# ---------- network/modules/share_parameter/variables.tf ----------

variable "ram_share_name" {
  description = "RAM Share Name."
  type        = string
}

variable "parameters" {
  description = "List of parameters to share."
  type        = map(string)
}