variable "random_id" {
  description = "A random string to append to resource names for uniqueness."
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "bigquery_table_project" {
  description = "The project ID of the BigQuery table."
  type        = string
}

variable "bigquery_table_dataset_id" {
  description = "The dataset ID of the BigQuery table."
  type        = string
}

variable "bigquery_table_table_id" {
  description = "The table ID of the BigQuery table."
  type        = string
}