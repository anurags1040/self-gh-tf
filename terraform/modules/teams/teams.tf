resource "github_team" "parent" {
  for_each = {
    for name, team in var.teams_config.teams : name => team
    if team.parent == null
  }

  name        = each.key
  description = each.value.description
  privacy     = "closed"
}

resource "github_team" "child" {
  for_each = {
    for name, team in var.teams_config.teams : name => team
    if team.parent != null
  }

  name        = each.key
  description = each.value.description
  privacy     = "closed"

  parent_team_id = each.value.parent != null ? github_team.parent[each.value.parent].id : null
}

# Note: This module only uses existing members that have already been assigned to the Github Org
# Query member info from the Github Org
data "github_membership" "member" {
  for_each = var.teams_config.members
  username = each.key
}

locals {
  # Create a map of alias to team name
  alias_to_team = {
    for team_name, team in var.teams_config.teams :
    team.alias => {
      name   = team_name
      parent = team.parent
    }
  }

  # Flatten the members and their teams
  member_teams = flatten([
    for member_key, member in var.teams_config.members : [
      for teams in member.teams : {
        member_key = member_key
        teams      = teams
      }
    ]
  ])

  # Match teams to teams
  matched_teams = {
    for item in local.member_teams :
    "${item.member_key}-${local.alias_to_team[item.teams].name}" => {
      member_key = item.member_key
      team_name  = local.alias_to_team[item.teams].name
      teams       = item.teams
      parent_team = local.alias_to_team[item.teams].parent
    }
    if contains(keys(local.alias_to_team), item.teams)
  }

  # Create list of all members that have been assigned admin
  admin_members = flatten([
    for key, value in local.matched_teams :
    value.member_key
    if value.teams == "admin"
  ])
}

# Assign users to proper teams, have to loop through all parent teams
resource "github_team_membership" "parent" {
  for_each = {
    for name, membership in local.matched_teams : name => membership
    if membership.parent_team == null
  }

  team_id  = github_team.parent[each.value.team_name].id
  username = each.value.member_key
  # If team member is an admin, then assign the maintainer role
  role = contains(local.admin_members, each.value.member_key) ? "maintainer" : "member"
}

# Assign users to proper teams, have to loop through all child teams
resource "github_team_membership" "child" {
  for_each = {
    for name, membership in local.matched_teams : name => membership
    if membership.parent_team != null
  }

  team_id  = github_team.child[each.value.team_name].id
  username = each.value.member_key
  # If team member is an admin, then assign the maintainer role
  role = contains(local.admin_members, each.value.member_key) ? "maintainer" : "member"
}

# Assign repository permissions to teams dynamically based on configuration
resource "github_team_repository" "team_repo_permissions" {
  for_each = merge([
    for team_name, team in var.teams_config.teams : 
    {
      for repo, permission in team.repositories : 
      "${team_name}-${repo}" => {
        team_name  = team_name
        repo       = repo
        permission = permission
        is_parent  = team.parent == null
      }
    }
  ]...)

  team_id    = try(github_team.parent[each.value.team_name].id, github_team.child[each.value.team_name].id)
  repository = var.repository_names[each.value.repo]
  permission = each.value.permission
}
