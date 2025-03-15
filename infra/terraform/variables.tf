variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "region" {
  description = "Région GCP"
  type        = string
}

variable "zone" {
  description = "Zone GCP"
  type        = string
}

variable "postgres_password" {
  description = "Mot de passe pour PostgreSQL"
  type        = string
}
