locals {
  message_retention_seconds  = 604800 # 7 days
  receive_wait_time_seconds  = 20

  queues = {
    "triaige-docs-received" = {
      dlq_name                  = "triaige-docs-received-dlq"
      visibility_timeout_seconds = 60
      max_receive_count         = 3
    }
    "triaige-docs-preprocessing" = {
      dlq_name                  = "triaige-docs-preprocessing-dlq"
      visibility_timeout_seconds = 300
      max_receive_count         = 3
    }
    "triaige-results-ready" = {
      dlq_name                  = "triaige-results-ready-dlq"
      visibility_timeout_seconds = 120
      max_receive_count         = 5
    }
  }
}

resource "aws_sqs_queue" "dlq" {
  for_each = local.queues

  name                      = each.value.dlq_name
  message_retention_seconds = local.message_retention_seconds

  tags = {
    Name = each.value.dlq_name
  }
}

resource "aws_sqs_queue" "main" {
  for_each = local.queues

  name                       = each.key
  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = local.message_retention_seconds
  receive_wait_time_seconds  = local.receive_wait_time_seconds

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.key].arn
    maxReceiveCount     = each.value.max_receive_count
  })

  tags = {
    Name = each.key
  }

  depends_on = [aws_sqs_queue.dlq]
}
