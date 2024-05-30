# ---------- network/modules/retreive_parameters/main.tf ----------

locals {
  parameters = { for p in var.parameters : p => var.account_id }
}

# Obtain AWS Region
data "aws_region" "current" {}

# Retrieving parameters
data "aws_ssm_parameter" "parameter" {
  for_each = local.parameters

  name = "arn:aws:ssm:${data.aws_region.current.name}:${each.value}:parameter/${each.key}"
}