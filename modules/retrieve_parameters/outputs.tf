# ---------- network/modules/retreive_parameters/outputs.tf ----------

output "parameter" {
  description = "Parameter value."
  value       = { for k, v in data.aws_ssm_parameter.parameter : k => v.value }
}