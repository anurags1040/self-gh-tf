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
    repositories = optional(map(object({
      environments = optional(map(object({
        reviewers = optional(list(string))
        branch_policies = optional(object({
          protected_branches     = optional(bool)
          custom_branch_policies = optional(bool)
          rules = optional(map(object({
            block_deletions     = optional(bool)
            block_force_pushes  = optional(bool)
            required_approvals  = optional(number)
            dismiss_stale_reviews = optional(bool)
            require_up_to_date_branch = optional(bool)
            require_code_owner_reviews = optional(bool)
            required_status_checks = optional(list(string))
            strict_status_checks = optional(bool)
            approvals_reset_on_source_change = optional(bool)
            reset_approvals_if_diff_changes = optional(bool)
            prevent_merge_with_unresolved_tasks = optional(bool)
            require_last_push_approval = optional(bool)
            allow_merge_with_unresolved_checks = optional(bool)
            restrict_pushes = optional(bool)
            push_restrictions = optional(list(string))
            status_checks = optional(list(string))
          })))
        }))
      })))
      branches = optional(map(object({
        required_approving_review_count = optional(number)
        dismiss_stale_reviews = optional(bool)
        require_up_to_date_branch = optional(bool)
        require_code_owner_reviews = optional(bool)
        required_status_checks = optional(list(string))
        strict_status_checks = optional(bool)
        approvals_reset_on_source_change = optional(bool)
        reset_approvals_if_diff_changes = optional(bool)
        prevent_merge_with_unresolved_tasks = optional(bool)
        require_last_push_approval = optional(bool)
        allow_merge_with_unresolved_checks = optional(bool)
        restrict_pushes = optional(bool)
      })))
    })))
  })
  default = {}
}


