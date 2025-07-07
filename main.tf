terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.13"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Use a random suffix to ensure resource names are unique
resource "random_pet" "this" {
  length = 2
}

module "gcp_data_lake" {
  source = "./modules/gcp_data_lake"

  random_id    = random_pet.this.id
  gcp_project_id = var.gcp_project_id
  gcp_location = var.gcp_region # Datasets and buckets can be regional
}

module "pubsub_to_bigquery" {
  source = "./modules/pubsub_to_bigquery"

  random_id                 = random_pet.this.id
  gcp_project_id            = var.gcp_project_id
  bigquery_table_project    = module.gcp_data_lake.bigquery_table_project
  bigquery_table_dataset_id = module.gcp_data_lake.bigquery_dataset_id
  bigquery_table_table_id   = module.gcp_data_lake.bigquery_table_id
}