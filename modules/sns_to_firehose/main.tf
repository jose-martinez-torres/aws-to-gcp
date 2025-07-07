# IAM Role for SNS to be able to publish to the Kinesis Firehose stream
resource "aws_iam_role" "sns_firehose_role" {
  name = "aws-sns-to-firehose-role-${var.random_id}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "sns.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "sns_firehose_policy" {
  name        = "aws-sns-to-firehose-policy-${var.random_id}"
  description = "Allows SNS to publish to a specific Kinesis Firehose stream."
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "firehose:PutRecord",
        Effect   = "Allow",
        Resource = var.kinesis_firehose_stream_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sns_firehose_attach" {
  role       = aws_iam_role.sns_firehose_role.name
  policy_arn = aws_iam_policy.sns_firehose_policy.arn
}

# The SNS Topic (The "Pub/Sub" Topic)
resource "aws_sns_topic" "data_events" {
  name = "aws-data-events-topic-${var.random_id}"
}

# The SNS Subscription that connects the Topic to the Firehose stream
resource "aws_sns_topic_subscription" "firehose_subscription" {
  topic_arn              = aws_sns_topic.data_events.arn
  protocol               = "firehose"
  endpoint               = var.kinesis_firehose_stream_arn
  endpoint_auto_confirms = true
  subscription_role_arn  = aws_iam_role.sns_firehose_role.arn
}