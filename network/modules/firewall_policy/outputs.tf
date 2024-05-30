# ---------- network/modules/firewall_policy/outputs.tf ----------

output "firewall_policy_arn" {
  value = aws_networkfirewall_firewall_policy.anfw_policy.arn
}