# OCI Scanner Plugin Helm Chart

Multi-vendor GPU monitoring and health check solution for OCI compute instances with AMD and NVIDIA GPUs.

## Components

- **Go Plugin**: Main metric collector
- **Node Exporter**: System metrics (via subchart)
- **AMD GPU Exporter**: AMD GPU metrics via ROCm Device Metrics Exporter
- **NVIDIA DCGM Exporter**: NVIDIA GPU metrics (via subchart)
- **Metrics Push Daemon**: Automated metrics forwarding to Pushgateway
- **Pod Node Mapper**: Pod-to-node relationship tracking
- **Health Check**: GPU performance testing (optional)
- **DRHPC**: Distributed diagnostic monitoring for both AMD and NVIDIA

## Configuration

```bash
helm dependency build
helm dependency update 

helm install oci-gpu-scanner-plugin . -f values.yaml -n oci-gpu-scanner-plugin \
  --set global.pushGatewayUrl="<your-push-gateway-url>" \
  --create-namespace

# Enable health check
helm install oci-gpu-scanner-plugin ./oci-scanner-plugin-amd-helm \
  --set healthCheck.enabled=true

# Uninstall
helm uninstall oci-gpu-scanner-plugin -n oci-gpu-scanner-plugin
```

## Requirements

- Kubernetes cluster with AMD / Nvidia GPU nodes
- Prometheus Push Gateway accessible from cluster
- AMD GPU drivers installed on nodes
- Nvidia GPU Drivers installed on the nodes