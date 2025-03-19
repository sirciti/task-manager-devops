# Configuration du backend GCS pour le statefile
terraform {
  backend "gcs" {
    bucket = "tf-state-task-manager-001"
    prefix = "terraform/state"
    credentials = "service-account-key.json"
  }
}
