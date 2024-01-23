data "archive_file" "security_hub_zip" {
  source_dir  = local.lambda_code_path
  output_path = local.lambda_archive_path
  type        = "zip"
}

data "aws_iam_policy_document" "security_hub_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "security_hub" {
  name               = "${local.resource_name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.security_hub_assume_role_policy.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    aws_iam_policy.allow_s3.arn
  ]
  tags = {
    Name = "${local.resource_name_prefix}-role"
  }
}

resource "aws_lambda_function" "security_hub" {
  function_name    = "${local.resource_name_prefix}-lambda"
  source_code_hash = data.archive_file.security_hub_zip.output_base64sha256
  filename         = data.archive_file.security_hub_zip.output_path
  description      = local.lambda_description
  role             = aws_iam_role.security_hub.arn
  handler          = local.lambda_handler
  runtime          = local.lambda_runtime
  timeout          = local.lambda_timeout

  tags = {
    Name = "${local.resource_name_prefix}-lambda"
  }


  reserved_concurrent_executions = local.lambda_concurrent_executions
}

resource "aws_cloudwatch_log_group" "security_hub" {
  name              = local.lambda_cw_log_group_name
  retention_in_days = local.lambda_log_retention_in_days
}
