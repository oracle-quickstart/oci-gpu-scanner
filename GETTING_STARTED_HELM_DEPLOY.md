# OCI GPU Scanner - Control Plane Helm Deployment

## Overview

**This guide covers Control Plane deployment only.**

For Data Plane plugin installation on GPU nodes, see [oci-gpu-scanner-plugin-helm](./helm/oci-gpu-scanner-plugin-helm/README.md).

### What This Deploys

- **Control Plane UI:** Web interface for managing and monitoring GPU nodes/clusters
- **REST API Backend:** Programmatic operations and management
- **Monitoring Stack:** Prometheus + Grafana (or integrate with your existing monitoring)

### Customization Options

This deployment supports:

- ✅ **Bring Your Own Monitoring:** Use existing Prometheus & Grafana instead of deploying new instances
- ✅ **Custom Domains:** Configure your own domain instead of default `nip.io`
- ✅ **Compartment Restrictions:** Limit OCI access to specific compartments
- ✅ **Resource Overrides:** Customize replicas, images, storage, and more via Helm values

---

## Quick Start Decision Tree

**Do you already have Prometheus and Grafana, and don't want to deploy new monitoring stacks?**

- **NO** → [Option 1: Full Installation](#option-1-full-installation-control-plane--monitoring-stack) (includes monitoring stack)
- **YES** → [Option 2: Control Plane Only](#option-2-control-plane-only-byo-monitoring) (BYO monitoring)

---

## Prerequisites

### System Requirements

- Kubernetes 1.26+
- Helm 3.0+
- Linux OS Machine
- OKE cluster with ≥2 CPU nodes
- (Optional) OCI Block Volume CSI driver for dynamic PVC provisioning

---

### 1. OCI IAM Policy Setup

The backend deployment uses a Kubernetes service account with workload identity to access OCI resources.

#### Service Account Details

- **Namespace:** `lens`
- **Service Account Name:** `corrino-lens-backend-sa`
- **Required Permissions:** Read access to `cluster-family` and `compute-management-family`

#### Create IAM Policy

**Note:** This step requires OCI tenancy-level permissions. Policies are always created in your OCI home region.

1. **Gather Required Information:**
   - `request.principal.cluster_id`: Your existing OKE cluster OCID (e.g., `ocid1.cluster.oc1.iad.aaaaaaaaa...`)
   - `request.principal.namespace`: `lens`
   - `request.principal.service_account`: `corrino-lens-backend-sa`

2. **Create Policy in OCI Console:**
   - Navigate to **Identity & Security** > **Policies**
   - Click **Create Policy**
   - **Name:** `oci-gpu-scanner-backend-access`
   - **Description:** Enable OCI GPU Scanner backend workload identity access
   - **Compartment:** Root compartment (or compartment where OKE cluster resides)
   - **Policy Builder:** Switch to **Manual Editor**

3. **Add Policy Statements:**

   **Option A: Tenancy-Level Access (Recommended)**
   ```sql
   Allow any-user to read instance-family in tenancy where all {
     request.principal.type = 'workload',
     request.principal.namespace = 'lens',
     request.principal.service_account = 'corrino-lens-backend-sa',
     request.principal.cluster_id = 'YOUR_OKE_CLUSTER_OCID'
   }

   Allow any-user to read compute-management-family in tenancy where all {
     request.principal.type = 'workload',
     request.principal.namespace = 'lens',
     request.principal.service_account = 'corrino-lens-backend-sa',
     request.principal.cluster_id = 'YOUR_OKE_CLUSTER_OCID'
   }
   ```

   **Option B: Compartment-Level Access (Restricted)**
   ```sql
   Allow any-user to read instance-family in compartment id 'YOUR_COMPARTMENT_OCID' where all {
     request.principal.type = 'workload',
     request.principal.namespace = 'lens',
     request.principal.service_account = 'corrino-lens-backend-sa',
     request.principal.cluster_id = 'YOUR_OKE_CLUSTER_OCID'
   }

   Allow any-user to read compute-management-family in compartment id 'YOUR_COMPARTMENT_OCID' where all {
     request.principal.type = 'workload',
     request.principal.namespace = 'lens',
     request.principal.service_account = 'corrino-lens-backend-sa',
     request.principal.cluster_id = 'YOUR_OKE_CLUSTER_OCID'
   }
   ```

   Replace `YOUR_OKE_CLUSTER_OCID` and `YOUR_COMPARTMENT_OCID` with your actual values.

📚 **Reference:** [OCI Workload Identity Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm)

---

### 2. Clone the Repository

Clone the OCI GPU Scanner repository and navigate to the root:

```bash
git clone https://github.com/oracle-quickstart/oci-gpu-scanner.git
cd oci-gpu-scanner/helm/oci-gpu-scanner-helm
```

The Helm chart is located at `./helm/oci-gpu-scanner-helm` relative to the repository root. All `helm` commands in this guide should be run from the repository root.

---

### 3. Create Kubernetes Secrets

All installation options require PostgreSQL and superuser credentials. **Run these commands before installation:**

```bash
# Create namespace
kubectl create namespace lens

# PostgreSQL credentials
export POSTGRES_USERNAME='your_secret_username'
export POSTGRES_PASSWORD='your_secret_password'

kubectl -n lens create secret generic lens-postgres-secret \
  --from-literal=postgres-user="$POSTGRES_USERNAME" \
  --from-literal=postgres-password="$POSTGRES_PASSWORD"

# Superuser credentials (for Control Plane UI/API access)
export SUPERUSER_USERNAME='your_superuser_username'
export SUPERUSER_EMAIL='superuser@email.com'
export SUPERUSER_PASSWORD='your_superuser_password'

kubectl -n lens create secret generic lens-backend-secret \
  --from-literal=superuser-username="$SUPERUSER_USERNAME" \
  --from-literal=superuser-email="$SUPERUSER_EMAIL" \
  --from-literal=superuser-password="$SUPERUSER_PASSWORD"
```

**For Option 2 only** (BYO Grafana), also create:

```bash
# Grafana API token (Option 2 only)
export GRAFANA_API_TOKEN='your_grafana_api_token'

kubectl -n lens create secret generic lens-grafana-secret \
  --from-literal=grafana-api-token="$GRAFANA_API_TOKEN"
```

**How to create a Grafana API token:**

1. Log in to your existing Grafana instance
2. Navigate to **Administration** → **Users and access** → **Service Accounts**
3. Click **Add service account**
   - Name: `oci-gpu-scanner` (or your preferred name)
   - Role: **Admin** (required for dashboard provisioning)
4. Click **Add service account token**
5. Copy the generated token (you won't be able to see it again)
6. Use this token as `GRAFANA_API_TOKEN` in the command above

📚 **Reference:** [Grafana Service Accounts Documentation](https://grafana.com/docs/grafana/latest/administration/service-accounts/)

---

## Installation Options

### Option 1: Full Installation (Control Plane + Monitoring Stack)

**What You Get:**
- ✅ Control Plane (UI + API)
- ✅ Prometheus + Pushgateway
- ✅ Grafana (open-source)

**Installation Command:**

```bash
helm install lens . -n lens --create-namespace \
  --set backend.tenancyId="YOUR_OCI_TENANCY_OCID" \
  --set backend.regionName="YOUR_OKE_REGION"
```

**Configuration Reference:**

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `backend.tenancyId` | ✅ | - | Your OCI tenancy OCID |
| `backend.regionName` | ✅ | - | OKE region (e.g., `us-ashburn-1`) |
| `backend.authorizedCompartments` | optional | (all) | Restrict to specific compartment OCID |
| `ingress.domain` | optional | `nip.io` | Custom domain (see [Custom Domain Setup](INGRESS_AND_TLS_SETUP.md)) |

**Note:** Grafana admin password is auto-generated during installation. See [Access Your Deployment](#2-access-your-deployment) for retrieval instructions.

**Example with Optional Flags:**

```bash
helm install lens . -n lens --create-namespace \
  --set backend.tenancyId="ocid1.tenancy.oc1..aaaaaaaa..." \
  --set backend.regionName="us-ashburn-1" \
  --set backend.authorizedCompartments="ocid1.compartment.oc1..aaaaaaaa..." \
  --set ingress.domain="gpu-scanner.example.com"
```

---

### Option 2: Control Plane Only (BYO Monitoring)

**Prerequisites:**
- ✅ Prometheus Pushgateway running (accessible URL)
- ✅ Grafana ≥10.4.8 running (accessible URL)
- ✅ Grafana API token with admin rights ([create in Grafana](https://grafana.com/docs/grafana/latest/administration/service-accounts/))
- ✅ VCN firewall rules allow Control Plane → Prometheus/Grafana
- ✅ DNS resolution between Control Plane and monitoring services

**What You Get:**
- ✅ Control Plane (UI + API)
- ✅ Integration with your existing Prometheus & Grafana

**Installation Command:**

```bash
helm install lens . -n lens --create-namespace \
  --set backend.prometheusPushgatewayUrl="http://YOUR_PUSHGATEWAY_IP:9091" \
  --set backend.prometheusUrl="http://YOUR_PROMETHEUS_IP:9090" \
  --set backend.grafanaUrl="http://YOUR_GRAFANA_IP:80" \
  --set prometheus.enabled=false \
  --set grafana.enabled=false \
  --set backend.tenancyId="YOUR_OCI_TENANCY_OCID" \
  --set backend.regionName="YOUR_OKE_REGION"
```

**Configuration Reference:**

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `backend.prometheusPushgatewayUrl` | ✅ | - | Your Pushgateway URL (e.g., `http://pushgateway.example.com:9091`) |
| `backend.prometheusUrl` | ✅ | - | Your Prometheus URL (e.g., `http://prometheus.example.com:9090`) |
| `backend.grafanaUrl` | ✅ | - | Your Grafana URL (e.g., `http://grafana.example.com:80`) |
| `prometheus.enabled` | ✅ | `true` | **Must set to `false`** |
| `grafana.enabled` | ✅ | `true` | **Must set to `false`** |
| `backend.tenancyId` | ✅ | - | Your OCI tenancy OCID |
| `backend.regionName` | ✅ | - | OKE region (e.g., `us-ashburn-1`) |
| `backend.authorizedCompartments` | optional | (all) | Restrict to specific compartment OCID |
| `ingress.domain` | optional | `nip.io` | Custom domain (see [Custom Domain Setup](INGRESS_AND_TLS_SETUP.md)) |

**Example with Optional Flags:**

```bash
helm install lens . -n lens --create-namespace \
  --set backend.prometheusPushgatewayUrl="http://10.0.1.50:9091" \
  --set backend.prometheusUrl="http://10.0.1.51:9090" \
  --set backend.grafanaUrl="http://10.0.1.52:80" \
  --set prometheus.enabled=false \
  --set grafana.enabled=false \
  --set backend.tenancyId="ocid1.tenancy.oc1..aaaaaaaa..." \
  --set backend.regionName="us-phoenix-1" \
  --set backend.authorizedCompartments="ocid1.compartment.oc1..aaaaaaaa..." \
  --set ingress.domain="gpu-scanner.mycompany.com"
```

---

## Post-Installation

### 1. Verify Installation

Check that all pods are running:

```bash
kubectl get pods -n lens
```

**Expected pods (Option 1 - Full Installation):**
- `lens-backend-*`
- `lens-frontend-*`
- `lens-postgres-*`
- `lens-prometheus-server-*`
- `lens-prometheus-pushgateway-*`
- `lens-grafana-*`

**Expected pods (Option 2 - BYO Monitoring):**
- `lens-backend-*`
- `lens-frontend-*`
- `lens-postgres-*`

All pods should show `Running` status. If not, check [Troubleshooting](#troubleshooting).

Reference screenshot:

![List of pods in lens namespace](/media/running-pods-success.png)

---

### 2. Access Your Deployment

Get the ingress URLs for your deployment:

```bash
kubectl get ingress -n lens
```

**Expected output:**

![List of services](/media/successful-services.png)

**Service Endpoints:**

| Service | URL Pattern | Default Credentials |
|---------|-------------|---------------------|
| Control Plane UI | `https://lens.<EXTERNAL_IP>.nip.io` | Username: `$SUPERUSER_USERNAME`<br>Password: `$SUPERUSER_PASSWORD` |
| API Backend | `https://api.<EXTERNAL_IP>.nip.io` | Same as UI |
| Grafana (Option 1) | `https://grafana.<EXTERNAL_IP>.nip.io` | Username: `admin`<br>Password: *See [Access Grafana](#access-grafana)* |
| Prometheus (Option 1) | `https://prometheus.<EXTERNAL_IP>.nip.io` | No authentication |
| Pushgateway (Option 1) | `https://pushgateway.<EXTERNAL_IP>.nip.io` | No authentication |

**Notes:**
- If using a custom domain, URLs will use your configured domain instead of `nip.io`
- Option 2 deployments use your existing Grafana/Prometheus URLs (not listed in ingress)

---

### 3. Next Steps

**Deploy Data Plane Plugin on GPU Nodes:**

To start monitoring GPU nodes, install the Data Plane plugin. See [oci-gpu-scanner-plugin-helm](./helm/oci-gpu-scanner-plugin-helm/README.md) for installation instructions.

The plugin can be installed on:
- Individual GPU instances
- OKE cluster GPU nodes (via DaemonSet)
- Slurm cluster nodes
- Cloud-init scripts for automated deployment

---

## Monitoring & Dashboards

### Access Grafana

**Option 1 (Deployed Grafana):**
- **URL:** `https://grafana.<EXTERNAL_IP>.nip.io` (or custom domain)
- **Username:** `admin`
- **Password:** Auto-generated during installation

Retrieve the auto-generated Grafana admin password:

```bash
kubectl get secret lens-grafana-secret -A -o name 2>/dev/null || \
  kubectl get secret lens-grafana-secret -n lens -o jsonpath='{.data.admin-password}' 2>/dev/null | base64 -d; echo
```

**Option 2 (BYO Grafana):**
- Use your existing Grafana URL
- Dashboards will be automatically provisioned via API

### Available Dashboards

1. **Standalone Nodes:** Monitor individual GPU instances (utilization, memory, temperature)
2. **OKE Clusters:** Monitor Kubernetes cluster health and GPU pod metrics
3. **Cluster Networks:** Monitor RDMA network performance and topology

### Creating Monitoring Rings

1. Navigate to the Control Plane UI
2. Go to **Dashboards** section
3. Select specific resources (nodes, clusters, networks)
4. Create custom monitoring groups ("rings")
5. View aggregated metrics in Grafana

### Advanced Features

- **Custom Queries:** Use Prometheus queries for custom visualizations
- **Alerting:** Configure alerts for GPU utilization, temperature, or cluster issues
- **Data Export:** Export metrics for external analysis

---

## Configuration Reference

### Advanced Customization

All configuration is managed via Helm values. Override any value using `--set` flags or a custom `values.yaml` file:

```bash
# Using --set flags
helm install lens . -n lens \
  --set frontend.replicaCount=3 \
  --set backend.image.tag=stable

# Using custom values file
helm install lens . -n lens -f custom-values.yaml
```

### Key Configuration Sections

| Section | Description |
|---------|-------------|
| `database` | PostgreSQL image, storage, service port |
| `backend` | Backend image, replicas, environment variables |
| `frontend` | Frontend image, replicas, service configuration |
| `monitoring` | Prometheus/Grafana configuration |
| `ingress` | Domain, TLS, and ingress controller settings |

For detailed configuration options, see the default `values.yaml` in the Helm chart.

### Custom Domain & TLS Setup

For production deployments with custom domains and TLS certificates, see:
- [Custom Domain Configuration](INGRESS_AND_TLS_SETUP.md#custom-domain-configuration)
- [TLS Certificate Setup](INGRESS_AND_TLS_SETUP.md#tls-setup)

---

## Troubleshooting

### Common Issues

#### 1. Services Not Getting External IPs

**Symptom:** `kubectl get svc -n lens` shows `<pending>` for `EXTERNAL-IP`

**Cause:** Cluster missing LoadBalancer controller

**Solution:**
- Verify LoadBalancer controller is installed: `kubectl get pods -n kube-system | grep cloud-controller`
- For OKE, ensure cluster has correct IAM policies for LoadBalancer provisioning

---

#### 2. Pushgateway Service Type Mismatch (Option 1)

**Symptom:** Prometheus Pushgateway created as `ClusterIP` instead of `LoadBalancer`

**Cause:** Helm chart default configuration issue

**Solution:** Patch the service manually:

```bash
# Check current service type
kubectl get svc lens-prometheus-pushgateway -n lens

# Patch to LoadBalancer
kubectl patch svc lens-prometheus-pushgateway -n lens -p '{"spec":{"type":"LoadBalancer"}}'

# Wait for external IP
kubectl get svc lens-prometheus-pushgateway -n lens -w
```

**Note:** Future Helm chart updates may automate this fix.

---

#### 3. Backend Can't Reach Monitoring Services (Option 2)

**Symptom:** Backend pod logs show connection errors to Prometheus/Grafana

**Cause:** Network connectivity or DNS resolution issues

**Solution:**

```bash
# Test connectivity from backend pod
kubectl exec -it deployment/lens-backend -n lens -- \
  curl -I http://YOUR_PUSHGATEWAY_IP:9091/-/healthy

kubectl exec -it deployment/lens-backend -n lens -- \
  curl -I http://YOUR_GRAFANA_IP:80/api/health

# Check backend environment variables
kubectl exec -it deployment/lens-backend -n lens -- \
  env | grep -E "(PUSHGATEWAY|GRAFANA|PROMETHEUS)"
```

**Fix checklist:**
- ✅ VCN security lists allow traffic from OKE subnet to monitoring services
- ✅ Network Security Groups (NSGs) permit required ports
- ✅ DNS resolution works (if using hostnames instead of IPs)
- ✅ Monitoring services are running and accessible

---

#### 4. Pods Not Starting

**Symptom:** Pods stuck in `Pending`, `CrashLoopBackOff`, or `Error` state

**Diagnosis:**

```bash
# Check pod status
kubectl get pods -n lens

# Describe problematic pod
kubectl describe pod <POD_NAME> -n lens

# Check pod logs
kubectl logs <POD_NAME> -n lens

# Check events
kubectl get events -n lens --sort-by='.lastTimestamp'
```

**Common causes:**
- Missing secrets (check Prerequisites section)
- Insufficient cluster resources (CPU/memory)
- Image pull errors (check image registry access)
- PVC provisioning failures (check StorageClass configuration)

---

### Diagnostic Commands

```bash
# Overall cluster health
kubectl get pods -n lens
kubectl get svc -n lens
kubectl get ingress -n lens
kubectl get pvc -n lens

# Pod logs
kubectl logs -l app=lens-frontend -n lens
kubectl logs -l app=lens-backend -n lens
kubectl logs -l app=lens-postgres -n lens

# Events timeline
kubectl get events -n lens --sort-by='.lastTimestamp'

# Resource usage
kubectl top pods -n lens
kubectl top nodes
```

---

## Cleanup

### Uninstall Control Plane

Remove all Control Plane resources with a single command:

```bash
helm uninstall lens -n lens
```

**Optional:** Delete the namespace (removes all secrets and PVCs):

```bash
kubectl delete namespace lens
```

⚠️ **Warning:** Deleting the namespace will permanently remove all data, including PostgreSQL databases and monitoring history.

---

### Uninstall Data Plane Plugin

For Data Plane plugin cleanup on GPU nodes, see [oci-gpu-scanner-plugin-helm](./helm/oci-gpu-scanner-plugin-helm/README.md).

---

## Additional Resources

- [Data Plane Plugin Installation](./helm/oci-gpu-scanner-plugin-helm/README.md)
- [Custom Domain & TLS Setup](INGRESS_AND_TLS_SETUP.md)
- [OCI Workload Identity Documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm)
- [Grafana Service Accounts](https://grafana.com/docs/grafana/latest/administration/service-accounts/)
