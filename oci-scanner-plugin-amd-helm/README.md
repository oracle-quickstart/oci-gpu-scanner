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
# Custom push gateway
helm install oci-scanner-plugin ./oci-scanner-plugin-helm \
  --set global.pushGatewayUrl=http://my-pushgateway:9091/

# Enable health check
helm install oci-scanner-plugin ./oci-scanner-plugin-helm \
  --set healthCheck.enabled=true

# Uninstall
helm uninstall oci-scanner-plugin
```

## Requirements

- Kubernetes cluster with AMD GPU nodes
- Prometheus Push Gateway accessible from cluster
- AMD GPU drivers installed on nodes