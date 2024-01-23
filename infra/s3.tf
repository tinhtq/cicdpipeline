#Created Policy for IAM Role
resource "aws_iam_policy" "allow_s3" {

  name        = "${local.resource_name_prefix}-allow-s3-policy"
  description = "A policy to allow put Object s3"


  policy = data.aws_iam_policy_document.allow_s3_policy_statement.json
}
data "aws_iam_policy_document" "allow_s3_policy_statement" {
  statement {
    effect    = "Allow"
    actions   = ["logs:*"]
    resources = ["arn:aws:logs:*:*:*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["securityhub:*"]
    resources = ["*"]
  }
}

resource "aws_s3_bucket" "data_security_hub" {
  bucket = "pipeline-artifact-bucket-${local.account_id}"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.data_security_hub.id
  versioning_configuration {
    status = "Enabled"
  }
}
