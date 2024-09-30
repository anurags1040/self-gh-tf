# variable "repo_name" {
#   type = string
#   default = "anurags1040/self-gh-tf"
# }

# variable "github_config" {
#   description = "Configuration for GitHub repositories and their environments"
#   type = object({
#     repositories = map(object({
#       environments = map(object({
#         reviewers = list(string)
#         branch_policies = object({
#           protected_branches     = bool
#           custom_branch_policies = bool
#         })
#         secrets = optional(map(object({
#             value = string
#         })), {})    
#       }))
#     }))
#   })
# }

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
}

variable "repository_names" {
  description = "The list of GitHub repositories to which teams will be assigned."
  type        = map(string)
}

# variable "team_members_config" {
#   description = "Mapping of GitHub teams to their respective members"
#   type = map(list(string))  # Map of teams to a list of GitHub usernames
# }