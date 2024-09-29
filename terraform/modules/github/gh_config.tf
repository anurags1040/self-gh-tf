#Reference existing repos instead of creating new ones

data "github_repository" "repo" {
  for_each = var.github_config.repositories

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

  repository  = data.github_repository.repos[each.value.repository].name
  environment = each.value.environment
# Use the reviewers provided in the github_config
  reviewers {
    users = [for reviewer in each.value.reviewers : data.github_user.reviewer_ids[reviewer].id]
  }

  # Set branch deployment policies
  deployment_branch_policy {
    protected_branches     = each.value.branch_policies.protected_branches
    custom_branch_policies = each.value.branch_policies.custom_branch_policies
  }
}

# Example of defining the repositories from a separate data or resource block
# Assuming `github_repository.repos` references GitHub repositories to be created or imported elsewhere.
resource "github_repository" "repos" {
  for_each = var.github_config.repositories

  name = each.key
  # Add other repository configuration details here if necessary
}

