# Data block to check if the teams already exist
data "github_team" "existing_teams" {
  for_each = var.teams_config

  slug = each.key
}

resource "github_team" "teams" {
  for_each = var.teams_config

  name        = each.key
  description = each.value.description
  privacy     = "closed"  # Ensure privacy is compatible with child teams

  # Ensure parent_team_id is only set after the parent team exists
}


# Use data source to fetch parent team IDs if needed
data "github_team" "parent_teams" {
  for_each = { for team_name, team_config in var.teams_config : team_name => team_config if team_config.parent_team != "" }

  slug = each.value.parent_team
}

# Update parent_team_id for child teams (only after they have been created)
resource "github_team" "update_parent_team" {
  for_each = { for team_name, team_config in var.teams_config : team_name => team_config if team_config.parent_team != "" }

  name = each.key

  # Assign the parent_team_id using the data source
  parent_team_id = data.github_team.parent_teams[each.key].id

  depends_on = [github_team.teams, data.github_team.parent_teams]
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
