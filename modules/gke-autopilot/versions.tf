terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.47.0, < 7.3"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.0"
    }
  }
}