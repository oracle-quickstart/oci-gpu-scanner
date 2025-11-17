# Getting started with OCI GPU Scanner quickstart using resource manager

**❗❗Important: The instructions below are for creating a new standalone deployment. To install OCI GPU Scanner on an existing OKE cluster, please refer to the [Install OCI GPU Scanner to an Existing OKE Cluster](GETTING_STARTED_HELM_DEPLOY.md)**

## Solution Components

- **OCI GPU Scanner Control Plane:** Install one per tenancy.
- **OCI GPU Data Plane Plugin:** Runs on each monitored GPU compute machine.


## Installing OCI GPU Scanner as a Standalone Service

This guide walks you through installing and using OCI GPU Scanner in your OCI Tenancy.

The quick start resource manager/terraform template installs everything in one deployment in your OCI tenancy. Below is the breakdown of the services deployed:

- **VCN** with required networking and security for OKE.
- **OKE Cluster** with 3 VM Flex E3 instances (10 OCPU, 100GB each - recommended)
- **OCI GPU Scanner Application** including:
   - OCI GPU Scanner Portal (Control Plane/UI)
   - OCI GPU Scanner Backend API
   - Prometheus Server (metrics collection)
   - Grafana Server (dashboards and visualization)
   - PostgreSQL Database (internal use)
- **IAM Policies** required for the scanner (automatically created).
See the [Oracle IAM policies documentation for more information.](https://docs.oracle.com/en-us/iaas/Content/Identity/policieshow/Policy_Basics.htm).
The below policies are created
``` bash
"Allow any-user to manage instances in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",

"Allow any-user to read cluster-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",

"Allow any-user to read compute-management-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",

"Allow any-user to manage instance-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",

"Allow any-user to manage tag-namespaces in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",

"Allow any-user to manage tags in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }"
```

**NOTE**: OKE Node Problem Detector is not installed as part of the resource manager deployment. You can follow [these instructions](/OKE_NPD_DEPLOY.md) to deploy this feature on existing OKE clusters. 

## Ingress and TLS Setup

The deployment automatically installs **ingress-nginx** and **cert-manager** for routing and TLS certificate management. After deployment completes, refer to the [Ingress and TLS Setup Prerequisites](INGRESS_AND_TLS_SETUP.md) for:
- Post-installation verification steps
- Understanding the ingress architecture

### Step 1: Deploy OCI GPU Scanner Package

1. Click the **Deploy to Oracle Cloud** button below:

[![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?zipUrl=https://github.com/oracle-quickstart/oci-gpu-scanner/releases/latest/download/oci-gpu-scanner-deploy.zip)

1. In **Create Stack:**

1. Click **Deploy to Oracle Cloud** above.
2. In **Create Stack**:
   - Accept the Oracle Terms of Use.
   - Name your stack (e.g., oci-lens-stack) or use the default.- 
   - Select the desired compartment and region. 
   - Configure parameters:
      - **Create IAM Policy:** Enable if you wish to create the workload identity IAM policy for the backend service account.
      - **IAM Policy Name:** Default is `corrino-lens-backend-workload-policy`
      - **Ingress Domain:** (Optional) Custom domain for ingress. Leave empty to use `nip.io` wildcard DNS service (recommended for quick start, no DNS setup required). If you provide a custom domain, you must manually create DNS records. See [Custom Domain Configuration](INGRESS_AND_TLS_SETUP.md#custom-domain-configuration) for details.
      - **Superuser Username:** Username for the OCI GPU Scanner Portal (default: `admin`)
      - **Superuser Password:** Password for the OCI GPU Scanner Portal (default: `supersecret`) — **Recommended to change for production**
      - **Superuser Email:** Email address for the superuser account (default: `admin@oracle.com`)
      - **Grafana Admin Password:** Password for Grafana dashboard access (default: `admin123`) — **Recommended to change for production**
3. Click **Next**, then **Create**, and finally choose **Run apply** to provision the OCI GPU Scanner environment.
4. Monitor deployment progress in **Resource Manager → Stacks.** Once the status is Succeeded, the deployment is ready. Deployment may take up to 10 minutes. 

---

## Step 2: Access OCI GPU Scanner Portal

Access the OKE cluster using the credentials created for the new OKE cluster.

After connecting with OKE cluster run the below command
```kubectl get ingress -n lens```

Copy the HOSTS details for all the applications deployed by lens. e.g. lens.129.80.43.138.nip.io

**Note:** If you configured a custom domain during deployment, you need to manually create DNS records. See [Custom Domain Configuration](INGRESS_AND_TLS_SETUP.md#custom-domain-configuration) for detailed instructions.



## Step 3: Install GPU Data Plane Plugin on GPU Nodes

This step is only required on the GPU nodes or OKE clusters running GPU nodes:

1. **Navigate to Dashboards**: Go to the "OCI GPU Scanner Plugin Installation"
---
2. **For Standalone Nodes (non OKE)- Install details for standalone nodes**:
   - You can use the script there and deploy the oci-scanner plugin on to your gpus nodes manually. 
   - SSH into your GPU nodes and run the script
   - You can embed teh scripts into a slurm node deployment script if you run a slurm cluster.
   - use the same scripts to be added as part of your new GPU compute deployments through cloud-init scripts.
---
2. **For OKE based GPU nodes- Install details for OKE  cluster**:
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
5. **Log in to Grafana**: Use username `admin` with the Grafana admin password you configured during deployment (default: `admin123`)
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
- All OCI GPU Scanner application components (Frontend, Backend, Database)
- Ingress-nginx controller and associated LoadBalancer
- cert-manager and TLS certificates
- Associated storage and IAM policies (if created)

Once the stack is destroyed, your tenancy will be free of any OCI GPU Scanner-related resources.
