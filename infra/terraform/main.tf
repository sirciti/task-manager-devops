# Configuration de Terraform et du fournisseur Google (version 6.8.0)
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0" # Version mise à jour
    }
  }

  # Configuration du backend GCS pour le statefile
  # backend "gcs" {
   #  bucket = "tf-state-task-manager-001" # Nom du bucket existant
   #  prefix = "terraform/state"          # Chemin pour le fichier de state
 #  }
}

provider "google" {
  credentials = file("service-account-key.json") # Chemin vers le fichier JSON
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# Instance Compute Engine avec Docker pré-installé
resource "google_compute_instance" "docker_host" {
  name         = "mon-instance"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network    = "default"
    access_config {} # IP publique
  }

  metadata_startup_script = templatefile("${path.module}/startup.sh", {
    ssh_user = var.ssh_user
  })

  tags = ["docker-host"]
}

# Pare-feu amélioré avec variables pour IP source
resource "google_compute_firewall" "allow_ssh_http_https" {
  name    = "allow-ssh-http-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  source_ranges = [var.allowed_ip] # Variable pour IP autorisée
}

# Cloud SQL PostgreSQL avec sauvegarde automatique
resource "google_sql_database_instance" "postgres_instance" {
  name             = "postgres-instance"
  database_version = "POSTGRES_14"
  deletion_protection = false # Désactiver pour les environnements de test

  settings {
    tier              = "db-f1-micro"
    disk_size         = 10
    disk_type         = "PD_SSD"
    availability_type = "ZONAL"

    backup_configuration {
      enabled     = true
      start_time  = "23:00"
    }

    ip_configuration {
      ipv4_enabled          = true
      authorized_networks {
        name  = "admin-access"
        value = var.allowed_ip
      }
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Configuration réseau avancée pour Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "default"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "default"
}
