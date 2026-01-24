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
    "Allow any-user to manage instance-family in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",
    "Allow any-user to manage tag-namespaces in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }",
    "Allow any-user to manage tags in tenancy where all { request.principal.type = 'workload', request.principal.namespace = 'lens', request.principal.service_account = 'corrino-lens-backend-sa', request.principal.cluster_id = '${var.cluster_ocid}' }"
  ]
}

resource "helm_release" "app" {
  name      = "lens"
  namespace = kubernetes_namespace.ns.metadata[0].name
  chart = "https://oci-ai-incubations.github.io/corrino-lens-devops/lens-0.1.16-20260124-0622.tgz"
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
    name  = "backend.authorizedCompartments"
    value = var.authorized_compartments
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

  # External Grafana configuration
  dynamic "set" {
    for_each = var.use_external_grafana ? [1] : []
    content {
      name  = "grafana.enabled"
      value = "false"
    }
  }

  dynamic "set" {
    for_each = var.use_external_grafana && var.grafana_url != "" ? [1] : []
    content {
      name  = "backend.grafanaUrl"
      value = var.grafana_url
    }
  }

  dynamic "set" {
    for_each = var.use_external_grafana && var.grafana_api_token != "" ? [1] : []
    content {
      name  = "backend.grafanaApiToken"
      value = var.grafana_api_token
    }
  }

  # External Ingress and Cert-Manager configuration
  dynamic "set" {
    for_each = var.use_external_ingress ? [1] : []
    content {
      name  = "cert-manager.enabled"
      value = "false"
    }
  }

  dynamic "set" {
    for_each = var.use_external_ingress ? [1] : []
    content {
      name  = "ingress-nginx.enabled"
      value = "false"
    }
  }

  dynamic "set" {
    for_each = var.use_external_ingress && var.ingress_cert_manager_cluster_issuer != "" ? [1] : []
    content {
      name  = "ingress.certManager.clusterIssuer"
      value = var.ingress_cert_manager_cluster_issuer
    }
  }

  dynamic "set" {
    for_each = var.use_external_ingress && var.ingress_class_name != "" ? [1] : []
    content {
      name  = "ingress.className"
      value = var.ingress_class_name
    }
  }

  dynamic "set" {
    for_each = var.use_external_ingress && var.ingress_external_namespace != "" ? [1] : []
    content {
      name  = "ingress.external.namespace"
      value = var.ingress_external_namespace
    }
  }

  dynamic "set" {
    for_each = var.use_external_ingress && var.ingress_external_service_name != "" ? [1] : []
    content {
      name  = "ingress.external.serviceName"
      value = var.ingress_external_service_name
    }
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
  count = var.use_external_grafana ? 0 : 1

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
    name      = var.use_external_ingress ? var.ingress_external_service_name : "${helm_release.app.name}-ingress-nginx-controller"
    namespace = var.use_external_ingress ? var.ingress_external_namespace    : kubernetes_namespace.ns.metadata[0].name
  }
  depends_on = [helm_release.app]
}

