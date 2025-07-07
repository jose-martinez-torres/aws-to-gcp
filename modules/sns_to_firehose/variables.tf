variable "random_id" {
  description = "A random string to append to resource names for uniqueness."
  type        = string
}

variable "kinesis_firehose_stream_arn" {
  description = "The ARN of the Kinesis Firehose delivery stream to subscribe to."
  type        = string
}