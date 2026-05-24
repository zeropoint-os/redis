# Redis zeropoint app

This module defines a Redis server for zeropoint OS using Terraform and the Docker provider.

## Resources Created

- **Docker Image**: Builds from local `Dockerfile` with platform-specific targeting
- **Docker Container**: Redis server

## Requirements

- Terraform >= 1.0
- Docker provider ~> 3.0

## Usage

### Via zeropoint API

```bash
curl -X POST http://<zeropoint-node-name>:2370/modules/install \
  -H "Content-Type: application/json" \
  -d '{
    "source": "https://github.com/zeropoint-os/redis.git", 
    "module_id": "redis",
    "arch": "amd64"
  }'
```

### Manual (for testing)

Use Run task (Shift+Alt+T)
1. Full test - setup and apply
2. Full test - cleanup

The install will be performed using Docker-in-Docker.

## Inputs

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `zp_module_id` | string | Unique identifier for this module instance (injected by zeropoint) | `"redis"` |
| `zp_network_name` | string | Pre-created Docker network name (injected by zeropoint) | (required) |
| `zp_arch` | string | Target architecture: amd64, arm64, etc. (injected by zeropoint) | `"amd64"` |
| `zp_module_dir` | string | Agent's working directory for this module — terraform state + cloned source (injected by zeropoint) | (required) |
| `zp_storage_dir` | string | Isolated data root for this module — all bind mounts must live under here (injected by zeropoint) | (required) |

## Outputs

| Name | Description |
|------|-------------|
| `main` | Main Ollama container resource (docker_container) |

## GPU Support

This module supports multiple GPU vendors:

# Persistence
This module mounts `${zp_storage_dir}/data` into the container's `/data` directory so Redis data is persisted on the host.

## Network & Service Discovery

- **Internal Port**: 6379 (Redis)
- **Network**: Uses pre-created network provided by zeropoint via `zp_network_name`
- **No Host Ports**: Service discovery via DNS only
- **Container Name**: `${zp_module_id}-main` (e.g., `ollama-main`)

## Accessing Ollama

### From Other Containers (Service Discovery)

Other apps linked to Ollama can access it via DNS:

```bash
redis-cli -h redis-main ping
```

### From Host (via Exposure)

External access requires creating an exposure through zeropoint API.
