variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

variable "credentials_file" {
  description = "Chemin vers le fichier de credentials GCP"
  type        = string
  default     = "service-account-key.json" # Placer le fichier dans le dossier terraform
}

variable "region" {
  description = "Région GCP"
  type        = string
  default     = "europe-west9"
}

variable "zone" {
  description = "Zone GCP"
  type        = string
  default     = "europe-west9-a"
}

variable "postgres_password" {
  description = "Mot de passe PostgreSQL"
  type        = string
  sensitive   = true # Masque la valeur dans les logs
}

variable "ssh_user" {
  description = "Utilisateur SSH"
  type        = string
  default     = "admin"
}

variable "allowed_ip" {
  description = "IP autorisée pour l'accès SSH/SQL"
  type        = string
  default     = "176.187.164.57/32" # À adapter
}
