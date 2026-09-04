terraform {
  required_version = "~> 1.16.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7.0"
    }
  }
}

provider "github" {
  # This block is purposely empty
}
