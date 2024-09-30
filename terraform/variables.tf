variable "teams_config" {
  description = "Configuration for GitHub teams and their permissions"
  type = map(object({
    description       = string
    parent_team       = string # Parent team name, if it exists
    repo_permission   = string # Permission level: 'pull', 'push', 'admin'
    environment_only  = optional(string) # 'staging' or 'production' to limit scope, optional
  }))
}

variable "target_environment" {
  description = "The environment for which the team repository permissions should be applied"
  type        = string
  default = "staging"
}

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
