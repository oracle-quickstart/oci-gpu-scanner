# Deploy OCI GPU Scanner solution through HELM Quickstart 

**❗❗IMPORTANT: The instructions below are for deploying to an existing OKE cluster. If you'd like to install OCI GPU Scanner solution as a standalone service, follow the steps here: [Install OCI GPU Scanner to an Existing OKE Cluster](./GETTING_STARTED_README.md)**

This product has 2 main components and installation steps

- [**Step 1: OCI GPU Scanner Control Plane Installation**](#step1-install-oci-gpu-scanner-control-plane-as-part-of-existing-kubernetes-cluster) (one install per OKE cluster) 
- [**Step 2: OCI GPU Data Plane Plugin As Kubernetes DaemonSet**](#step-2-oci-gpu-data-plane-plugin-installation-on-gpu-nodes) (runs on each monitored GPU compute OKE nodes. Can be added to any other OKE cluster running GPU nodes) 

## Prerequisites

- Kubernetes 1.26+
- Helm 3.0+
- (Optional) OCI Block Volume CSI driver for dynamic PVC provisioning
- Linux OS Machine
- An OKE cluster with at least 2 CPU nodes

### Pre-req Step 1: Create workload identity configuration policy

The backend deployment is configured with a service account that enables workload identity access to OCI resources. This allows the application to authenticate with OCI services using the Kubernetes service account identity.

#### Service Account Configuration

**NOTE:** This step requires you to have enough OCI tenancy level permissions to create a policy. Policies are always created in your OCI home region. 

The helm deployments create a name below that needs to be used when a policy is created

```yaml
name: "corrino-lens-backend-sa"
```

Follow [these instructions](https://docs.oracle.com/en-us/iaas/Content/Identity/policymgmt/managingpolicies_topic-To_create_a_policy.htm) to get to policy manager in your OCI console. 

Get the following details before you can start creating policies:

1. **Get the required information:**
   - **request.principal.cluster_id**: `this is your existing OKE cluster OCID e.g ocid1.cluster.oc1.iad.aaaaaaaaalwej3x7nlecvak2z2psrduvqo6mqkjg7er3aolnmcuvyljsqtva `
   - **request.principal.namespace**: `lens` (or your deployment namespace if you changed it from default install)
   - **request.principal.service_account**: `corrino-lens-backend-sa`

2. **Create an IAM policy to access all resources in the tenancy (recommended)** in the OCI Console:
   - Navigate to **Identity & Security** > **Policies**
   - Create a new policy with the following statement:

Type the name as "OCI-gpu-scanner-backend-access". Add required description. Choose root compartment or a compartment where your existing OKE cluster is installed. 

Choose "Manual Editor" and add the below statements

```sql
Allow any-user to manage instances in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '<existingOKEclusterID>' }

Allow any-user to read cluster-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = 'existingOKEclusterID' }

Allow any-user to read compute-management-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = 'existingOKEclusterID' }

Allow any-user to manage instance-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = 'existingOKEclusterID' }

```

The backend application can now use the OCI SDK with workload identity authentication. The service account token is automatically mounted and the application can authenticate without additional configuration.

For more information, see the [Oracle Cloud Infrastructure documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contenggrantingworkloadaccesstoresources.htm).


### Pre-req Step 2: Download the helm chart into your deployment environment
Both installation use helm charts for installation. Please download these charts to your deployment CLI environment. 

``` bash
helm repo add lens https://oci-ai-incubations.github.io/corrino-lens-devops/
helm repo add oci-ai-incubations https://oci-ai-incubations.github.io/corrino-lens-devops/
helm repo update
```

## Step 1: Install OCI GPU Scanner control plane as part of existing Kubernetes cluster

Once the steps are finished you will have access to the below:

1. OCI GPU Scanner Control Plane to help manage and monitor GPU nodes or OKE clusters through UI. 
2. OCI GPU Scanner Control Plane REST API Backend to manage operations through REST. 
3. A dedicated OCI Scanner Prometheus server (open-source version) instance & prometheus push gateway.
4. A dedicated OCI Scanner Grafana (open-source version) for advanced monitoring, visualization and alerting.

With control plane installation, you also have a choice to bring your own Prometheus server and Grafana server instead. You have two options to install the control plane

1. [Option 1: Install all dependency services for control plane to work e.g Prometheus & Grafana in this cluster](#option-1-install-all-the-control-plane-components-and-dependencies-to-existing-oke-cluster)
2. [Option 2: Install only control plane components and use your existing Grafana & Prometheus](#option-2-install-control-plane-with-your-existing-grafana--prometheus-to-existing-oke-cluster)
---

### Option 1: Install all the control plane components and dependencies to existing OKE cluster

Login to your existing OKE cluster where you would like to deploy. Run the below  command. Fill in all the requited placeholder details.

``` bash
helm search repo lens
helm search repo oci-ai-incubations
helm install lens oci-ai-incubations/lens -n lens --create-namespace \
  --set backend.superuser.username="username for API & control plane e.g. admin" \
  --set backend.superuser.email="your email" \
  --set backend.superuser.password="access password for API & control plane" \
  --set grafana.adminPassword="access password for grafana portal. User name is admin by default"\
  --set monitoring.grafanaAdminPassword="password" \
  --set backend.tenancyId="your-oci-tenancy-id" \
  --set backend.regionName="your-oke-region-name"
```

**Optional: Custom Domain Configuration**

By default, the deployment uses `nip.io` for ingress (no DNS setup required). To use your own domain, add `--set ingress.domain="your-domain"` to the helm command above.

For detailed instructions on custom domain setup and required DNS records, see [Custom Domain Configuration](INGRESS_AND_TLS_SETUP.md#custom-domain-configuration).

### OPTION 2: Install control plane with your existing grafana & prometheus to existing OKE cluster

If you already have Prometheus Postgateway and Grafana running, login to existing OKE cluster where you would like to install this:

**Please make sure in this installation that VCNs have necessary firewall rules and DNS resolving ability for scanner portal to access the prometheus and grafana servers**

```bash

helm repo update
helm search repo oci-ai-incubations
helm install lens oci-ai-incubations/lens -n lens --create-namespace \
  --set backend.prometheusPushgatewayUrl="http://YOUR_PUSHGATEWAY_IP_OR_SERVICE_NAME:9091" \
  --set backend.grafanaUrl="http://YOUR_GRAFANA_IPIP_OR_SERVICE_NAME:80" \
  --set monitoring.grafanaAdminPassword="password" \
  --set grafana.adminPassword="password" \
  --set backend.tenancyId="your-oci-tenancy-id" \
  --set backend.regionName="your-oke-region-name" \
  --set backend.superuser.username="username for API & control plane e.g. admin" \
  --set backend.superuser.email="your email" \
  --set backend.superuser.password="access password for API & control plane" \
  --set grafana.adminPassword="access password for grafana portal. User name is admin by default"
```

**Optional: Custom Domain Configuration**

By default, the deployment uses `nip.io` for ingress (no DNS setup required). To use your own domain, add `--set ingress.domain="your-domain"` to the helm command above.

For detailed instructions on custom domain setup and required DNS records, see [Custom Domain Configuration](INGRESS_AND_TLS_SETUP.md#custom-domain-configuration).

## Verify for successful install

Once the installation is complete you should see the following pods in the "lens" namespace. If you don't please uninstall and reinstall or check the helm install events/logs. 

![List of pods in lens namespace](/media/running-pods-success.png)


## Configuration and access to configuration values

All configuration is managed via `values.yaml`.

### Key Sections in `values.yaml`

- `database`: PostgreSQL image, credentials, storage, and service port
- `backend`: Backend image, environment, and service configuration
- `frontend`: Frontend image, environment, and service configuration
- `monitoring`: External monitoring components configuration

## Finding your application URLs

If you already have Prometheus Pushgateway and Grafana running, find their external IPs:

```bash
kubectl get ingress-n lens
```

You should the below response with a list of public URLs for your deployments.

![List of services](/media//successful-services.png)

You can use these URL'S to access portal, API backend and Grafana/Prometheus instance. Use the password created during helm install phases. 

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


## Step 2: OCI GPU Data Plane Plugin installation on GPU Nodes

**NOTE** : Running data control plane plugin as a Kubernetes native plugin running daemon sets for [AMD and Nvidia  nodes can be found here](./oci-scanner-plugin-helm/README.md). Supported GPUs are: MI300x, MI355x, A10, H100 and B200.

1. **Navigate to Dashboards**: Go to the dashboard section of the OCI GPU Scanner Portal
2. **Go to Tab - OCI GPU Scanner Install Script**:
   - You can use the script there and deploy the oci-scanner plugin on to your gpus nodes manually (works on Ubuntu OS based GPU nodes). 
   - Embed them into a slurm script if you run a slurm cluster.
   - Use the same scripts to be added as part of your new GPU compute deployments through cloud-init scripts.

  Example script:

  ```bash
  chdir /home/ubuntu/
mkdir "$(hostname)"
cd "$(hostname)"
curl -X GET https://objectstorage.us-ashburn-1.oraclecloud.com/p/N6955_gYqc8g04xQLQkWyxHumraL_hy6qIxHR6Hd4H69ZOf8mQJFxN7-M-TNQOlJ/n/iduyx1qnmway/b/bucket-corrino-lens-dev/o/oci_plugin.tar.gz --output oci_plugin.tar.gz
tar -xzvf oci_plugin.tar.gz
cd oci_lens_plugin
export PUSH_GATEWAY="https://pushgateway.132.226.100.100.nip.io/"
export OCI_PAR_R="https://objectstorage.us-ashburn-1.oraclecloud.com/p/YmY6NBiA5VSkxVAoymx8FhZNfiFGDq9Gdqt0Q5G7e-CQsjDjnVWslylOSsIRuO2b/n/iduyx1qnmway/b/bucket-corrino-lens-dev/o/oci_lens_plugin"
export OCI_LENS_CP="http://api.100.100.100.nip.io"
export CP_AUTH_TOKEN="ad37cf7d9bcdd520d27c4va06eae5a3bc15a06e911bc0"
chmod -R +x *
./run.sh
  ```
---

## Step 3: Explore Monitoring Dashboards

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

You can remove all control plane resources in **one step**:

### Uninstall the control plane components from OKE cluster 

```bash
helm uninstall lens -n lens
```

### Uninstall the data plane components installed as system services (per GPU node)

```bash
cd /home/ubuntu/$(hostname)/oci-lens-plugin/
./uninstall 
cd ..
rm -rf *
cd ..
rmdir  $(hostname)

```

Once the stack is destroyed, your OKE cluster will be free of any OCI GPU Scanner-related resources including the GPU monitored nodes.