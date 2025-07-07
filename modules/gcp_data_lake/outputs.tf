output "gcs_bucket_name" {
  description = "The name of the GCS bucket."
  value       = google_storage_bucket.data_lake.name
}

output "gcs_bucket_url" {
  description = "The URL of the GCS bucket."
  value       = google_storage_bucket.data_lake.url
}

output "bigquery_dataset_id" {
  description = "The ID of the BigQuery dataset."
  value       = google_bigquery_dataset.events_db.dataset_id
}

output "bigquery_table_id" {
  description = "The ID of the BigQuery table."
  value       = google_bigquery_table.events_table.table_id
}

output "bigquery_table_project" {
  description = "The Project ID of the BigQuery table."
  value       = google_bigquery_table.events_table.project
}