resource "aws_sqs_queue" "standard_queue" {
  depends_on = [
    aws_sqs_queue.dead_letter_queue
  ]
  name = var.name

  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  policy                      = var.policy
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  deduplication_scope         = var.deduplication_scope
  fifo_throughput_limit       = var.fifo_throughput_limit

  kms_master_key_id                 = "alias/${var.name}-sqs"
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  tags = var.tags

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = var.max_receive_count
  })
}

resource "aws_sqs_queue" "dead_letter_queue" {
  name = "${var.name}-dl"

  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  max_message_size            = var.max_message_size
  delay_seconds               = var.delay_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  policy                      = var.policy-dl
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.content_based_deduplication
  deduplication_scope         = var.deduplication_scope
  fifo_throughput_limit       = var.fifo_throughput_limit

  kms_master_key_id                 = "alias/${var.name}-sqs"
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  tags = var.tags

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = ["arn:aws:sqs:${var.aws_region}:${var.aws_account_id}:${var.name}"]
  })
}

module "sqs_kms_key" {
  source                = "git::https://github.com/CareRevolutions/terraform-common-modules.git//kms?ref=0.0.16"
  description           = "used for sqs queues"
  key_name              = "${var.name}-sqs"
  extra_kms_policy_json = data.aws_iam_policy_document.sqs_kms_policy.json
}

data "aws_iam_policy_document" "sqs_kms_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
    principals {
      identifiers = var.services
      type        = "Service"
    }
  }
}

output "standard_queue" {
  value = aws_sqs_queue.standard_queue
}

output "dead_letter_queue" {
  value = aws_sqs_queue.dead_letter_queue
}

output "sqs_kms_key" {
  value = module.sqs_kms_key
}
