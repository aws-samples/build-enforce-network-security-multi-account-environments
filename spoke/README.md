<!-- BEGIN_TF_DOCS -->
## Spoke AWS Account

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_aws.awsireland"></a> [aws.awsireland](#provider\_aws.awsireland) | >= 5.0.0 |
| <a name="provider_aws.awsnvirginia"></a> [aws.awsnvirginia](#provider\_aws.awsnvirginia) | >= 5.0.0 |
| <a name="provider_aws.awsohio"></a> [aws.awsohio](#provider\_aws.awsohio) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ireland_compute"></a> [ireland\_compute](#module\_ireland\_compute) | ./modules/compute | n/a |
| <a name="module_ireland_retrieve_parameters"></a> [ireland\_retrieve\_parameters](#module\_ireland\_retrieve\_parameters) | ../modules/retrieve_parameters | n/a |
| <a name="module_ireland_share_parameters"></a> [ireland\_share\_parameters](#module\_ireland\_share\_parameters) | ../modules/share_parameter | n/a |
| <a name="module_ireland_vpcs"></a> [ireland\_vpcs](#module\_ireland\_vpcs) | aws-ia/vpc/aws | 4.4.2 |
| <a name="module_nvirginia_compute"></a> [nvirginia\_compute](#module\_nvirginia\_compute) | ./modules/compute | n/a |
| <a name="module_nvirginia_retrieve_parameters"></a> [nvirginia\_retrieve\_parameters](#module\_nvirginia\_retrieve\_parameters) | ../modules/retrieve_parameters | n/a |
| <a name="module_nvirginia_share_parameters"></a> [nvirginia\_share\_parameters](#module\_nvirginia\_share\_parameters) | ../modules/share_parameter | n/a |
| <a name="module_nvirginia_vpcs"></a> [nvirginia\_vpcs](#module\_nvirginia\_vpcs) | aws-ia/vpc/aws | 4.4.2 |
| <a name="module_ohio_compute"></a> [ohio\_compute](#module\_ohio\_compute) | ./modules/compute | n/a |
| <a name="module_ohio_retrieve_parameters"></a> [ohio\_retrieve\_parameters](#module\_ohio\_retrieve\_parameters) | ../modules/retrieve_parameters | n/a |
| <a name="module_ohio_share_parameters"></a> [ohio\_share\_parameters](#module\_ohio\_share\_parameters) | ../modules/share_parameter | n/a |
| <a name="module_ohio_vpcs"></a> [ohio\_vpcs](#module\_ohio\_vpcs) | aws-ia/vpc/aws | 4.4.2 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_managed_prefix_list.ireland_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |
| [aws_ec2_managed_prefix_list.nvirginia_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |
| [aws_ec2_managed_prefix_list.ohio_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list) | resource |
| [aws_ec2_managed_prefix_list_entry.ireland_prefix_list_entry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list_entry) | resource |
| [aws_ec2_managed_prefix_list_entry.nvirginia_prefix_list_entry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list_entry) | resource |
| [aws_ec2_managed_prefix_list_entry.ohio_prefix_list_entry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_managed_prefix_list_entry) | resource |
| [aws_ram_principal_association.ireland_pl_principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_principal_association.nvirginia_pl_principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_principal_association.ohio_pl_principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.ireland_pl_resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.nvirginia_pl_resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_association.ohio_pl_resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.ireland_pl_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share.nvirginia_pl_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_ram_resource_share.ohio_pl_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.ireland_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.nvirginia_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [aws_vpc.ohio_vpcs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_networking_account_id"></a> [networking\_account\_id](#input\_networking\_account\_id) | Networking AWS Account ID. | `string` | n/a | yes |
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | AWS Regions to create the environment. | `map(string)` | <pre>{<br>  "ireland": "eu-west-1",<br>  "nvirginia": "us-east-1",<br>  "ohio": "us-east-2"<br>}</pre> | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project Identifier, used as identifer when creating resources. | `string` | `"nis342"` | no |
| <a name="input_vpcs"></a> [vpcs](#input\_vpcs) | Information about the VPCs to create. | `any` | <pre>{<br>  "ireland": {<br>    "vpc1": {<br>      "instance_type": "t2.micro",<br>      "number_azs": 2<br>    },<br>    "vpc2": {<br>      "instance_type": "t2.micro",<br>      "number_azs": 2<br>    }<br>  },<br>  "nvirginia": {<br>    "vpc1": {<br>      "instance_type": "t2.micro",<br>      "number_azs": 2<br>    },<br>    "vpc2": {<br>      "instance_type": "t2.micro",<br>      "number_azs": 2<br>    }<br>  },<br>  "ohio": {<br>    "vpc1": {<br>      "instance_type": "t2.micro",<br>      "number_azs": 2<br>    },<br>    "vpc2": {<br>      "instance_type": "t2.micro",<br>      "number_azs": 2<br>    }<br>  }<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->