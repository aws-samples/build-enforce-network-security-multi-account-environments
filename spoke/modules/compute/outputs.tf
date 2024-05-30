# --- spoke/modules/compute/outputs.tf ---

output "ec2_instances" {
  value       = aws_instance.ec2_instance
  description = "List of instances created."
}