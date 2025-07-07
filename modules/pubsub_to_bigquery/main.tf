# The Pub/Sub Topic (The GCP equivalent of an SNS Topic)
resource "google_pubsub_topic" "data_events" {
  name = "gcp-data-events-topic-${var.random_id}"
}

# The Pub/Sub Subscription that connects the Topic to the BigQuery table
resource "google_pubsub_subscription" "bigquery_subscription" {
  name  = "gcp-bigquery-subscription-${var.random_id}"
  topic = google_pubsub_topic.data_events.name

  bigquery_config {
    table = "${var.gcp_project_id}:${var.bigquery_table_dataset_id}.${var.bigquery_table_table_id}"
    # When true, use the BigQuery table's schema as the columns to write to.
    # Messages must be published in JSON format.
    use_table_schema = true
    # When true, messages that fail schema validation are dropped.
    # When false, they are written to an _error topic.
    drop_unknown_fields = true
    write_metadata      = false
  }

  # This explicit dependency ensures the IAM permissions for the Pub/Sub service account
  # are created *before* the subscription is created. This is required for BigQuery subscriptions
  # to prevent a race condition during the API's permission check.
  depends_on = [
    google_bigquery_table_iam_member.pubsub_bq_writer
  ]
}

# IAM: Grant the Pub/Sub service account permission to write to BigQuery
# First, get the service account email
data "google_project" "project" {
  project_id = var.gcp_project_id
}

# This is the special service account that Pub/Sub uses
locals {
  pubsub_service_account = "service-${data.google_project.project.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}

# Grant the service account the "BigQuery Data Editor" role on the specific table.
# This is the most secure approach, following the principle of least privilege by
# scoping permissions to the single resource that needs it.
resource "google_bigquery_table_iam_member" "pubsub_bq_writer" {
  project    = var.gcp_project_id
  dataset_id = var.bigquery_table_dataset_id
  table_id   = var.bigquery_table_table_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${local.pubsub_service_account}"
}