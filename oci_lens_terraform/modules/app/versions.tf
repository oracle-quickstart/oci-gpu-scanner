# oci_lens_terraform/modules/app/versions.tf
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      configuration_aliases = [oci.home]   # for IAM writes only
    }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.27" }
    helm       = { source = "hashicorp/helm",       version = ">= 2.12, < 3.0.0" }
    random     = { source = "hashicorp/random",     version = ">= 3.6" }
    local      = { source = "hashicorp/local",      version = ">= 2.5" }
  }
}

