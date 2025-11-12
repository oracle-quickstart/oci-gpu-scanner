# oci_lens_terraform/modules/app/main.tf
# Namespace
resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "oci_identity_policy" "workload_identity_policy" {
  count = var.create_iam_policy ? 1 : 0
  provider = oci.home
  name           = var.policy_name
  description    = "Policy to allow lens-backend service account to manage resources"
  compartment_id = var.tenancy_ocid

  statements = [
    "Allow any-user to manage instances in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",
    "Allow any-user to read cluster-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",
    "Allow any-user to read compute-management-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",
    "Allow any-user to manage instance-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }"
  ]
}

resource "helm_release" "app" {
  name      = "lens"
  namespace = kubernetes_namespace.ns.metadata[0].name
  chart = "https://oci-ai-incubations.github.io/corrino-lens-devops/lens-0.1.10-20251031-2247.tgz"
  wait            = true
  timeout         = 1800
  atomic          = false
  cleanup_on_fail = false

  set {
    name = "backend.regionName"
    value = var.region
  }

  set {
    name = "backend.tenancyId"
    value = var.tenancy_ocid
  }

  set {
    name = "backend.superuser.username"
    value = var.superuser_username
  }

  set {
    name = "backend.superuser.password"
    value = var.superuser_password
  }

  set {
    name = "backend.superuser.email"
    value = var.superuser_email
  }

  set {
    name = "monitoring.grafanaAdminPassword"
    value = var.grafana_admin_password
  }

  set {
    name = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  set {
    name = "ingress.domain"
    value = var.ingress_domain != "" ? var.ingress_domain : "nip.io"
  }

  depends_on = [
    kubernetes_namespace.ns,
  ]
}

# Data sources to retrieve ingress information after deployment
data "kubernetes_ingress_v1" "frontend_ingress" {
  metadata {
    name      = "lens-frontend-ingress"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  depends_on = [helm_release.app]
}

data "kubernetes_ingress_v1" "backend_ingress" {
  metadata {
    name      = "lens-backend-ingress"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  depends_on = [helm_release.app]
}

data "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name      = "lens-grafana-ingress"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  depends_on = [helm_release.app]
}

data "kubernetes_ingress_v1" "prometheus_ingress" {
  metadata {
    name      = "lens-prometheus-ingress"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  depends_on = [helm_release.app]
}

# Data source to get the ingress-nginx LoadBalancer IP
data "kubernetes_service_v1" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  depends_on = [helm_release.app]
}

