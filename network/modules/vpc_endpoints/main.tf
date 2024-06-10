# ---------- network/modules/vpc_endpoints/main.tf ----------
data "aws_region" "region" {}

# VPC endpoints
resource "aws_vpc_endpoint" "endpoint" {
  for_each = { for i, endpoint in var.service_endpoints : endpoint => i }

  vpc_id              = var.vpc_information.vpc_attributes.id
  service_name        = "com.amazonaws.${data.aws_region.region.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values({ for k, v in var.vpc_information.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "endpoints" })
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = false
}

# Security Group
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc_endpoint-security-group-${data.aws_region.region.name}"
  description = "VPC endpoint Security Group"
  vpc_id      = var.vpc_information.vpc_attributes.id
}

resource "aws_vpc_security_group_ingress_rule" "allowing_ingress_https" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allowing_egress_any" {
  security_group_id = aws_security_group.vpc_endpoint_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# Route 53 Profile
resource "awscc_route53profiles_profile" "r53_profile" {
  name = "${data.aws_region.region.name}-r53-profile"
}

# PHZs associated to R53 profile
resource "awscc_route53profiles_profile_resource_association" "r53_profile_resource_association" {
  for_each = { for i, endpoint in var.service_endpoints : endpoint => i }

  name         = "${each.key}-phz"
  profile_id   = awscc_route53profiles_profile.r53_profile.id
  resource_arn = aws_route53_zone.private_hosted_zone[each.key].arn
}

# Private Hosted Zones
resource "aws_route53_zone" "private_hosted_zone" {
  for_each = { for i, endpoint in var.service_endpoints : endpoint => i }

  name = "${each.key}.${data.aws_region.region.name}.amazonaws.com"

  vpc {
    vpc_id = var.vpc_information.vpc_attributes.id
  }
}

# DNS Records (CNAME)
resource "aws_route53_record" "endpoint_record" {
  for_each = { for i, endpoint in var.service_endpoints : endpoint => i }

  zone_id = aws_route53_zone.private_hosted_zone[each.key].id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.endpoint[each.key].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.endpoint[each.key].dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "s3_endpoint_record" {
  for_each = {
    for i, endpoint in var.service_endpoints : endpoint => i
    if endpoint == "s3"
  }

  zone_id = aws_route53_zone.private_hosted_zone[each.key].id
  name    = "*"
  type    = "A"

  alias {
    name                   = aws_vpc_endpoint.endpoint[each.key].dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.endpoint[each.key].dns_entry[0].hosted_zone_id
    evaluate_target_health = true
  }
} 