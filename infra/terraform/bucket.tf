resource "google_storage_bucket" "terraform_state" {
  name          = "my-discovery-tf-state-bucket-unique" # Remplacez par un nom unique
  location      = "US"                        # Région du bucket
  storage_class = "STANDARD"                  # Classe de stockage

  versioning {
    enabled = true                            # Active la gestion des versions pour protéger l'état Terraform
  }
}
