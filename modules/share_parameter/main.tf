# ---------- network/modules/share_parameter/main.tf ----------

# Obtaining AWS Organization ID
data "aws_organizations_organization" "org" {}

# Resource Share
resource "aws_ram_resource_share" "resource_share" {
  name                      = var.ram_share_name
  allow_external_principals = false
}

resource "aws_ram_principal_association" "principal_association" {
  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.resource_share.arn
}

# Creation of the SSM Parameter Store Parameters
resource "aws_ssm_parameter" "parameter" {
  for_each = var.parameters

  name  = each.key
  tier  = "Advanced"
  type  = "String"
  value = each.value
}

# Sharing Parameters via RAM
resource "aws_ram_resource_association" "resource_association" {
  for_each = var.parameters

  resource_arn       = aws_ssm_parameter.parameter[each.key].arn
  resource_share_arn = aws_ram_resource_share.resource_share.arn
} 