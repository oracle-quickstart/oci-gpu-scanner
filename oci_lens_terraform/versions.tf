# oci_lens_terraform/versions.tf
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci         = { source = "oracle/oci",           version = ">= 5.0.0" }
    kubernetes  = { source = "hashicorp/kubernetes", version = ">= 2.0.0" }
    helm        = { source = "hashicorp/helm",       version = "~> 2.12" }
    time        = { source = "hashicorp/time",       version = ">= 0.9.0" }
    local       = { source = "hashicorp/local",      version = ">= 2.0.0" }
    null        = { source = "hashicorp/null",       version = ">= 3.0.0" }
    random      = { source = "hashicorp/random",     version = ">= 3.0.0" }
  }
}
