variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "app_image" {
  description = "Container image for the Flask application"
  type        = string
}
