variable "random_id" {
  description = "A random string to append to resource names for uniqueness."
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "gcp_location" {
  description = "The GCP location (region or multi-region) for resources."
  type        = string
}