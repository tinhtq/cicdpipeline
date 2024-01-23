output "ec2-instance-ip" {
  value = aws_instance.web.*.public_ip
}
output "lambda" {
  value = aws_lambda_function.security_hub.function_name
}