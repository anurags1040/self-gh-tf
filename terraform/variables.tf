variable "teams_config" {
  description = "Configuration for GitHub teams, their permissions, and repositories"
  type = object({
    teams = map(object({
      description  = string
      alias        = string
      parent       = optional(string)      # Parent team if applicable
      repositories = map(string)           # Map of repositories to permission levels (e.g., "first-repo" = "pull")
    }))
    members = map(object({
      teams    = list(string)              # List of teams the member belongs to (can use alias)
      is_admin = optional(bool)            # Optional flag for admin members
    }))
  })
}

variable "repository_names" {
  description = "List of GitHub repositories for team permissions"
  type        = map(string)
}

# variable "target_environment" {
#   description = "The environment for which the team repository permissions should be applied"
#   type        = string
#   default = "staging"
# }

variable "github_config" {
  description = "Configuration for GitHub repositories and their environments"
  type = object({
    repositories = map(object({
      environments = map(object({
        reviewers = list(string)
        branch_policies = object({
          protected_branches     = bool
          custom_branch_policies = bool
        })
        secrets = optional(map(object({
            value = string
        })), {})    
      }))
    }))
  })
}
