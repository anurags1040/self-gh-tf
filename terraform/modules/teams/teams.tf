# Create teams dynamically
resource "github_team" "teams" {
  for_each = var.teams_config

  name        = each.key
  description = each.value.description
  privacy     = "closed"
  
  # Set parent team if it exists
  parent_team_id = try(github_team.teams[each.value.parent_team].id, null)
}

# Assign repository permissions dynamically to teams
resource "github_team_repository" "team_repo_permissions" {
  for_each = {
    for team_name, team_config in var.teams_config : 
    team_name => {
      team_id         = github_team.teams[team_name].id
      permission      = team_config.repo_permission
      environment_only = lookup(team_config, "environment_only", null) # Optional field
    }
    # Filter out entries if 'environment_only' is specified and doesn't match the intended environment
    if lookup(team_config, "environment_only", null) == null
      || lookup(team_config, "environment_only", null) == var.target_environment
  }

  team_id    = each.value.team_id
  repository = github_repository.repos[each.key].name
  permission = each.value.permission

  lifecycle {
    create_before_destroy = true
  }
}

# Add members to teams dynamically
# resource "github_team_membership" "team_members" {
#   for_each = {
#     for team, members in var.team_members_config : 
#     team => flatten([for member in members : {
#       team_id = github_team.teams[team].id
#       username = member
#     }])
#   }

#   team_id  = each.value.team_id
#   username = each.value.username
#   role     = "member"  # You can use "maintainer" if needed
# }
