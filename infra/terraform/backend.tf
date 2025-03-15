terraform {
  backend "gcs" {
    bucket = "my-terraform-bucket-state"
    prefix = "terraform/state"
  }
}
