resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = false
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.name
  name  = "nginx_server"

  ports {
    internal = 80
    external = 8080
  }
}

resource "docker_image" "postgres" {
  name         = "postgres:latest"
  keep_locally = false
}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.name
  name  = "postgres_server"

  ports {
    internal = 5432
    external = 5432
  }

  env = [
    "POSTGRES_USER=admin",
    "POSTGRES_PASSWORD=admin123",
    "POSTGRES_DB=mydatabase",
    "PGDATA=/var/lib/postgresql/data/pgdata"
  ]

  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql/data"
  }

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U admin -d mydatabase"]
    interval = "10s"
    timeout  = "5s"
    retries  = 3
  }

  log_driver = "json-file"
  log_opts = {
    max-size = "10m"
    max-file = "3"
  }
}
