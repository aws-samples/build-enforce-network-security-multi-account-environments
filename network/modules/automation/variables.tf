# ---------- network/modules/automation/variables.tf ----------

variable "source_code_hash" {
  type        = any
  description = "AWS Lambda Function's source code hash."
}

variable "lambda_role_arn" {
  type        = string
  description = "AWS Lambda Function's role ARN."
}

variable "core_network_id" {
  type        = string
  description = "Core Network ID."
}
