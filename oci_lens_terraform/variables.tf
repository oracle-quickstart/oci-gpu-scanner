# oci_lens_terraform/variables.tf
variable "tenancy_ocid"     { type = string }
variable "compartment_ocid" { type = string }
variable "region"           { type = string }

variable "create_new_cluster" {
  description = "Create a new OKE cluster. If false, use an existing cluster."
  type        = bool
  default     = true
}

variable "cluster_ocid" {
  description = "The OCID of an existing OKE cluster (required when create_new_cluster is false)"
  type        = string
  default     = ""
}

variable "namespace" {
  type    = string
  default = "lens"
}

variable "create_iam_policy" {
  description = "Create the workload Identity IAM policy (requires RM to have manage policies)."
  type        = bool
  default     = false
}

variable "policy_name" {
  description = "Name for the IAM policy if create_iam_policy is true."
  type        = string
  default     = "lens-backend-workload-policy"
}

variable "superuser_username" {
  description = "Username for OCI GPU Scanner portal and backend API"
  type        = string
  default     = "admin"
}

variable "superuser_password" {
  description = "Password for the superuser of OCI GPU Scanner portal and backend API"
  type        = string
  sensitive   = true
  default     = "supersecret"
}

variable "superuser_email" {
  description = "Email for the of OCI GPU Scanner portal and backend API"
  type        = string
  default     = "admin@oracle.com"
}

variable "grafana_admin_password" {
  description = "Password for the admin of Grafana"
  type        = string
  sensitive   = true
  default     = "admin123"
}

variable "skip_regions" {
  description = "Comma-separated list of OCI regions to skip during GPU scanning"
  type        = string
  default     = ""
}