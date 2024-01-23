locals {
  resource_name_prefix         = "security-hub"
  lambda_code_path             = "${path.module}/lambdas/security_hub"
  lambda_archive_path          = "${path.module}/lambdas/security_hub.zip"
  lambda_handler               = "import_findings_security_hub.lambda_handler"
  lambda_description           = "Security Hub"
  lambda_runtime               = "python3.8"
  lambda_timeout               = 60
  lambda_concurrent_executions = -1
  lambda_cw_log_group_name     = "/aws/lambda/${aws_lambda_function.security_hub.function_name}"
  lambda_log_retention_in_days = 1
  account_id                   = data.aws_caller_identity.current.account_id

}
