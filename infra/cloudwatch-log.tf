resource "aws_cloudwatch_log_group" "falco" {
  name = "falco"
  retention_in_days = 1
}
