# Cost Tracking with OpenCost in OCI Lens

## Overview

OCI GPU Scanner integrates OpenCost to provide comprehensive cost visibility for Kubernetes workloads running on OCI. OpenCost exposes detailed cost and resource allocation metrics that are automatically collected by Prometheus and can be visualized in Grafana.

## Metrics Reference

### Node Cost Metrics

These metrics provide hourly cost information at the node level.

#### `oci_lens_cost_node_cpu_hourly_cost`
- **Description**: Hourly cost per oCPU core on the node
- **Unit**: USD per hour per oCPU core

#### `oci_lens_cost_node_ram_hourly_cost`
- **Description**: Hourly cost per GiB of RAM on the node
- **Unit**: USD per hour per GiB

#### `oci_lens_cost_node_gpu_hourly_cost`
- **Description**: Hourly cost per GPU on the node
- **Unit**: USD per hour per GPU

#### `oci_lens_cost_node_gpu_count`
- **Description**: Number of GPUs available on the node
- **Unit**: Count

#### `oci_lens_cost_node_total_hourly_cost`
- **Description**: Total hourly cost for the entire node
- **Unit**: USD per hour
- **Calculation**:
  - **CPU nodes**: `(vCPU_cores / 2) × oci_lens_cost_node_cpu_hourly_cost + RAM_GiB × oci_lens_cost_node_ram_hourly_cost`
  - **GPU nodes**: `GPU_count × oci_lens_cost_node_gpu_hourly_cost` (CPU/RAM included in GPU cost)
> **Note**: OCI pricing uses OCPUs (1 OCPU = 2 vCPUs), so CPU cost calculation divides vCPU count by 2.

---

### Storage Metrics

#### `oci_lens_cost_pv_hourly_cost`
- **Description**: Hourly cost for persistent volumes
- **Unit**: USD per hour

---

### Container Resource Allocation Metrics

These metrics show actual resource allocations to containers, used for chargeback and cost attribution.

#### `oci_lens_cost_container_cpu_allocation`
- **Description**: Number of CPU cores allocated to the container
- **Unit**: CPU cores

#### `oci_lens_cost_container_memory_allocation_bytes`
- **Description**: Memory (RAM) allocated to the container in bytes
- **Unit**: Bytes

#### `oci_lens_cost_container_gpu_allocation`
- **Description**: Number of GPUs allocated to the container
- **Unit**: GPU count
- **Supported GPU types**:
  - NVIDIA GPUs (`nvidia.com/gpu`)
  - AMD GPUs (`amd.com/gpu`)

#### `oci_lens_cost_pod_pvc_allocation`
- **Description**: Persistent volume claim allocation for pods
- **Unit**: Bytes allocated per claim

---

### Cluster and Network Metrics

#### `oci_lens_cost_kubecost_cluster_info`
- **Description**: Cluster metadata and information

#### `oci_lens_cost_kubecost_node_is_spot`
- **Description**: Indicates if a node is a spot/preemptible instance
- **Values**: 
  - `1` = Spot instance
  - `0` = On-demand instance

#### `oci_lens_cost_kubecost_network_zone_egress_cost`
- **Description**: Cost per GiB for cross-availability-zone network egress
- **Unit**: USD per GiB

#### `oci_lens_cost_kubecost_network_region_egress_cost`
- **Description**: Cost per GiB for cross-region network egress
- **Unit**: USD per GiB

#### `oci_lens_cost_kubecost_network_internet_egress_cost`
- **Description**: Cost per GiB for internet network egress
- **Unit**: USD per GiB

#### `oci_lens_cost_kubecost_cluster_management_cost`
- **Description**: Hourly cluster management fee	
- **Unit**: USD per hour

#### `oci_lens_cost_kubecost_load_balancer_cost`
- **Description**: Hourly cost for load balancers
- **Unit**: USD per hour

---

## Additional Resources

- [OCI GPU Scanner OpenCost Fork](https://github.com/oci-ai-incubations/opencost) - OCI GPU Scanner specific custom pricing implementation
- [OCI GPU Scanner OpenCost Helm Chart](https://github.com/oci-ai-incubations/opencost-helm-chart) - OCI GPU Scanner specific deployment configuration
- [OpenCost Documentation](https://www.opencost.io/docs/) - OpenCost Official documentation


