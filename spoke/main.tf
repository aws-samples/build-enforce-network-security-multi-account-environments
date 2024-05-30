# ---------- spoke/main.tf ----------
data "aws_organizations_organization" "org" {}
data "aws_region" "region" {}
data "aws_caller_identity" "current" {}

locals {
  parameters = ["core_network", "ipam_pool_id"]
}

# ---------- N. VIRGINIA ----------
module "nvirginia_vpcs" {
  providers = { aws = aws.awsnvirginia }
  source    = "aws-ia/vpc/aws"
  version   = "4.4.2"
  for_each  = var.vpcs.nvirginia

  name                    = each.key
  vpc_ipv4_ipam_pool_id   = module.nvirginia_retrieve_parameters.parameter.ipam_pool_id
  vpc_ipv4_netmask_length = 24
  az_count                = 2

  core_network = {
    id  = split("/", module.nvirginia_retrieve_parameters.parameter.core_network)[1]
    arn = module.nvirginia_retrieve_parameters.parameter.core_network
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload     = { netmask = 28 }
    endpoints    = { netmask = 28 }
    core_network = { netmask = 28 }
  }
}

# Retrieve Parameters: Core Network ARN & IPAM Pool ID
module "nvirginia_retrieve_parameters" {
  providers = { aws = aws.awsnvirginia }
  source    = "../modules/retrieve_parameters"

  account_id = var.networking_account_id
  parameters = local.parameters
}

# Compute: EC2 Instances & EC2 Instance Connect endpoint
module "nvirginia_compute" {
  providers = { aws = aws.awsnvirginia }
  source    = "./modules/compute"
  for_each  = module.nvirginia_vpcs

  identifier      = var.identifier
  vpc_name        = each.key
  vpc             = each.value
  vpc_information = var.vpcs.nvirginia[each.key]
}

# Managed Prefix List
resource "aws_ec2_managed_prefix_list" "nvirginia_prefix_list" {
  provider = aws.awsnvirginia

  name           = "nvirginia-vpcs"
  address_family = "IPv4"
  max_entries    = length(var.vpcs.nvirginia)
}

data "aws_vpc" "nvirginia_vpcs" {
  provider = aws.awsnvirginia
  for_each = module.nvirginia_vpcs

  id = each.value.vpc_attributes.id
}

resource "aws_ec2_managed_prefix_list_entry" "nvirginia_prefix_list_entry" {
  provider = aws.awsnvirginia
  for_each = data.aws_vpc.nvirginia_vpcs

  cidr           = each.value.cidr_block_associations[0].cidr_block
  description    = "${each.key}-nvirginia"
  prefix_list_id = aws_ec2_managed_prefix_list.nvirginia_prefix_list.id
}

# Resource Share: Prefix List
resource "aws_ram_resource_share" "nvirginia_pl_resource_share" {
  provider = aws.awsnvirginia

  name                      = "VPCs Prefix List - N. Virginia"
  allow_external_principals = false
}

resource "aws_ram_principal_association" "nvirginia_pl_principal_association" {
  provider = aws.awsnvirginia

  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.nvirginia_pl_resource_share.arn
}

resource "aws_ram_resource_association" "nvirginia_pl_resource_association" {
  provider = aws.awsnvirginia

  resource_arn       = aws_ec2_managed_prefix_list.nvirginia_prefix_list.arn
  resource_share_arn = aws_ram_resource_share.nvirginia_pl_resource_share.arn
}

# Share Parameters: Prefix List ID
module "nvirginia_share_parameters" {
  providers = { aws = aws.awsnvirginia }
  source    = "../modules/share_parameter"

  ram_share_name = "Prefix List - N. Virginia"
  parameters = {
    prefix_list_id = aws_ec2_managed_prefix_list.nvirginia_prefix_list.id
  }
}

# ---------- OHIO ----------
module "ohio_vpcs" {
  providers = { aws = aws.awsohio }
  source    = "aws-ia/vpc/aws"
  version   = "4.4.2"
  for_each  = var.vpcs.ohio

  name                    = each.key
  vpc_ipv4_ipam_pool_id   = module.ohio_retrieve_parameters.parameter.ipam_pool_id
  vpc_ipv4_netmask_length = 24
  az_count                = 2

  core_network = {
    id  = split("/", module.ohio_retrieve_parameters.parameter.core_network)[1]
    arn = module.ohio_retrieve_parameters.parameter.core_network
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload     = { netmask = 28 }
    endpoints    = { netmask = 28 }
    core_network = { netmask = 28 }
  }
}

# Retrieve Parameters: Core Network ARN & IPAM Pool ID
module "ohio_retrieve_parameters" {
  providers = { aws = aws.awsohio }
  source    = "../modules/retrieve_parameters"

  account_id = var.networking_account_id
  parameters = local.parameters
}

# Compute: EC2 Instances & EC2 Instance Connect endpoint
module "ohio_compute" {
  providers = { aws = aws.awsohio }
  source    = "./modules/compute"
  for_each  = module.ohio_vpcs

  identifier      = var.identifier
  vpc_name        = each.key
  vpc             = each.value
  vpc_information = var.vpcs.ohio[each.key]
}

# Managed Prefix List
resource "aws_ec2_managed_prefix_list" "ohio_prefix_list" {
  provider = aws.awsohio

  name           = "ohio-vpcs"
  address_family = "IPv4"
  max_entries    = length(var.vpcs.ohio)
}

data "aws_vpc" "ohio_vpcs" {
  provider = aws.awsohio
  for_each = module.ohio_vpcs

  id = each.value.vpc_attributes.id
}

resource "aws_ec2_managed_prefix_list_entry" "ohio_prefix_list_entry" {
  provider = aws.awsohio
  for_each = data.aws_vpc.ohio_vpcs

  cidr           = each.value.cidr_block_associations[0].cidr_block
  description    = "${each.key}-ohio"
  prefix_list_id = aws_ec2_managed_prefix_list.ohio_prefix_list.id
}

# Resource Share: Prefix List
resource "aws_ram_resource_share" "ohio_pl_resource_share" {
  provider = aws.awsohio

  name                      = "VPCs Prefix List - Ohio"
  allow_external_principals = false
}

resource "aws_ram_principal_association" "ohio_pl_principal_association" {
  provider = aws.awsohio

  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.ohio_pl_resource_share.arn
}

resource "aws_ram_resource_association" "ohio_pl_resource_association" {
  provider = aws.awsohio

  resource_arn       = aws_ec2_managed_prefix_list.ohio_prefix_list.arn
  resource_share_arn = aws_ram_resource_share.ohio_pl_resource_share.arn
}

# Share Parameters: Prefix List ID
module "ohio_share_parameters" {
  providers = { aws = aws.awsohio }
  source    = "../modules/share_parameter"

  ram_share_name = "Prefix List - Ohio"
  parameters = {
    prefix_list_id = aws_ec2_managed_prefix_list.ohio_prefix_list.id
  }
}

# ---------- IRELAND ----------
module "ireland_vpcs" {
  providers = { aws = aws.awsireland }
  source    = "aws-ia/vpc/aws"
  version   = "4.4.2"
  for_each  = var.vpcs.ireland

  name                    = each.key
  vpc_ipv4_ipam_pool_id   = module.ireland_retrieve_parameters.parameter.ipam_pool_id
  vpc_ipv4_netmask_length = 24
  az_count                = 2

  core_network = {
    id  = split("/", module.ireland_retrieve_parameters.parameter.core_network)[1]
    arn = module.ireland_retrieve_parameters.parameter.core_network
  }
  core_network_routes = {
    workload = "0.0.0.0/0"
  }

  subnets = {
    workload     = { netmask = 28 }
    endpoints    = { netmask = 28 }
    core_network = { netmask = 28 }
  }
}

# Retrieve Parameters: Core Network ARN & IPAM Pool ID
module "ireland_retrieve_parameters" {
  providers = { aws = aws.awsireland }
  source    = "../modules/retrieve_parameters"

  account_id = var.networking_account_id
  parameters = local.parameters
}

# Compute: EC2 Instances & EC2 Instance Connect endpoint
module "ireland_compute" {
  providers = { aws = aws.awsireland }
  source    = "./modules/compute"
  for_each  = module.ireland_vpcs

  identifier      = var.identifier
  vpc_name        = each.key
  vpc             = each.value
  vpc_information = var.vpcs.ireland[each.key]
}

# Managed Prefix List
resource "aws_ec2_managed_prefix_list" "ireland_prefix_list" {
  provider = aws.awsireland

  name           = "ireland-vpcs"
  address_family = "IPv4"
  max_entries    = length(var.vpcs.ireland)
}

data "aws_vpc" "ireland_vpcs" {
  provider = aws.awsireland
  for_each = module.ireland_vpcs

  id = each.value.vpc_attributes.id
}

resource "aws_ec2_managed_prefix_list_entry" "ireland_prefix_list_entry" {
  provider = aws.awsireland
  for_each = data.aws_vpc.ireland_vpcs

  cidr           = each.value.cidr_block_associations[0].cidr_block
  description    = "${each.key}-ireland"
  prefix_list_id = aws_ec2_managed_prefix_list.ireland_prefix_list.id
}

# Resource Share: Prefix List
resource "aws_ram_resource_share" "ireland_pl_resource_share" {
  provider = aws.awsireland

  name                      = "VPCs Prefix List - Ireland"
  allow_external_principals = false
}

resource "aws_ram_principal_association" "ireland_pl_principal_association" {
  provider = aws.awsireland

  principal          = data.aws_organizations_organization.org.arn
  resource_share_arn = aws_ram_resource_share.ireland_pl_resource_share.arn
}

resource "aws_ram_resource_association" "ireland_pl_resource_association" {
  provider = aws.awsireland

  resource_arn       = aws_ec2_managed_prefix_list.ireland_prefix_list.arn
  resource_share_arn = aws_ram_resource_share.ireland_pl_resource_share.arn
}

# Share Parameters: Prefix List ID
module "ireland_share_parameters" {
  providers = { aws = aws.awsireland }
  source    = "../modules/share_parameter"

  ram_share_name = "Prefix List - Ireland"
  parameters = {
    prefix_list_id = aws_ec2_managed_prefix_list.ireland_prefix_list.id
  }
}