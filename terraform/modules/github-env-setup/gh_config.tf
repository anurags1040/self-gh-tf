# # Check if repositories already exist using a data source
data "github_repository" "existing_repos" {
  for_each = var.github_config.repositories
  name     = each.key
}

resource "github_repository" "repos" {
  for_each = {
    for repo, repo_config in var.github_config.repositories :
    repo => repo_config
    if try(data.github_repository.existing_repos[repo].id, null) == null  # Only create if repo doesn't exist
  }

  name = each.key
}

#user id error for reviewers. The following data block converts the github username to github user id which
#is the accepted format here.
# Lookup GitHub user IDs based on usernames
data "github_user" "reviewer_ids" {
  for_each = toset(flatten([
    for repo, repo_config in var.github_config.repositories : [
      for env, env_config in coalesce(repo_config.environments, {}) :
      env_config.reviewers
    ]
  ]))

  username = each.value
}

resource "github_repository_environment" "environments" {
  for_each = merge([
    for repo, repo_config in var.github_config.repositories :
    {
      for env, env_config in coalesce(repo_config.environments, {}) :
      "${repo}/${env}" => {
        repository  = repo
        environment = env
        reviewers         = env_config.reviewers
        branch_policies   = env_config.branch_policies
      }
    }
  ]...)

  repository  = try(github_repository.repos[each.value.repository].name, data.github_repository.existing_repos[each.value.repository].name)
  environment = each.value.environment
# Use the reviewers provided in the github_config
  reviewers {
    users = [for reviewer in each.value.reviewers : data.github_user.reviewer_ids[reviewer].id]
  }

  # Set branch deployment policies. custom_branch_policies and protected_branches settings cannot both have the
  # same value, meaning that both cannot be true at the same time in the deployment_branch_policy of a GitHub environment.
  deployment_branch_policy {
    protected_branches     = each.value.branch_policies.protected_branches
    custom_branch_policies = each.value.branch_policies.protected_branches ? false : each.value.branch_policies.custom_branch_policies
  }

  depends_on = [github_repository.repos]
}

#let tf create secret and ignore changes on every run

# resource "null_resource" "wait_for_repo_creation" {
#   depends_on = [github_repository.repos]

#   provisioner "local-exec" {
#     command = "sleep 10"  # This adds a 10-second delay
#   }
# }

resource "github_actions_environment_secret" "environment_secrets" {
  for_each = { for idx, secret in local.environment_secrets : "${secret.repository_name}-${secret.environment_name}-${secret.secret_name}" => secret }

  repository     = github_repository.repos[each.value.repository_name].name
  environment    = each.value.environment_name
  secret_name    = each.value.secret_name
  plaintext_value = each.value.secret_value

  depends_on = [github_repository.repos]
}