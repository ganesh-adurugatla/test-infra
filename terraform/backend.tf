# terraform/backend.tf
terraform {
  backend "gcs" {
    bucket = "vishakha-403211-tfstate"
    prefix = "terraform/state"
  }
}
