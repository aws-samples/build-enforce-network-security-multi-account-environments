# ---------- network/modules/vpc_endpoints/outputs.tf ----------

output "r53_profile" {
  description = "Route 53 Profile ARN."
  value       = awscc_route53profiles_profile.r53_profile.arn
}