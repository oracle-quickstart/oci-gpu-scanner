# OCI Scanner Plugin Helm Chart

AMD GPU monitoring and health check solution for OCI compute instances.

## Components

- **Go Plugin**: Main metric collector
- **Node Exporter**: System metrics
- **AMD GPU Exporter**: GPU metrics
- **Metrics Push Job**: Automated metrics forwarding
- **Health Check**: GPU performance testing (optional)
- **DRHPC**: DRHPC monitoring (optional)

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

- Kubernetes cluster with AMD GPU nodes
- Prometheus Push Gateway accessible from cluster
- AMD GPU drivers installed on nodes