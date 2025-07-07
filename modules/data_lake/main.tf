# S3 bucket to store the data from Firehose (The "BigQuery" storage)
resource "aws_s3_bucket" "data_lake" {
  bucket = "aws-datalake-bucket-${var.random_id}"
}

# AWS Glue Catalog database
resource "aws_glue_catalog_database" "events_db" {
  name = "aws_events_database_${var.random_id}"
}

# AWS Glue Catalog table (The "BigQuery Table" definition)
# This defines the schema for the data Firehose will store in S3.
resource "aws_glue_catalog_table" "events_table" {
  name          = "aws_events_table_${var.random_id}"
  database_name = aws_glue_catalog_database.events_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "EXTERNAL"            = "TRUE"
    "parquet.compression" = "SNAPPY"
    "projection.enabled"  = "true" # For Athena partition projection
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.data_lake.id}/data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet-serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = "1"
      }
    }

    # Define the schema of the incoming JSON messages
    columns {
      name = "eventid"
      type = "string"
    }
    columns {
      name = "eventtype"
      type = "string"
    }
    columns {
      name = "payload"
      type = "string"
    }
  }
}