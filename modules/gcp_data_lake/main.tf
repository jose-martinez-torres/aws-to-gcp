# GCS bucket to store the data (optional, as we stream to BigQuery)
# This can be used for a "data lake" raw storage approach.
resource "google_storage_bucket" "data_lake" {
  name          = "gcp-datalake-bucket-${var.random_id}"
  location      = var.gcp_location
  uniform_bucket_level_access = true
  force_destroy = true # Set to false in production
}

# BigQuery Dataset (equivalent to a Glue Database)
resource "google_bigquery_dataset" "events_db" {
  dataset_id = "gcp_events_database_${replace(var.random_id, "-", "_")}"
  location   = var.gcp_location
}

# BigQuery Table (equivalent to a Glue Table)
# This defines the schema for the data Pub/Sub will stream in.
resource "google_bigquery_table" "events_table" {
  dataset_id = google_bigquery_dataset.events_db.dataset_id
  table_id   = "gcp_events_table_${replace(var.random_id, "-", "_")}"
  project    = var.gcp_project_id

  # The schema of the incoming JSON messages
  schema = jsonencode([
    {
      "name" : "eventid",
      "type" : "STRING",
      "mode" : "NULLABLE"
    },
    {
      "name" : "eventtype",
      "type" : "STRING",
      "mode" : "NULLABLE"
    },
    {
      "name" : "payload",
      "type" : "STRING",
      "mode" : "NULLABLE"
    }
  ])
}