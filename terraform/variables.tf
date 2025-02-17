variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
}

variable "node_count" {
  description = "Number of GKE nodes"
  type        = number
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
}