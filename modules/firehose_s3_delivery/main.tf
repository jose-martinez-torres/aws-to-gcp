# IAM Role for Kinesis Firehose to access S3 and Glue
resource "aws_iam_role" "firehose_role" {
  name = "aws-firehose-role-${var.random_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "firehose_policy" {
  name        = "aws-firehose-policy-${var.random_id}"
  description = "Policy for Kinesis Firehose to write to S3 and use Glue Catalog."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:GetTable",
          "glue:GetTableVersion",
          "glue:GetTableVersions"
        ],
        Resource = [
          var.glue_table_arn,
          var.glue_database_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "firehose_attach" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_policy.arn
}

# The Kinesis Firehose Delivery Stream (The "Push Subscription" logic)
resource "aws_kinesis_firehose_delivery_stream" "s3_stream" {
  name        = "aws-firehose-stream-${var.random_id}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.s3_bucket_arn

    # Best Practice: Partition data by arrival time for efficient querying
    # This creates a folder structure like: s3://.../data/2023/11/28/15/
    prefix              = "data/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}"

    # Best Practice: Convert incoming JSON to columnar Parquet format
    data_format_conversion_configuration {
      enabled = true
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }
      output_format_configuration {
        serializer {
          parquet_ser_de {}
        }
      }
      schema_configuration {
        role_arn      = aws_iam_role.firehose_role.arn
        database_name = var.glue_database_name
        table_name    = var.glue_table_name
        region        = var.aws_region
      }
    }
  }
}