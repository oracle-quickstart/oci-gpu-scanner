# OKE Cluster Information
output "cluster_id" { 
  value       = local.cluster_id
  description = "The OCID of the OKE cluster"
}

output "cluster_name" { 
  value       = var.create_new_cluster ? module.cluster[0].oke_cluster_name : data.oci_containerengine_cluster.existing_cluster[0].name
  description = "The name of the OKE cluster"
}

output "namespace_name" { 
  value = var.namespace 
  description = "The Kubernetes namespace where resources are deployed"
}

output "deployment_status" { 
  value       = var.create_new_cluster ? "OCI GPU Scanner deployment completed successfully on new cluster!" : "OCI GPU Scanner deployment completed successfully on existing cluster!"
  description = "Deployment status message"
}

# OCI GPU Scanner Portal Information
output "portal_url" {
  value       = module.app.frontend_ingress_host != "" ? "https://${module.app.frontend_ingress_host}" : "Ingress host not available yet"
  description = "OCI GPU Scanner Portal URL"
}

output "admin_username" {
  value       = module.app.superuser_username
  description = "Admin username for OCI GPU Scanner Portal"
}

output "admin_password" {
  value       = module.app.superuser_password
  description = "Admin password for OCI GPU Scanner Portal"
  sensitive   = true
}

# OCI GPU Scanner API Information
output "api_url" {
  value       = module.app.backend_ingress_host != "" ? "https://${module.app.backend_ingress_host}" : "Ingress host not available yet"
  description = "OCI GPU Scanner API URL"
}

# Grafana Information
output "grafana_url" {
  value       = module.app.grafana_ingress_host != "" ? "https://${module.app.grafana_ingress_host}" : "Ingress host not available yet"
  description = "Grafana Dashboard URL"
}

output "grafana_username" {
  value       = "admin"
  description = "Grafana username"
}

output "grafana_password" {
  value       = module.app.grafana_admin_password
  description = "Grafana admin password"
  sensitive   = true
}

# Prometheus Information
output "prometheus_url" {
  value       = module.app.prometheus_ingress_host != "" ? "https://${module.app.prometheus_ingress_host}" : "Ingress host not available yet"
  description = "Prometheus URL"
}

output "notes" {
  value = <<EOT
Deployment completed successfully!

To access your services:
1. Portal: ${module.app.frontend_ingress_host != "" ? "https://${module.app.frontend_ingress_host}" : "Run: kubectl get ingress -n ${var.namespace}"}
2. API: ${module.app.backend_ingress_host != "" ? "https://${module.app.backend_ingress_host}" : "Run: kubectl get ingress -n ${var.namespace}"}
3. Grafana: ${module.app.grafana_ingress_host != "" ? "https://${module.app.grafana_ingress_host}" : "Run: kubectl get ingress -n ${var.namespace}"}
4. Prometheus: ${module.app.prometheus_ingress_host != "" ? "https://${module.app.prometheus_ingress_host}" : "Run: kubectl get ingress -n ${var.namespace}"}

To view all ingress resources:
  kubectl get ingress -n ${var.namespace}
EOT
  description = "Post-deployment instructions"
}
