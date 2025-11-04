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
- **Node Problem Detector**: GPU health monitoring via DRHPC integration (requires labeling)

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

# Enable Node Problem Detector (requires node labeling and drhpc to be enabled- see below)
helm upgrade oci-gpu-scanner-plugin . \
  --set nodeProblemDetector.enabled=true \
  --set drhpc.enabled=true

# Uninstall
helm uninstall oci-gpu-scanner-plugin -n oci-gpu-scanner-plugin
```

## Requirements

- Kubernetes cluster with AMD / Nvidia GPU nodes
- Prometheus Push Gateway accessible from cluster
- AMD GPU drivers installed on nodes
- Nvidia GPU Drivers installed on the nodes

## Node Problem Detector Setup

**IMPORTANT**: The Node Problem Detector will only work on GPU nodes that are labeled with `oci.oraclecloud.com/oke-node-problem-detector-enabled="true"`. And it reads these metrics from drhpc, so ensure that is enabled while deploying.

Before enabling NPD, label your GPU nodes:

```bash
# Label individual nodes
kubectl label nodes <node-name> oci.oraclecloud.com/oke-node-problem-detector-enabled=true

# Label all AMD GPU nodes
kubectl label nodes --selector=amd.com/gpu=true oci.oraclecloud.com/oke-node-problem-detector-enabled=true

# Label all NVIDIA GPU nodes
kubectl label nodes --selector=nvidia.com/gpu=true oci.oraclecloud.com/oke-node-problem-detector-enabled=true

# Verify labels
kubectl get nodes --show-labels | grep oke-node-problem-detector-enabled
```

Then enable NPD:

```bash
helm upgrade oci-gpu-scanner-plugin . \
  --set nodeProblemDetector.enabled=true \
  --set drhpc.enabled=true
```

**Note**: NPD requires DRHPC to be enabled and running to provide GPU health check data.