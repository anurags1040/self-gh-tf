teams_config = {
  "members-all" = {
    description       = "Parent team with read-only permissions to all repositories"
    parent_team       = "" # No parent for main-team
    repo_permission   = "pull"
  },
  "contributors" = {
    description       = "Team for contributors with write permissions"
    parent_team       = "members-all"
    repo_permission   = "push"
  },
  "staging-deployers" = {
    description       = "Team for deploying to staging with admin permissions"
    parent_team       = "members-all"
    repo_permission   = "admin"
    environment_only  = "staging"
  },
  "prod-deployers" = {
    description       = "Team for deploying to production with admin permissions"
    parent_team       = "members-all"
    repo_permission   = "admin"
    environment_only  = "production"
  }
}

target_environment = "staging"  # Example of setting the target environment

# team_members_config = {
#   "members-all" = ["anurags1040"]
#   "contributors" = ["csykora-flexion"]
#   "staging-deployers" = ["csykora-sbx"]
#   "prod-deployers" = ["anurags1040"]
# }
