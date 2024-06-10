# ---------- network/cloudwan_policy.tf ----------

# Data source: Region's Prefix Lists
data "aws_ec2_managed_prefix_list" "nvirginia_prefix_list" {
  provider = aws.awsnvirginia

  id = module.nvirginia_retrieve_parameters.parameter.prefix_list_id
}

data "aws_ec2_managed_prefix_list" "ohio_prefix_list" {
  provider = aws.awsohio

  id = module.ohio_retrieve_parameters.parameter.prefix_list_id
}

data "aws_ec2_managed_prefix_list" "ireland_prefix_list" {
  provider = aws.awsireland

  id = module.ireland_retrieve_parameters.parameter.prefix_list_id
}

locals {
  # We get the list of AWS Region codes from var.aws_regions
  region_codes = values({ for k, v in var.aws_regions : k => v })
  # We get the list of AWS Region names from var.aws_regions
  region_names = keys({ for k, v in var.aws_regions : k => v })
  # List of routing domains
  routing_domains = ["hub", "inspected", "onlyshared", "blocked", "shared"]

  # Information about the CIDR blocks and Inspection VPC attachments of each AWS Region
  region_information = {
    ireland = {
      cidr_blocks               = [for entry in data.aws_ec2_managed_prefix_list.ireland_prefix_list.entries : entry.cidr]
      inspection_vpc_attachment = module.ireland_central.central_vpcs.inspection.core_network_attachment.id
    }
    nvirginia = {
      cidr_blocks               = [for entry in data.aws_ec2_managed_prefix_list.nvirginia_prefix_list.entries : entry.cidr]
      inspection_vpc_attachment = module.nvirginia_central.central_vpcs.inspection.core_network_attachment.id
    }
    ohio = {
      cidr_blocks               = [for entry in data.aws_ec2_managed_prefix_list.ohio_prefix_list.entries : entry.cidr]
      inspection_vpc_attachment = module.ohio_central.central_vpcs.inspection.core_network_attachment.id
    }
  }

  # We create a list of maps with the following format:
  # - inspection --> inspection segment to create the static routes
  # - destination --> destination AWS Region, to add the destination CIDRs + Inspection VPC of that Region
  region_combination = flatten(
    [for region1 in local.region_names :
      [for region2 in local.region_names :
        {
          inspection  = region1
          destination = region2
        }
        if region1 != region2
      ]
    ]
  )
}

# AWS Cloud WAN Core Network Policy - Single Segment
data "aws_networkmanager_core_network_policy_document" "core_network_policy" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64520-65525"]

    dynamic "edge_locations" {
      for_each = local.region_codes
      iterator = region

      content {
        location = region.value
      }
    }
  }

  # We generate one segment per routing domain
  dynamic "segments" {
    for_each = local.routing_domains
    iterator = domain

    content {
      name                          = domain.value
      require_attachment_acceptance = false
      isolate_attachments           = domain.value == "hub" ? false : true
      deny_filter                   = [for r in local.region_names : "inspection${r}"]
    }
  }

  # We create 1 inspection segment per AWS Region
  dynamic "segments" {
    for_each = local.region_names
    iterator = region

    content {
      name                          = "inspection${region.value}"
      require_attachment_acceptance = false
      isolate_attachments           = true
    }
  }

  # HUB & INSPECTED SEGMENTS: default (0.0.0.0/0) to Inspection VPCs - egress traffic
  dynamic "segment_actions" {
    for_each = ["hub", "inspected"]
    iterator = domain

    content {
      action                  = "create-route"
      segment                 = domain.value
      destination_cidr_blocks = ["0.0.0.0/0"]
      destinations            = values({ for k, v in local.region_information : k => v.inspection_vpc_attachment })
    }
  }

  # HUB & INSPECTED SEGMENTS: we share the segment routes with the inspection segments
  dynamic "segment_actions" {
    for_each = ["hub", "inspected"]
    iterator = domain

    content {
      action     = "share"
      mode       = "attachment-route"
      segment    = domain.value
      share_with = [for r in local.region_names : "inspection${r}"]
    }
  }

  # SHARED SEGMENT: sharing with all segments except blocked
  dynamic "segment_actions" {
    for_each = ["hub", "inspected", "onlyshared"]
    iterator = domain

    content {
      action     = "share"
      mode       = "attachment-route"
      segment    = domain.value
      share_with = ["shared"]
    }
  }

  # Create of static routes - per AWS Region, we need to point those VPCs CIDRs to pass through the local Inspection VPC in the other inspection segments
  # For example, N. Virginia CIDRs to Inspection VPC in N.Virginia --> inspectionireland & inspectionsydney
  dynamic "segment_actions" {
    for_each = local.region_combination
    iterator = combination

    content {
      action                  = "create-route"
      segment                 = "inspection${combination.value.inspection}"
      destination_cidr_blocks = local.region_information[combination.value.destination].cidr_blocks
      destinations            = [local.region_information[combination.value.destination].inspection_vpc_attachment]
    }
  }

  # Attachment policies
  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type = "tag-exists"
      key  = "domain"
    }

    action {
      association_method = "tag"
      tag_value_of_key   = "domain"
    }
  }

  attachment_policies {
    rule_number     = 200
    condition_logic = "or"

    conditions {
      type     = "attachment-type"
      operator = "equals"
      value    = "vpc"
    }

    action {
      association_method = "constant"
      segment            = "hub"
    }
  }
}