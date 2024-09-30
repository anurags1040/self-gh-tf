terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# provider "github" {
#   owner = var.github_config.repository_owner
# }

provider "github" {
  organization = "asharma-sbx"     # Reference the organization
}