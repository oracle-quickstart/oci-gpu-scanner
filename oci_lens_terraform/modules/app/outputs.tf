# Outputs for the OCI Lens deployment

output "policy_ocid" {
  description = "The OCID of the created workload identity policy"
  value       = var.create_iam_policy ? oci_identity_policy.workload_identity_policy[0].id : null
}

output "policy_name" {
  description = "The name of the created workload identity policy"
  value       = var.create_iam_policy ? oci_identity_policy.workload_identity_policy[0].name : null
}

output "policy_created" {
  description = "Whether the IAM policy was created by this module."
  value       = var.create_iam_policy
}

output "namespace_name" {
  description = "The Kubernetes namespace where resources are deployed"
  value       = kubernetes_namespace.ns.metadata[0].name
}

output "app_service_name" {
  description = "The main application service name"
  value       = helm_release.app.name
}

output "superuser_username" {
  description = "The admin username for OCI GPU Scanner Portal"
  value       = var.superuser_username
}

output "superuser_password" {
  description = "The admin password for OCI GPU Scanner Portal"
  value       = var.superuser_password
  sensitive   = true
}

output "grafana_admin_password" {
  description = "The Grafana admin password"
  value       = var.grafana_admin_password
  sensitive   = true
}

output "frontend_ingress_host" {
  description = "The ingress host for the OCI GPU Scanner Portal (frontend)"
  value       = try(data.kubernetes_ingress_v1.frontend_ingress.spec[0].rule[0].host, "")
}

output "backend_ingress_host" {
  description = "The ingress host for the OCI GPU Scanner API (backend)"
  value       = try(data.kubernetes_ingress_v1.backend_ingress.spec[0].rule[0].host, "")
}

output "grafana_ingress_host" {
  description = "The ingress host for Grafana"
  value       = try(data.kubernetes_ingress_v1.grafana_ingress.spec[0].rule[0].host, "")
}

output "prometheus_ingress_host" {
  description = "The ingress host for Prometheus"
  value       = try(data.kubernetes_ingress_v1.prometheus_ingress.spec[0].rule[0].host, "")
}

output "ingress_nginx_loadbalancer_ip" {
  description = "The external LoadBalancer IP for the ingress-nginx controller"
  value       = try(data.kubernetes_service_v1.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].ip, "")
}

output "ingress_nginx_loadbalancer_hostname" {
  description = "The external LoadBalancer hostname for the ingress-nginx controller"
  value       = try(data.kubernetes_service_v1.ingress_nginx_controller.status[0].load_balancer[0].ingress[0].hostname, "")
}
