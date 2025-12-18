# variables.tf

# variable "kubeconfig_path" {
#   type = string
# }

variable "namespace" {
  type    = string
  default = "lens"
}

variable "compartment_ocid" {
  description = "The OCID of the compartment"
  type = string
}

variable "region" {
  description = "The OCI region"
  type = string
}

variable "cluster_ocid" {
  description = "The OCID of the OKE cluster"
  type = string
}

variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type = string
}

variable "create_iam_policy" {
  type = bool
  default = false
}

variable "policy_name" {
  type = string
  default = "lens-backend-workload-policy"
}

variable "superuser_username" {
  description = "Username for the superuser of Lens API Backend"
  type = string
}

variable "superuser_password" {
  description = "Password for the superuser of Lens API Backend"
  type = string
  sensitive = true
}

variable "superuser_email" {
  description = "Email for the superuser of Lens API Backend"
  type = string
}

variable "grafana_admin_password" {
  description = "Password for the admin of Grafana"
  type = string
  sensitive = true
}

variable "ingress_domain" {
  description = "Domain for ingress. Empty string defaults to nip.io."
  type = string
  default = ""
}

variable "use_external_grafana" {
  description = "Use your own Grafana instance instead of deploying one."
  type = bool
  default = false
}

variable "grafana_url" {
  description = "URL of your existing Grafana instance."
  type = string
  default = ""
}

variable "grafana_api_token" {
  description = "API token for authenticating with your existing Grafana instance."
  type = string
  sensitive = true
  default = ""
}

variable "use_external_ingress" {
  description = "Use your own ingress controller and cert-manager instead of deploying them."
  type = bool
  default = false
}

variable "ingress_cert_manager_cluster_issuer" {
  description = "Name of your existing cert-manager ClusterIssuer for TLS certificate management."
  type = string
  default = ""
}

variable "ingress_class_name" {
  description = "Ingress class name for your existing ingress controller."
  type = string
  default = ""
}

variable "ingress_external_namespace" {
  description = "Namespace where your existing ingress controller service is deployed."
  type = string
  default = ""
}

variable "ingress_external_service_name" {
  description = "Service name of your existing ingress controller."
  type = string
  default = ""
}