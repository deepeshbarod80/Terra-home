// Creating on localhost ip only in docker container locally

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create isolated Docker network (no IP conflicts)
resource "docker_network" "terra_network" {
  name   = "terra-local-network"
  driver = "bridge"
}

# SSH key configuration using localhost paths
resource "local_file" "terra_ssh_key" {
  filename = "${path.module}/terra-local-key"
  content  = file("${path.module}/terra-key.pub")
}

# Security container with localhost-only exposure
resource "docker_container" "terra_security" {
  name  = "terra-local-gateway"
  image = "alpine:latest"
  command = ["tail", "-f", "/dev/null"]

  networks_advanced {
    name = docker_network.terra_network.name
  }

  # Bind ONLY to localhost (127.0.0.1)
  ports {
    internal = 22
    external = 32222
    ip       = "127.0.0.1"
  }
  ports {
    internal = 80
    external = 38880
    ip       = "127.0.0.1"
  }
  ports {
    internal = 443
    external = 38443
    ip       = "127.0.0.1"
  }
}

# Main application container (localhost only)
resource "docker_container" "terra_instance" {
  name  = "terra-local-app"
  image = "ubuntu:22.04"
  command = ["tail", "-f", "/dev/null"]

  networks_advanced {
    name = docker_network.terra_network.name
  }

  volumes {
    host_path      = abspath(local_file.terra_ssh_key.filename)
    container_path = "/root/.ssh/authorized_keys"
  }
}

output "access_instructions" {
  value = {
    note = "All services are ONLY available on localhost (127.0.0.1)"
    ssh  = "ssh root@127.0.0.1 -p 32222"
    web  = {
      http  = "http://127.0.0.1:38880"
      https = "https://127.0.0.1:38443"
    }
    management = {
      containers = "docker ps --filter 'name=terra-local-'"
      network    = "docker network inspect terra-local-network"
    }
  }
}