resource "aws_iam_user_policy" "sqs" {
  count  = var.user_name != null ? 1 : 0
  policy = data.aws_iam_policy_document.sqs.json
  user   = var.user_name
}

resource "aws_iam_user_policy" "bucket" {
  count  = length(var.bucket_names) > 0 && var.user_name != null ? 1 : 0
  policy = data.aws_iam_policy_document.bucket.json
  user   = var.user_name
}

resource "aws_iam_role_policy" "sqs" {
  count  = var.role_id != null ? 1 : 0
  policy = data.aws_iam_policy_document.sqs.json
  role   = var.role_id
}

resource "aws_iam_role_policy" "bucket" {
  count  = length(var.bucket_names) > 0 && var.role_id != null ? 1 : 0
  policy = data.aws_iam_policy_document.bucket.json
  role   = var.role_id
}

data "aws_iam_policy_document" "sqs" {
  statement {
    sid    = "SQSKMSPolicy"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = var.kms_key_arns
  }

  statement {
    sid    = "SQSKMSPolicy1"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueURL"
    ]
    resources = var.sqs_queue_arns
  }
}

data "aws_kms_alias" "this" {
  for_each = toset(var.bucket_names)
  name     = "alias/${each.key}-s3"
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "BucketPolicy"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetObjectVersion",
      "s3:DeleteObjectVersion",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl"
    ]
    resources = concat([for bucket in var.bucket_names : "arn:aws:s3:::${bucket}"], [for bucket in var.bucket_names : "arn:aws:s3:::${bucket}/*"])
  }

  statement {
    sid    = "KMSPolicy"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [for bucket in var.bucket_names : data.aws_kms_alias.this[bucket].target_key_arn]
  }
}
