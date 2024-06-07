<!-- BEGIN_TF_DOCS -->
## Networking AWS Account

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_aws.awsireland"></a> [aws.awsireland](#provider\_aws.awsireland) | >= 5.0.0 |
| <a name="provider_aws.awsnvirginia"></a> [aws.awsnvirginia](#provider\_aws.awsnvirginia) | >= 5.0.0 |
| <a name="provider_aws.awsohio"></a> [aws.awsohio](#provider\_aws.awsohio) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ipam"></a> [ipam](#module\_ipam) | aws-ia/ipam/aws | 2.0.0 |
| <a name="module_ireland_automation"></a> [ireland\_automation](#module\_ireland\_automation) | ./modules/automation | n/a |
| <a name="module_ireland_central"></a> [ireland\_central](#module\_ireland\_central) | aws-ia/cloudwan/aws | 3.2.0 |
| <a name="module_ireland_firewall_policy"></a> [ireland\_firewall\_policy](#module\_ireland\_firewall\_policy) | ./modules/firewall_policy | n/a |
| <a name="module_ireland_retrieve_parameters"></a> [ireland\_retrieve\_parameters](#module\_ireland\_retrieve\_parameters) | ../modules/retrieve_parameters | n/a |
| <a name="module_ireland_share_parameter"></a> [ireland\_share\_parameter](#module\_ireland\_share\_parameter) | ../modules/share_parameter | n/a |
| <a name="module_nvirginia_automation"></a> [nvirginia\_automation](#module\_nvirginia\_automation) | ./modules/automation | n/a |
| <a name="module_nvirginia_central"></a> [nvirginia\_central](#module\_nvirginia\_central) | aws-ia/cloudwan/aws | 3.2.0 |
| <a name="module_nvirginia_firewall_policy"></a> [nvirginia\_firewall\_policy](#module\_nvirginia\_firewall\_policy) | ./modules/firewall_policy | n/a |
| <a name="module_nvirginia_retrieve_parameters"></a> [nvirginia\_retrieve\_parameters](#module\_nvirginia\_retrieve\_parameters) | ../modules/retrieve_parameters | n/a |
| <a name="module_nvirginia_share_parameter"></a> [nvirginia\_share\_parameter](#module\_nvirginia\_share\_parameter) | ../modules/share_parameter | n/a |
| <a name="module_ohio_automation"></a> [ohio\_automation](#module\_ohio\_automation) | ./modules/automation | n/a |
| <a name="module_ohio_central"></a> [ohio\_central](#module\_ohio\_central) | aws-ia/cloudwan/aws | 3.2.0 |
| <a name="module_ohio_firewall_policy"></a> [ohio\_firewall\_policy](#module\_ohio\_firewall\_policy) | ./modules/firewall_policy | n/a |
| <a name="module_ohio_retrieve_parameters"></a> [ohio\_retrieve\_parameters](#module\_ohio\_retrieve\_parameters) | ../modules/retrieve_parameters | n/a |
| <a name="module_ohio_share_parameter"></a> [ohio\_share\_parameter](#module\_ohio\_share\_parameter) | ../modules/share_parameter | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.automation_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.automation_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.automation_lambda_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_networkmanager_core_network.core_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network) | resource |
| [aws_networkmanager_core_network_policy_attachment.core_network_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_core_network_policy_attachment) | resource |
| [aws_networkmanager_global_network.global_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkmanager_global_network) | resource |
| [aws_ram_principal_association.cwan_principal_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.cwan_resource_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.cwan_resource_share](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [archive_file.cwan_automation_package](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ec2_managed_prefix_list.ireland_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_ec2_managed_prefix_list.nvirginia_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_ec2_managed_prefix_list.ohio_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_iam_policy_document.automation_lambda_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.automation_lambda_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_networkmanager_core_network_policy_document.core_network_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/networkmanager_core_network_policy_document) | data source |
| [aws_organizations_organization.org](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_spoke_account_id"></a> [spoke\_account\_id](#input\_spoke\_account\_id) | Spoke AWS Account ID. | `string` | n/a | yes |
| <a name="input_aws_regions"></a> [aws\_regions](#input\_aws\_regions) | AWS Regions to create the environment. | `map(string)` | <pre>{<br>  "ireland": "eu-west-1",<br>  "nvirginia": "us-east-1",<br>  "ohio": "us-east-2"<br>}</pre> | no |
| <a name="input_guarduty_finding_names"></a> [guarduty\_finding\_names](#input\_guarduty\_finding\_names) | List of GuardDuty Finding names to filter in EventBridge. | `list(string)` | <pre>[<br>  "UnauthorizedAccess:EC2/MaliciousIPCaller.Custom",<br>  "CryptoCurrency:EC2/BitcoinTool.B!DNS",<br>  "Execution:Runtime/SuspiciousTool"<br>]</pre> | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project Identifier, used as identifer when creating resources. | `string` | `"nis342"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->