# ---------- network/modules/automation/main.tf ----------
data "aws_region" "region" {}

# ---------- AMAZON EVENTBRIDGE ----------
resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "guardduty-event-rule-${data.aws_region.region.name}"
  description = "Capture Amazon GuardDuty findings."

  event_pattern = jsonencode({
    source = ["aws.guardduty"]
    detail = {
      type = [
        "UnauthorizedAccess:EC2/MaliciousIPCaller.Custom",
        "CryptoCurrency:EC2/BitcoinTool.B!DNS",
        "Execution:Runtime/MaliciousFileExecuted",
        "UnauthorizedAccess:EC2/SSHBruteForce",
        "Execution:Runtime/SuspiciousCommand",
        "Recon:EC2/PortProbeUnprotectedPort",
        "Trojan:EC2/DNSDataExfiltration",
        "Backdoor:EC2/C&CActivity.B!DNS",
        "Execution:EC2/MaliciousFile"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.event_rule.id
  target_id = "${data.aws_region.region.name}-lambda"
  arn       = aws_lambda_function.lambda_function.arn

  input_transformer {
    input_paths = {
      Finding_ID          = "$.detail.id",
      Finding_Type        = "$.detail.type",
      Finding_description = "$.detail.description",
      instanceId          = "$.detail.resource.instanceDetails.instanceId",
      region              = "$.detail.region",
      severity            = "$.detail.severity",
      vpcId               = "$.detail.resource.instanceDetails.networkInterfaces[0].vpcId",
    }
    input_template = <<EOF
{
  "InputTemplate": "{ \"Finding_ID\": \"<Finding_ID>\", \"Finding_Type\": \"<Finding_Type>\", \"Finding_description\": \"<Finding_description>\", \"instanceId\": \"<instanceId>\", \"region\": \"<region>\", \"severity\": \"<severity>\", \"vpcId\": \"<vpcId>\" }"
}
EOF
  }
}

resource "aws_lambda_permission" "eventbridge_lambda_permission" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn
}

# ---------- AWS LAMBDA FUNCTION ----------
resource "aws_lambda_function" "lambda_function" {
  function_name    = "${data.aws_region.region.name}-automation-function"
  filename         = "automation.zip"
  source_code_hash = var.source_code_hash

  role        = var.lambda_role_arn
  runtime     = "python3.12"
  handler     = "automation.lambda_handler"
  timeout     = 60
  memory_size = 128

  environment {
    variables = { CORE_NETWORK_ID = var.core_network_id }
  }
}