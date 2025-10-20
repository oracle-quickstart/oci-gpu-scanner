# OCI Scanner Plugin

A Kubernetes-native monitoring solution for GPU resources and system metrics on OCI compute instances. This plugin provides comprehensive monitoring capabilities for both AMD and NVIDIA GPUs, along with system-level metrics collection and automated health checks.

## Quick Start

Deploy all components with a single command:

```bash
# Deploy all components
kubectl apply -f oci_scanner_plugin/
```

## Components

### 1. **NVlink RDMA exporter** (`go-plugin/`)
**Custom OCI Lens metric collector with GPU and system monitoring**

- **Purpose**: Collects GPU metrics, system information, and RDMA network statistics
- **Deployment**: DaemonSet that runs on all GPU-enabled nodes
- **Features**:
  - AMD and NVIDIA GPU support
  - RDMA network monitoring
  - System resource metrics
  - Automatic metrics pushing to Prometheus Push Gateway

**Deploy:**
```bash
kubectl apply -f oci_scanner_plugin/go-plugin/
```

**Configuration:**
- Update `PUSH_GATEWAY` URL in `daemonset.yaml` (line 70) and `configmap.yaml` (line 10)
- Modify `GPU_TYPE` environment variable for specific GPU types
- Adjust `PUSH_FREQUENCY` for metrics collection interval

### 2. **Node and GPU Exporters** (`node-and-gpu-exporters/`)
**System and GPU metrics collection using industry-standard exporters**

- **Node Exporter**: System-level metrics (CPU, memory, disk, network)
- **AMD GPU Exporter**: AMD GPU-specific metrics and health information
- **Deployment**: DaemonSets with host networking for direct hardware access

**Deploy:**
```bash
kubectl apply -f oci_scanner_plugin/node-and-gpu-exporters/
```

**Features:**
- Prometheus-compatible metrics endpoints
- Host filesystem access for comprehensive system monitoring
- GPU device access for hardware-specific metrics
- Automatic service discovery annotations

### 3. **Metrics Push Job** (`metrics-push-job/`)
**Automated metrics collection and forwarding to Prometheus Push Gateway**

- **Purpose**: Collects metrics from exporters and pushes to Push Gateway every minute
- **Deployment**: CronJob with RBAC permissions
- **Features**:
  - Automatic discovery of available exporters
  - Error handling and logging
  - Configurable Push Gateway URL
  - Node-specific metric labeling

**Deploy:**
```bash
# Set your Push Gateway URL
export PUSHGATEWAY_URL="http://your-pushgateway:9091/metrics"

# Update configmap with your URL
kubectl patch configmap pushgateway-config -n oci-monitoring \
  --patch '{"data":{"url":"'$PUSHGATEWAY_URL'"}}'

# Deploy the push job
kubectl apply -f oci_scanner_plugin/metrics-push-job/
```
or update the `configmap.yaml` before deploying.

### 4. **Active Health Check** (`active-health-check/`)
**PyTorch-based GPU performance testing and health validation**

- **Purpose**: Comprehensive GPU health checks using PyTorch workloads
- **Deployment**: Kubernetes Job for on-demand testing
- **Features**:
  - AMD GPU functional testing
  - Performance benchmarking
  - Matrix multiplication tests
  - Memory bandwidth validation

**Deploy:**
```bash
kubectl apply -f oci_scanner_plugin/active-health-check/
```

**Test Categories:**
- Model MFU (Model Flops Utilization)
- Compute throughput validation
- Memory bandwidth testing
- GPU temperature and power monitoring
- Error detection and reporting

## Configuration

### Prerequisites
- Kubernetes cluster with GPU nodes
- Prometheus Push Gateway accessible from cluster
- Appropriate RBAC permissions for DaemonSets and Jobs

### Namespace Setup
Most components use the `oci-monitoring` namespace. Create it if it doesn't exist:

```bash
kubectl create namespace oci-monitoring
```

### GPU Node Requirements
- AMD GPU nodes should have `amd.com/gpu=true` label
- NVIDIA GPU nodes should have `nvidia.com/gpu` taint
- Nodes must have appropriate GPU drivers installed

## Monitoring

### Access Metrics
- **Node Exporter**: `http://node-ip:9100/metrics`
- **AMD GPU Exporter**: `http://node-ip:5000/metrics`
- **OCI Lens Plugin**: `http://node-ip:8080/metrics`

### View Push Job Logs
```bash
kubectl logs -l app=metrics-push-job -n oci-monitoring --tail=50
```

### Check Health Check Results
```bash
kubectl logs -l app=amd-gpu-healthcheck -n monitoring
```

## Cleanup

Remove all components:

```bash
# Remove all components
kubectl delete -f oci_scanner_plugin/

# Or remove individually
kubectl delete -f oci_scanner_plugin/go-plugin/
kubectl delete -f oci_scanner_plugin/node-and-gpu-exporters/
kubectl delete -f oci_scanner_plugin/metrics-push-job/
kubectl delete -f oci_scanner_plugin/active-health-check/
```

## 🔍 Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n oci-monitoring
kubectl get pods -n monitoring
```

### View Logs
```bash
# Go Plugin logs
kubectl logs -l app=oci-lens-plugin -n monitoring

# Exporter logs
kubectl logs -l app=node-exporter -n oci-monitoring
kubectl logs -l app=amd-gpu-exporter -n oci-monitoring

# Push job logs
kubectl logs -l app=metrics-push-job -n oci-monitoring
```

### Test Connectivity
```bash
# Test AMD GPU exporter
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl http://localhost:5000/metrics

# Test Node Exporter
kubectl run test-pod --image=curlimages/curl --rm -it --restart=Never -- curl http://localhost:9100/metrics
```

### Common Issues
1. **Permission Denied**: Ensure pods have appropriate security contexts and capabilities
2. **GPU Not Detected**: Verify GPU drivers and device mounts
3. **Push Gateway Unreachable**: Check network connectivity and URL configuration
4. **Metrics Not Appearing**: Verify Prometheus scraping configuration

## Advanced Usage

### Custom GPU Types
Modify the `GPU_TYPE` environment variable in the Go Plugin DaemonSet to support specific GPU architectures.

### Custom Metrics Collection
Extend the metrics push job script to collect additional metrics or modify collection frequency.

### Integration with Prometheus
Configure Prometheus to scrape the exposed metrics endpoints or use the Push Gateway for metric ingestion.

---

**Note**: This plugin is designed to work with OCI Lens but can be used independently for GPU monitoring on any Kubernetes cluster with GPU nodes.
