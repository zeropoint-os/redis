terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

variable "zp_module_id" {
  type        = string
  default     = "redis"
  description = "Unique identifier for this module instance (user-defined, freeform)"
}

 variable "zp_network_name" {
  type        = string
  description = "Pre-created Docker network name for this module (managed by zeropoint)"
}

variable "zp_arch" {
  type        = string
  default     = "amd64"
  description = "Target architecture - amd64, arm64, etc. (injected by zeropoint)"
}

variable "zp_module_storage" {
  type        = string
  description = "Host path for persistent storage (injected by zeropoint)"
}

# Build Redis image from local Dockerfile
resource "docker_image" "redis" {
  name = "${var.zp_module_id}:latest"
  build {
    context    = path.module
    dockerfile = "Dockerfile"
    platform   = "linux/${var.zp_arch}"  # Uses injected zp_arch variable
  }
  keep_locally = true
}

# Main Redis container (no host port binding)
resource "docker_container" "redis_main" {
  name  = "${var.zp_module_id}-main"
  image = docker_image.redis.image_id

  # Network configuration (provided by zeropoint)
  networks_advanced {
    name = var.zp_network_name
  }

  # Restart policy
  restart = "unless-stopped"

  # Persistent storage for Redis data
  volumes {
    host_path      = "${var.zp_module_storage}/data"
    container_path = "/data"
  }

  # Ports exposed internally (no host binding)
  # Port 6379 is accessible via service discovery (DNS)
}

# Outputs for zeropoint (container resource only)
output "redis_main" {
  value       = docker_container.redis_main
  description = "Main Redis container"
}

# Service ports for external access (defined but not bound to host)
# Service ports for external access (defined but not bound to host)
output "redis_main_ports" {
  value = {
    redis = {
      port        = 6379
      protocol    = "redis"
      transport   = "tcp"
      description = "Redis service port"
      default     = true
    }
  }
  description = "Service ports for external access"
}

# Ollama API URL for easy consumption by other modules
output "redis_url" {
  value       = "redis://${docker_container.redis_main.name}:6379"
  description = "Redis URL accessible via Docker network"
}