# The Pub/Sub Topic (The GCP equivalent of an SNS Topic)
resource "google_pubsub_topic" "data_events" {
  name = "gcp-data-events-topic-${var.random_id}"
}

# The Pub/Sub Subscription that connects the Topic to the BigQuery table
resource "google_pubsub_subscription" "bigquery_subscription" {
  name  = "gcp-bigquery-subscription-${var.random_id}"
  topic = google_pubsub_topic.data_events.name

  bigquery_config {
    table = "${var.bigquery_table_project}:${var.bigquery_table_dataset_id}.${var.bigquery_table_table_id}"
    # When true, the subscription writes data to the table, and format is not required.
    use_topic_schema = false
    # When true, messages that fail schema validation are dropped.
    # When false, they are written to an _error topic.
    drop_unknown_fields = true
    write_metadata      = false
  }

  # This explicit dependency ensures the IAM permissions for the Pub/Sub service account
  # are created *before* the subscription is created. This is required for BigQuery subscriptions
  # to prevent a race condition during the API's permission check.
  depends_on = [
    google_bigquery_dataset_iam_member.pubsub_bq_writer,
    google_project_iam_member.pubsub_token_creator
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

# Grant the service account the "BigQuery Data Editor" role on the specific dataset.
# This is more secure and follows the principle of least privilege.
resource "google_bigquery_dataset_iam_member" "pubsub_bq_writer" {
  project    = var.bigquery_table_project
  dataset_id = var.bigquery_table_dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${local.pubsub_service_account}"
}

# Grant the service account the "Token Creator" role so it can create tokens to write
resource "google_project_iam_member" "pubsub_token_creator" {
  project = var.gcp_project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${local.pubsub_service_account}"
}