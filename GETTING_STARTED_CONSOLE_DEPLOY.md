# Getting Started with OCI GPU Scanner Quickstart (COMING SOON)

**❗❗IMPORTANT: The instructions below are for creating to an existing OKE cluster. If you'd like to install OCI GPU Scanner standalone service, follow the steps here: [Install OCI GPU Scanner to an Existing OKE Cluster](./GETTING_STARTED_README.md)**

This product has 2 main components 

- **OCI GPU Scanner Control Plane** (one install per OKE cluster) 
- **OCI GPU Data Plane Plugin As Kubernetes DaemonSet** (runs on each monitored GPU compute OKE nodes) 

With control plane installation, you also have a choice to bring your own Prometheus server and Grafana server instead. 

## Install OCI GPU Scanner As part of existing Kubernetes cluster

Once the steps are finished you will have access to the below:

1. OCI GPU Scanner Control Plane to help manage and monitor GPU nodes or OKE clusters through UI. 
2. OCI GPU Scanner Control Plane REST API Backend to manage operations through REST. 
3. A dedicated OCI Scanner Prometheus server (open-source version) instance & prometheus push gateway.
4. A dedicated OCI Scanner Grafana (open-source version) for advanced monitoring, visualization and alerting.

---

## Prerequisites

- Kubernetes 1.26+
- Helm 3.0+
- (Optional) OCI Block Volume CSI driver for dynamic PVC provisioning

### Ingress and TLS Setup

The Helm chart automatically installs **ingress-nginx** and **cert-manager** for routing and TLS certificate management. Before proceeding with installation, please review the [Ingress and TLS Setup Prerequisites](INGRESS_AND_TLS_SETUP.md) to:
- Check for existing ingress/cert-manager infrastructure in your cluster
- Clean up any conflicts before installation
- Understand post-installation verification and troubleshooting

## Download the helm chart and unzip it into a directory called helm 

```
# Create the helm directory
mkdir -p helm

# Download the chart
curl -o corrino-lens-0.1.6-ba11a1d.tgz "https://objectstorage.us-ashburn-1.oraclecloud.com/p/HVqOasjp6KjQIiwYItUsJC8dmLLA4mJh9PxYZq3TMHxKPxocP4JPI8ZLUMyaCIH-/n/iduyx1qnmway/b/helm-charts/o/corrino-lens-0.1.6-ba11a1d.tgz"

# Extract to helm directory
tar -xzf corrino-lens-0.1.6-ba11a1d.tgz -C helm
```


## Workload Identity Configuration

The backend deployment is configured with a service account that enables workload identity access to OCI resources. This allows the application to authenticate with OCI services using the Kubernetes service account identity.

### Service Account Configuration

The Helm chart automatically creates a service account for the backend deployment with the following configuration:

```yaml
backend:
  serviceAccount:
    create: true
    name: "corrino-lens-backend-sa"
    automountToken: true
```

### Setting Up IAM Policy for Workload Identity

To grant the workload access to OCI resources, you need to create an IAM policy. Follow these steps:

1. **Get the required information:**
   - Cluster OCID: `{{ .Values.backend.okeClusterId }}`
   - Namespace: `lens` (or your deployment namespace)
   - Service Account: `corrino-lens-backend-sa`

2. **Create an IAM policy** in the OCI Console:
   - Navigate to **Identity & Security** > **Policies**
   - Create a new policy with the following statement:

```sql
Allow any-user to manage objects in tenancy where all {
  request.principal.type = 'workload',
  request.principal.namespace = 'lens',
  request.principal.service_account = 'corrino-lens-backend-sa',
  request.principal.cluster_id = '{{ .Values.backend.okeClusterId }}'
}
```

3. **For specific compartment access**, use this format:

```sql
Allow any-user to manage objects in compartment <compartment-id> where all {
  request.principal.type = 'workload',
  request.principal.namespace = 'lens',
  request.principal.service_account = 'corrino-lens-backend-sa',
  request.principal.cluster_id = '{{ .Values.backend.okeClusterId }}'
}
```

### Using Workload Identity in Application Code

The backend application can now use the OCI SDK with workload identity authentication. The service account token is automatically mounted and the application can authenticate without additional configuration.

For more information, see the [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm).

## GPU Scanner Custom Application Only

If you already have Prometheus Postgateway and Grafana running, login to existing OKE cluster where you would like to install this:

**Please make sure in this installation that VCNs have necessary firewall rules and DNS resolving ability for scanner portal to access the prometheus and grafana servers**

```bash
# Create namespace
kubectl create namespace lens

# Install only the Corrino Lens application
helm install lens ./helm -n lens \
  --set backend.prometheusPushgatewayUrl="http://YOUR_PUSHGATEWAY_IP_OR_SERVICE_NAME:9091" \
  --set backend.grafanaUrl="http://YOUR_GRAFANA_IPIP_OR_SERVICE_NAME:80" \
  --set backend.tenancyId="your-tenancy-id" \
  --set backend.regionName="your-region-name"
```

### Option 3: Manual Step-by-Step

```bash
# Create namespace
kubectl create namespace lens

# Install the chart
helm install lens ./helm -n lens
```

### Upgrade the chart
```bash
# Basic upgrade
helm upgrade lens ./helm -n lens

# Upgrade with custom monitoring URLs
helm upgrade lens ./helm -n lens \
  --set backend.prometheusPushgatewayUrl="http://YOUR_PUSHGATEWAY_IP:9091" \
  --set backend.grafanaUrl="http://YOUR_GRAFANA_IP:80" \
  --set backend.tenancyId="your-tenancy-id" \
  --set backend.regionName="your-region-name"
```

### Uninstall the chart
```bash
helm uninstall lens -n lens
```

**Note:** To completely remove all components including ingress-nginx, cert-manager, and related cluster-wide resources, see the complete cleanup instructions in the [Ingress and TLS Setup Guide](INGRESS_AND_TLS_SETUP.md#complete-cleanup).

## Configuration & Access To Control Plane

All configuration is managed via `values.yaml`.

### Key Sections in `values.yaml`

- `database`: PostgreSQL image, credentials, storage, and service port
- `backend`: Backend image, environment, and service configuration
- `frontend`: Frontend image, environment, and service configuration
- `monitoring`: External monitoring components configuration

## Finding Your Monitoring Service IPs

If you already have Prometheus Pushgateway and Grafana running, find their external IPs:

```bash
# Find Pushgateway IP
kubectl get svc -A | grep pushgateway

# Find Grafana IP  
kubectl get svc -A | grep grafana

# Or if they're in a specific namespace
kubectl get svc -n your-monitoring-namespace
```

Look for services with `LoadBalancer` type and note their external IPs.

#### Example
```yaml
database:
  image:
    repository: postgres
    tag: "13"
    pullPolicy: IfNotPresent
  postgresqlDatabase: ps_db
  postgresqlUsername: ps_user
  postgresqlPassword: CorrinoLens@2025!
  storageClassName: oci-bv
  storageSize: 10Gi
  servicePort: 5432

backend:
  image:
    repository: iad.ocir.io/iduyx1qnmway/corrino-lens-backend
    tag: latest
    pullPolicy: Always
  servicePort: 80
  containerPort: 5000
  # ...other backend environment variables...

frontend:
  port: 3000
  image:
    repository: iad.ocir.io/iduyx1qnmway/corrino-lens-portal
    tag: latest
    pullPolicy: Always
  replicaCount: 1
  env:
    NODE_ENV: "production"
  # resources, etc.

monitoring:
  # External monitoring components configuration
  pushgatewayService: "prometheus-pushgateway"
  pushgatewayPort: 9091
  grafanaService: "grafana"
  grafanaPort: 80
  externalUrls:
    grafana: "http://GRAFANA_EXTERNAL_IP:80"
    pushgateway: "http://PUSHGATEWAY_EXTERNAL_IP:9091"
```

## Service Discovery and API Wiring

- The backend and frontend services are named dynamically using Helm helpers, ensuring unique names per release.
- The frontend's `API_BASE_URL` is set automatically to point to the backend service **inside the cluster** using:
  ```yaml
  API_BASE_URL: "http://{{ include "corrino-lens.backendHost" . }}:{{ .Values.backend.servicePort }}"
  ```
- This ensures the frontend always talks to the correct backend, regardless of release name or namespace.

## Accessing the Application

### Port Forwarding (Recommended for Local Testing)
```bash
# Frontend
kubectl port-forward svc/lens-corrino-lens-frontend 8080:80 -n lens
# Access in browser: http://localhost:8080

# Backend
kubectl port-forward svc/lens-corrino-lens-backend 8081:80 -n lens
# Access in browser or via API: http://localhost:8081
# Or access directly via LoadBalancer IP: http://BACKEND_EXTERNAL_IP:80

# Postgres (psql)
kubectl port-forward svc/lens-corrino-lens-postgres-lb 5432:5432 -n lens
psql -h localhost -U ps_user -d ps_db
```

### Service Names
- Frontend: `lens-corrino-lens-frontend` (LoadBalancer)
- Backend: `lens-corrino-lens-backend` (LoadBalancer)
- Postgres: `lens-corrino-lens-postgres-lb` (LoadBalancer)
- Prometheus Pushgateway: `prometheus-pushgateway` (external chart)
- Grafana: `grafana` (external chart)

### External Access URLs
- Frontend: `http://EXTERNAL_IP:80` (IP shown after installation)
- Backend: `http://EXTERNAL_IP:80` (IP shown after installation)
- Postgres: `EXTERNAL_IP:5432` (IP shown after installation)
- Grafana: `http://EXTERNAL_IP:80` (IP shown after installation)
- Prometheus Pushgateway: `http://EXTERNAL_IP:9091` (IP shown after installation)

## Monitoring and Troubleshooting

### Check Deployment Status
```bash
kubectl get pods -n lens
kubectl get svc -n lens
kubectl get pvc -n lens
```

### Verify Monitoring Integration

If you're using existing monitoring components:

```bash
# Check if backend can reach your monitoring services
kubectl exec -it deployment/lens-corrino-lens-backend -n lens -- \
  curl -I http://YOUR_PUSHGATEWAY_IP:9091/-/healthy

kubectl exec -it deployment/lens-corrino-lens-backend -n lens -- \
  curl -I http://YOUR_GRAFANA_IP:80/api/health

# Check backend environment variables
kubectl exec -it deployment/lens-corrino-lens-backend -n lens -- env | grep -E "(PUSHGATEWAY|GRAFANA)"
```

### View Logs
```bash
# Frontend logs
kubectl logs -l app=lens-corrino-lens-frontend -n lens
# Backend logs
kubectl logs -l app=lens-corrino-lens-backend -n lens
```

### Check Events
```bash
kubectl get events -n lens
```

## Troubleshooting

### Pushgateway Service Type Issue

If you encounter an issue where the Prometheus Pushgateway service is created as `ClusterIP` instead of `LoadBalancer`, the installation script automatically handles this by patching the service. If you need to do this manually:

```bash
# Check current service type
kubectl get svc prometheus-prometheus-pushgateway -n lens

# Patch to LoadBalancer if needed
kubectl patch svc prometheus-prometheus-pushgateway -n lens -p '{"spec":{"type":"LoadBalancer"}}'

# Wait for external IP
kubectl get svc prometheus-prometheus-pushgateway -n lens -w
```

### Common Issues

1. **Services not getting external IPs**: Check if your cluster has a LoadBalancer controller installed
2. **Backend can't reach monitoring services**: Verify the external IPs are correct in the values file
3. **Pods not starting**: Check events with `kubectl get events -n lens`

## Customization

Override any value in `values.yaml` using `--set` or a custom values file:
```bash
helm install lens ./helm -n lens \
  --set frontend.replicaCount=3 \
  --set backend.image.tag=stable
```

## Architecture

The Helm chart deploys the following components:

1. **Frontend (Portal)**
   - React/Node.js application
   - Served on port 3000
   - Service for internal/external access

2. **Backend (Control Plane)**
   - Django application
   - Served on port 5000 (container), 80 (service)
   - External access via LoadBalancer service
   - Connects to Postgres
   - Configured with Prometheus Pushgateway and Grafana URLs

3. **Postgres Database**
   - Managed via StatefulSet/Deployment
   - Persistent storage via PVC
   - Service for backend connectivity

4. **ConfigMaps and Secrets**
   - All environment variables and sensitive data are managed via ConfigMaps and Kubernetes Secrets

## Monitoring Components

The application is designed to work with external monitoring components installed in the same namespace:

- **Prometheus Pushgateway**: Installed via `prometheus-community/prometheus-pushgateway` chart
- **Grafana**: Installed via `grafana/grafana` chart


### Step 1: Deploy OCI GPU Scanner Package (VCN + OKE + Scanner Application - Control Plane Components)

The quick start resource manager/terraform template installs everything in one deployment in your OCI tenancy. Below is the breakdown of the services deployed:

- **VCN** with proper networking and security for OKE cluster
- **OKE Cluster** with 3 VM Flex E3 instances (10 OCPU, 100GB each - recommended for servicing prometheus & grafana)
- **OCI GPU Scanner Application** including:
  - OCI GPU Scanner Portal (Custom Component)
  - OCI GPU Scanner Backend API (Custom Component)
  - Prometheus Server (open-source software)
  - Grafana Server (open-source software)
  - PostgreSQL Database (open-source software)
- **IAM Policies** automatically created for required permissions

**Note**: The stack automatically creates all necessary IAM policies for OCI GPU Scanner to function properly. If you want to learn more about the specific policies being created, check the [IAM policies documentation](https://docs.oracle.com/en-us/iaas/Content/Identity/policieshow/Policy_Basics.htm).

Use the button below to open Oracle Cloud's Resource Manager:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/gablyu-oci/oci-lens-quickstart-test/releases/download/v0.1.6/oci-lens-quickstart-v0.1.6.zip)

1. Click **Deploy to Oracle Cloud** above.
2. In **Create Stack**:
   - Click "I have reviewed and accept the Oracle Terms of Use".
   - Give your stack a **name** (e.g., _oci-lens-stack_) or leave as default.
   - Select the **compartment** where you want OCI GPU Scanner deployed.
   - Click **Next**.
   - Select the **region** where you want to deploy.
   - Configure the following parameters:
     - **Create IAM Policy**: Whether to create workload identity IAM policy for backend service account
     - **IAM Policy Name**: Name for the IAM policy if enabled (default: `corrino-lens-backend-workload-policy`)
3. Click **Next**, then **Create**, and finally choose **Run apply** to provision your complete OCI GPU Scanner environment.
4. Monitor the progress in **Resource Manager → Stacks**. Once the status is **Succeeded**, you have a fully functional OCI GPU Scanner deployment ready to use.

---

## Step 2: Access OCI GPU Scanner Portal

After successful deployment, you'll need to get the external IPs from your OKE cluster to access the services:

### Get Service URLs from OKE Cluster

1. **Go to your OKE Cluster** in the OCI Console
2. **Run the following command** to see all services and their external IPs:
   ```bash
   kubectl get svc -n lens
   ```
3. **Look for services with `EXTERNAL-IP`** - these are your LoadBalancer services

### Available Services

#### OCI GPU Scanner Portal
- **Purpose**: Main interface for OCI GPU Scanner functionality
- **Access**: `http://<EXTERNAL-IP>:8080` (where `<EXTERNAL-IP>` is the LoadBalancer IP for the corrino-lens service)
- **Features**: Deploy monitoring, view health check results, manage monitoring rings
- **Default Credentials**: Username: `admin`, Password: `supersecret`

#### Grafana
- **Purpose**: Advanced monitoring dashboards and alerting
- **Access**: `http://<EXTERNAL-IP>:80` (where `<EXTERNAL-IP>` is the LoadBalancer IP for the Grafana service)
- **Features**: Pre-configured dashboards for GPU monitoring, custom queries, alerting rules
- **Default Credentials**: Username: `admin`, Password: `admin123`

#### Prometheus
- **Purpose**: Metrics collection and storage
- **Access**: `http://<EXTERNAL-IP>:9090` (where `<EXTERNAL-IP>` is the LoadBalancer IP for the Prometheus service)
- **Features**: Metrics querying, data visualization, alerting configuration

#### Prometheus Pushgateway
- **Purpose**: Push metrics to Prometheus
- **Access**: `http://<EXTERNAL-IP>:9091` (where `<EXTERNAL-IP>` is the LoadBalancer IP for the Pushgateway service)

#### PostgreSQL
- **Purpose**: Database backend for OCI GPU Scanner
- **Access**: Internal to the cluster, not directly accessible from outside
- **Default Credentials**: Username: `postgres`, Password: `postgres123`

---

## Step 3: OCI GPU Data Plane Plugin installation on GPU Nodes

1. **Navigate to Dashboards**: Go to the dashboard section
2. **Go to Tab - OCI GPU Scanner Install Script**:
   - You can use the script there and deploy the oci-scanner plugin on to your gpus nodes manually. 
   - Embed them into a slurm script if you run a slurm cluster.
   - Use the kubernetes objects for the plugin under the `oci_scanner_plugin` folder for a Kubernetes cluster. Refer to [Readme](oci_scanner_plugin/README.md).
   - use the same scripts to be added as part of your new GPU compute deployments through cloud-init scripts.
---

## Step 4: Explore Monitoring Dashboards

1. **Navigate to Dashboards**: Go to the dashboard section
2. **View Available Dashboards**:
   - **Standalone Nodes**: Monitor individual GPU instances
   - **OKE Clusters**: Monitor Kubernetes cluster health
   - **Cluster Networks**: Monitor RDMA network performance
3. **Create Monitoring Rings**: Select specific resources to create custom monitoring groups
4. **Access Grafana**: Go to "View Dashboard" under the Grafana URL
5. **Log in to Grafana**: Use default credentials. Username: `admin`; Password: `admin123`
6. **Access Additional Features**:
   - **Custom Queries**: Use Prometheus queries to create custom visualizations
   - **Alerting**: Set up alerts for critical GPU or cluster issues

---

## Cleanup

You can remove all resources in **one step**:

1. **Destroy the OCI GPU Scanner Stack**
   - Go to **Resource Manager → Stacks** in the OCI Console.
   - Select your **OCI GPU Scanner stack**.
   - Click **Destroy**, confirm, and wait until the job succeeds.

This will remove:
- The OKE cluster and all nodes
- The VCN and networking components
- All OCI GPU Scanner application components
- Associated storage and IAM policies (if created)

Once the stack is destroyed, your tenancy will be free of any OCI GPU Scanner-related resources.


## Support

For issues and questions:
- GitHub: https://github.com/oci-ai-incubations/corrino-lens-devops
- Email: ritika.g.gupta@oracle.com 
