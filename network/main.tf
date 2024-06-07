# ---------- network/main.tf ----------
data "aws_organizations_organization" "org" {}
data "aws_caller_identity" "current" {}

locals {
  parameters = ["prefix_list_id"]
}

data "archive_file" "cwan_automation_package" {
  type        = "zip"
  source_file = "./automation.py"
  output_path = "./modules/automation/automation.zip"
}

# ---------- AUTOMATION (GUARDUTY FINDINGS TO CLOUDWAN ATTACHMENT TAG CHANGE) ----------
# North Virginia
module "nvirginia_automation" {
  providers = { aws = aws.awsnvirginia }
  source    = "./modules/automation"

  source_code_hash        = data.archive_file.cwan_automation_package.output_base64sha256
  lambda_role_arn         = aws_iam_role.automation_lambda_role.arn
  core_network_id         = aws_networkmanager_core_network.core_network.id
  guardduty_finding_names = var.guarduty_finding_names
}

# Ireland
module "ireland_automation" {
  providers = { aws = aws.awsireland }
  source    = "./modules/automation"

  source_code_hash        = data.archive_file.cwan_automation_package.output_base64sha256
  lambda_role_arn         = aws_iam_role.automation_lambda_role.arn
  core_network_id         = aws_networkmanager_core_network.core_network.id
  guardduty_finding_names = var.guarduty_finding_names
}

# Ohio
module "ohio_automation" {
  providers = { aws = aws.awsohio }
  source    = "./modules/automation"

  source_code_hash        = data.archive_file.cwan_automation_package.output_base64sha256
  lambda_role_arn         = aws_iam_role.automation_lambda_role.arn
  core_network_id         = aws_networkmanager_core_network.core_network.id
  guardduty_finding_names = var.guarduty_finding_names
}

# IAM Role
resource "aws_iam_role" "automation_lambda_role" {
  provider = aws.awsnvirginia

  name = "automation-lambda-role"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.automation_lambda_assume_role_policy.json
}

resource "aws_iam_policy" "automation_lambda_policy" {
  name        = "automation-lambda-policy"
  description = "Automation - AWS Lambda policy"
  policy      = data.aws_iam_policy_document.automation_lambda_actions.json
}

resource "aws_iam_role_policy_attachment" "automation_lambda_policy_attachment" {
  role       = aws_iam_role.automation_lambda_role.name
  policy_arn = aws_iam_policy.automation_lambda_policy.arn
}

data "aws_iam_policy_document" "automation_lambda_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "automation_lambda_actions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:${data.aws_caller_identity.current.id}:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "networkmanager:DescribeGlobalNetworks",
      "networkmanager:ListCoreNetworks",
      "networkmanager:ListCoreNetworkPolicyVersions",
      "networkmanager:ListAttachments",
      "networkmanager:GetCoreNetworkPolicy",
      "networkmanager:GetNetworkResources",
      "networkmanager:GetResourcePolicy",
      "networkmanager:ListTagsForResource",
      "networkmanager:GetVpcAttachment",
      "networkmanager:AcceptAttachment",
      "networkmanager:PutResourcePolicy",
      "networkmanager:UpdateCoreNetwork",
      "networkmanager:UpdateVpcAttachment",
      "networkmanager:TagResource",
      "networkmanager:UntagResource",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
}

# ---------- AWS CLOUD WAN RESOURCES ----------
# Global Network
resource "aws_networkmanager_global_network" "global_network" {
  provider = aws.awsnvirginia

  description = "Global Network - ${var.identifier}"

  tags = {
    Name = "Global Network - ${var.identifier}"
  }
}

# Core Network
resource "aws_networkmanager_core_network" "core_network" {
  provider = aws.awsnvirginia

  description       = "Core Network - ${var.identifier}"
  global_network_id = aws_networkmanager_global_network.global_network.id

  create_base_policy  = true
  base_policy_regions = values({ for k, v in var.aws_regions : k => v })

  tags = {
    Name = "Core Network - ${var.identifier}"
  }
}

# Core Network Policy Attachment
resource "aws_networkmanager_core_network_policy_attachment" "core_network_policy_attachment" {
  provider = aws.awsnvirginia

  core_network_id = aws_networkmanager_core_network.core_network.id
  policy_document = jsonencode(jsondecode(data.aws_networkmanager_core_network_policy_document.core_network_policy.json))
}

# Resource Share
resource "aws_ram_resource_share" "cwan_resource_share" {
  provider = aws.awsnvirginia

  name                      = "AWS Cloud WAN - Core Network"
  allow_external_principals = false
}

resource "aws_ram_principal_association" "cwan_principal_association" {
  provider = aws.awsnvirginia

  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.cwan_resource_share.arn
}

resource "aws_ram_resource_association" "cwan_resource_association" {
  provider = aws.awsnvirginia

  resource_arn       = aws_networkmanager_core_network.core_network.arn
  resource_share_arn = aws_ram_resource_share.cwan_resource_share.arn
}

# ---------- AMAZON VPC IPAM ----------
module "ipam" {
  providers = { aws = aws.awsnvirginia }
  source    = "aws-ia/ipam/aws"
  version   = "2.0.0"

  top_cidr       = ["10.0.0.0/8"]
  address_family = "ipv4"
  create_ipam    = true
  top_name       = "Organization IPAM"

  pool_configurations = {
    nvirginia = {
      name           = "nvirginia"
      description    = "N. Virginia (us-east-1) Region"
      netmask_length = 10
      locale         = var.aws_regions.nvirginia

      sub_pools = {
        central = {
          name           = "nvirginia-central"
          netmask_length = 11
        }
        spoke = {
          name                 = "nvirginia-spoke"
          netmask_length       = 11
          ram_share_principals = [data.aws_organizations_organization.org.arn]
        }
      }
    }
    ohio = {
      name           = "ohio"
      description    = "Ohio (us-east-2) Region"
      netmask_length = 10
      locale         = var.aws_regions.ohio

      sub_pools = {
        central = {
          name           = "ohio-central"
          netmask_length = 11
        }
        spoke = {
          name                 = "ohio-spoke"
          netmask_length       = 11
          ram_share_principals = [data.aws_organizations_organization.org.arn]
        }
      }
    }
    ireland = {
      name           = "ireland"
      description    = "Ireland (us-east-1) Region"
      netmask_length = 10
      locale         = var.aws_regions.ireland

      sub_pools = {
        central = {
          name           = "ireland-central"
          netmask_length = 11
        }
        spoke = {
          name                 = "ireland-spoke"
          netmask_length       = 11
          ram_share_principals = [data.aws_organizations_organization.org.arn]
        }
      }
    }
  }
}

# ---------- NORTH VIRGINIA ----------
module "nvirginia_central" {
  source    = "aws-ia/cloudwan/aws"
  version   = "3.2.0"
  providers = { aws = aws.awsnvirginia }

  core_network_arn = aws_networkmanager_core_network.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    inspection = {
      type                    = "egress_with_inspection"
      vpc_ipv4_ipam_pool_id   = module.ipam.pools_level_2["nvirginia/central"].id
      vpc_ipv4_netmask_length = 24
      az_count                = 2

      subnets = {
        public    = { netmask = 28 }
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "inspectionnvirginia" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-nvirginia"
      description = "AWS Network Firewall - us-east-1"
      policy_arn  = module.nvirginia_firewall_policy.firewall_policy_arn
    }
  }
}

module "nvirginia_firewall_policy" {
  providers = { aws = aws.awsnvirginia }
  source    = "./modules/firewall_policy"

  identifier = var.identifier
}

module "nvirginia_share_parameter" {
  providers = { aws = aws.awsnvirginia }
  source    = "../modules/share_parameter"

  ram_share_name = "Networking Account - N. Virginia"
  parameters = {
    core_network = aws_networkmanager_core_network.core_network.arn
    ipam_pool_id = module.ipam.pools_level_2["nvirginia/spoke"].id
  }
}

module "nvirginia_retrieve_parameters" {
  providers = { aws = aws.awsnvirginia }
  source    = "../modules/retrieve_parameters"

  account_id = var.spoke_account_id
  parameters = local.parameters
}

# ---------- OHIO ----------
module "ohio_central" {
  source    = "aws-ia/cloudwan/aws"
  version   = "3.2.0"
  providers = { aws = aws.awsohio }

  core_network_arn = aws_networkmanager_core_network.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    inspection = {
      type                    = "egress_with_inspection"
      vpc_ipv4_ipam_pool_id   = module.ipam.pools_level_2["ohio/central"].id
      vpc_ipv4_netmask_length = 24
      az_count                = 2

      subnets = {
        public    = { netmask = 28 }
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "inspectionohio" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-ohio"
      description = "AWS Network Firewall - us-east-2"
      policy_arn  = module.ohio_firewall_policy.firewall_policy_arn
    }
  }
}

module "ohio_firewall_policy" {
  providers = { aws = aws.awsohio }
  source    = "./modules/firewall_policy"

  identifier = var.identifier
}

module "ohio_share_parameter" {
  providers = { aws = aws.awsohio }
  source    = "../modules/share_parameter"

  ram_share_name = "Networking Account - Ohio"
  parameters = {
    core_network = aws_networkmanager_core_network.core_network.arn
    ipam_pool_id = module.ipam.pools_level_2["ohio/spoke"].id
  }
}

module "ohio_retrieve_parameters" {
  providers = { aws = aws.awsohio }
  source    = "../modules/retrieve_parameters"

  account_id = var.spoke_account_id
  parameters = local.parameters
}

# ---------- IRELAND ----------
module "ireland_central" {
  source    = "aws-ia/cloudwan/aws"
  version   = "3.2.0"
  providers = { aws = aws.awsireland }

  core_network_arn = aws_networkmanager_core_network.core_network.arn

  ipv4_network_definition = "10.0.0.0/8"
  central_vpcs = {
    inspection = {
      type                    = "egress_with_inspection"
      vpc_ipv4_ipam_pool_id   = module.ipam.pools_level_2["ireland/central"].id
      vpc_ipv4_netmask_length = 24
      az_count                = 2

      subnets = {
        public    = { netmask = 28 }
        endpoints = { netmask = 28 }
        core_network = {
          netmask = 28

          tags = { domain = "inspectionireland" }
        }
      }
    }
  }

  aws_network_firewall = {
    inspection = {
      name        = "anfw-ireland"
      description = "AWS Network Firewall - eu-west-1"
      policy_arn  = module.ireland_firewall_policy.firewall_policy_arn
    }
  }
}

module "ireland_firewall_policy" {
  providers = { aws = aws.awsireland }
  source    = "./modules/firewall_policy"

  identifier = var.identifier
}

module "ireland_share_parameter" {
  providers = { aws = aws.awsireland }
  source    = "../modules/share_parameter"

  ram_share_name = "Networking Account - Ireland"
  parameters = {
    core_network = aws_networkmanager_core_network.core_network.arn
    ipam_pool_id = module.ipam.pools_level_2["ireland/spoke"].id
  }
}

module "ireland_retrieve_parameters" {
  providers = { aws = aws.awsireland }
  source    = "../modules/retrieve_parameters"

  account_id = var.spoke_account_id
  parameters = local.parameters
}