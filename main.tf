terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use a random suffix to ensure resource names are unique
resource "random_pet" "this" {
  length = 2
}

module "data_lake" {
  source = "./modules/data_lake"

  random_id = random_pet.this.id
}

module "firehose_s3_delivery" {
  source = "./modules/firehose_s3_delivery"

  random_id         = random_pet.this.id
  aws_region        = var.aws_region
  s3_bucket_arn     = module.data_lake.s3_bucket_arn
  glue_database_name = module.data_lake.glue_database_name
  glue_table_name   = module.data_lake.glue_table_name
  glue_database_arn = module.data_lake.glue_database_arn
  glue_table_arn    = module.data_lake.glue_table_arn
}

module "sns_to_firehose" {
  source = "./modules/sns_to_firehose"

  random_id                   = random_pet.this.id
  kinesis_firehose_stream_arn = module.firehose_s3_delivery.kinesis_firehose_stream_arn
}