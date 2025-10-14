#############################################
# oci_lens_terraform/main.tf — Root wrapper (ORM)
#############################################

# --- Determine the actual cluster ID to use ---
locals {
  cluster_id = var.create_new_cluster ? module.cluster[0].oke_cluster_id : var.cluster_ocid
}

# --- User-selected region provider (default) ---
provider "oci" {
  region = var.region
}

# --- Discover true home region & configure alias ---
data "oci_identity_tenancy" "this" {
  tenancy_id = var.tenancy_ocid
}

data "oci_identity_regions" "all" {}

# Map home region key -> name
locals {
  home_region_name = one(
    [for r in data.oci_identity_regions.all.regions : r.name
      if r.key == data.oci_identity_tenancy.this.home_region_key]
  )
}

provider "oci" {
  alias  = "home"
  region = local.home_region_name
}

provider "oci" {
  alias  = "current_region"
  region = var.region
}

# --- Create OKE + networking (only when create_new_cluster is true) ---
module "cluster" {
  count  = var.create_new_cluster ? 1 : 0
  source = "./modules/cluster"

  providers = {
    oci                = oci
    oci.current_region = oci.current_region
  }

  tenancy_ocid     = var.tenancy_ocid
  compartment_ocid = var.compartment_ocid
  region           = var.region
}

# --- Get existing cluster information (only when create_new_cluster is false) ---
data "oci_containerengine_cluster" "existing_cluster" {
  count      = var.create_new_cluster ? 0 : 1
  cluster_id = var.cluster_ocid
}

# --- Kubeconfig (token auth) for the cluster ---
data "oci_containerengine_cluster_kube_config" "kube" {
  cluster_id    = local.cluster_id
  endpoint      = "PUBLIC_ENDPOINT"
  token_version = "2.0.0"
}

locals {
  kube          = yamldecode(data.oci_containerengine_cluster_kube_config.kube.content)
  kube_host     = local.kube["clusters"][0]["cluster"]["server"]
  kube_ca_b64   = local.kube["clusters"][0]["cluster"]["certificate-authority-data"]
  kube_token    = try(local.kube["users"][0]["user"]["token"], null)
}

# --- Providers for Kubernetes & Helm ---
provider "kubernetes" {
  host                   = local.kube_host
  cluster_ca_certificate = base64decode(local.kube_ca_b64)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", var.region]
    command     = "oci"
  }
}

provider "helm" {
  kubernetes {
    host                   = local.kube_host
    cluster_ca_certificate = base64decode(local.kube_ca_b64)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", local.cluster_id, "--region", var.region]
      command     = "oci"
    }
  }
}

# --- Small settle time to let LBs/controllers come up (only for new clusters) ---
resource "time_sleep" "after_cluster" {
  count           = var.create_new_cluster ? 1 : 0
  depends_on      = [module.cluster]
  create_duration = "60s"
}

# --- Save kubeconfig for convenience (optional) ---
resource "local_file" "kubeconfig" {
  content              = data.oci_containerengine_cluster_kube_config.kube.content
  filename             = "${path.module}/generated/kubeconfig"
  directory_permission = "0755"
  file_permission      = "0600"
  depends_on           = [time_sleep.after_cluster]
}

# --- App stack (Lens chart) ---
module "app" {
  source = "./modules/app"

  providers = {
    oci      = oci
    oci.home = oci.home
  }

  namespace         = var.namespace
  compartment_ocid  = var.compartment_ocid
  region            = var.region
  cluster_ocid      = local.cluster_id
  tenancy_ocid      = var.tenancy_ocid
  create_iam_policy = var.create_iam_policy
  policy_name       = var.policy_name
  superuser_username = var.superuser_username
  superuser_password = var.superuser_password
  superuser_email    = var.superuser_email
  grafana_admin_password = var.grafana_admin_password
  skip_regions      = var.skip_regions

  # wait for cluster (if new cluster was created)
  depends_on = [time_sleep.after_cluster]
}
