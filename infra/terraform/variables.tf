variable "project_id" {
  type        = string
  description = "ID du projet GCP"
}

variable "region" {
  type        = string
  description = "Région pour les ressources GCP"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "Zone pour les ressources GCP"
  default     = "us-central1-c"
}

variable "postgres_password" {
  type        = string
  description = "Mot de passe PostgreSQL root"
}
