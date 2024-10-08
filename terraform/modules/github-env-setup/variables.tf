variable "repo_name" {
  type = string
  default = "anurags1040/self-gh-tf"
}

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


# variable "teams_config" {
#   description = "Configuration for GitHub teams and their permissions"
#   type = map(object({
#     description       = string
#     parent_team       = string # Parent team name, if it exists
#     repo_permission   = string # Permission level: 'pull', 'push', 'admin'
#     environment_only  = optional(string) # 'staging' or 'production' to limit scope, optional
#   }))
# }

# variable "target_environment" {
#   description = "The environment for which the team repository permissions should be applied"
#   type        = string
# }

# variable "team_members_config" {
#   description = "Mapping of GitHub teams to their respective members"
#   type = map(list(string))  # Map of teams to a list of GitHub usernames
# }