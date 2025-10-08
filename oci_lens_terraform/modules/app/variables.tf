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