# Configuration de Terraform et du fournisseur Google
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

}

provider "google" {
  credentials = file("path/to/your/service-account-key.json") # Si nécessaire
  project     = "discovery-452411"                            # ID du projet Discovery
  region      = var.region
  zone        = var.zone
}

# Instance Compute Engine (VM) avec Docker
resource "google_compute_instance" "docker_host" {
  name         = "mon-instance"
  machine_type = "e2-medium" # Type de machine (2 vCPU, 4 Go RAM)
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12" # Image Debian Bookworm
    }
  }

  network_interface {
    network       = "default"
    access_config {} # Permet d'obtenir une IP publique
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ${var.ssh_user}
  EOT

  tags = ["docker-host"]
}

# Pare-feu pour autoriser SSH, HTTP et HTTPS
resource "google_compute_firewall" "allow_ssh_http_https" {
  name    = "allow-ssh-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = ["0.0.0.0/0"] # Autorise tout le monde (à restreindre si nécessaire)
}

# Instance Cloud SQL pour PostgreSQL
resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-instance"
  database_version = "POSTGRES_14" # Version PostgreSQL

  settings {
    tier              = "db-f1-micro" # Type d'instance (ajustez selon vos besoins)
    disk_size         = 10           # Taille du disque en Go
    disk_type         = "PD_SSD"     # Disque SSD persistant
    activation_policy = "ALWAYS"

    ip_configuration {
      ipv4_enabled   = true          # Activer IPv4 public pour se connecter à la base de données
      authorized_networks {          # Ajoutez votre IP publique ici si nécessaire
        name        = "my-ip"
        value       = "<YOUR_IP_ADDRESS>" # Remplacez par votre adresse IP publique ou laissez vide pour tester.
      }
    }
  }

  region = var.region
}

# Base de données PostgreSQL dans l'instance Cloud SQL
resource "google_sql_database" "postgres_db" {
  name     = "mydatabase"
  instance = google_sql_database_instance.postgres_instance.name
}

# Utilisateur PostgreSQL avec mot de passe défini dans les variables Terraform
resource "google_sql_user" "postgres_user" {
  name     = "admin"
  instance = google_sql_database_instance.postgres_instance.name
  password = var.postgres_password # Mot de passe défini dans les variables Terraform ou via un fichier sécurisé.
}
