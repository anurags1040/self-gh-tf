# # Check if repositories already exist using a data source
# data "github_repository" "existing_repos" {
#   for_each = var.github_config.repositories
#   name     = each.key
# }

resource "github_repository" "repos" {
  # for_each = {
  #   for repo, repo_config in var.github_config.repositories :
  #   repo => repo_config
  #   if try(data.github_repository.existing_repos[repo].id, null) == null  # Only create if repo doesn't exist
  # }

  for_each = var.github_config.repositories
  name = each.key

  lifecycle {
    prevent_destroy = true  # This will prevent Terraform from destroying the repository
  }
  
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

  repository  = github_repository.repos[each.value.repository].name
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

   lifecycle {
    ignore_changes = [environment, reviewers, repository]
  }

  depends_on = [github_repository.repos]
}

#This change uses the try() function to look for the repository in github_repository.repos, 
#and if it’s not there, it looks in data.github_repository.existing_repos. This ensures that it can handle 
#both newly created and existing repositories.

# resource "github_actions_environment_secret" "environment_secrets" {
#   for_each = { for idx, secret in local.environment_secrets : "${secret.repository_name}-${secret.environment_name}-${secret.secret_name}" => secret }

#   repository     = try(github_repository.repos[each.value.repository_name].name, data.github_repository.existing_repos[each.value.repository_name].name)
#   environment    = each.value.environment_name
#   secret_name    = each.value.secret_name
#   plaintext_value = each.value.secret_value

#    lifecycle {
#     ignore_changes = [
#       plaintext_value
#     ]
#   }
  
#   depends_on = [github_repository.repos]
# }

# resource "github_branch" "branch" {
#   for_each = merge([
#     for repo_name, repo in var.github_config.repositories : {
#       for branch_name in keys(repo.environments.test.branch_policies.rules) :
#       "${repo_name}-${branch_name}" => {
#         repository = repo_name
#         branch     = branch_name
#       }
#     }
#   ]...)

#   repository = github_repository.repos[each.value.repository].name
#   branch     = each.value.branch
# }

resource "github_branch" "default_branches" {
  for_each = merge([
    for repo_name, repo in var.github_config.repositories : {
      for branch_name in keys(repo.branches) :
        "${repo_name}-${branch_name}" => {
          repository = repo_name
          branch     = branch_name
          source_branch = "main"
        }
      if branch_name != "feature/*"  # Exclude the wildcard pattern
    }
  ]...)

  repository = github_repository.repos[each.value.repository].name
  branch     = each.value.branch
  source_branch = each.value.source_branch
}

data "github_branch" "existing_branches" {
  for_each = merge([
    for repo, config in var.github_config.repositories : {
      for branch in keys(config.branches) :
        "${repo}-${branch}" => { repository = repo, branch = branch }
    }
  ]...)

  repository = each.value.repository
  branch     = each.value.branch

  depends_on = [github_branch.default_branches]
}

resource "github_branch_protection" "pattern_protection" {
  for_each = {
    for key, value in merge([
      for repo_name, repo in var.github_config.repositories : 
        merge([
          for env_name, env in repo.environments : 
            {
              for branch_name, branch_config in coalesce(env.branch_policies.rules, {}) :
                "${repo_name}-${env_name}-${branch_name}" => {
                  repo       = repo_name
                  env        = env_name
                  pattern    = branch_name
                  protection = branch_config
                }
              if contains(["feature/*", "bugfix/*"], branch_name)
            }
        ]...)
    ]...) :
    key => value
  }

  repository_id = github_repository.repos[each.value.repo].node_id
  pattern       = each.value.pattern

  required_pull_request_reviews {
    required_approving_review_count = each.value.protection.required_approvals
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = try(each.value.protection.approvals_reset_on_source_change, false)
    require_last_push_approval      = try(each.value.protection.reset_approvals_if_diff_changes, false)
  }

  required_status_checks {
    strict   = true
    contexts = each.value.protection.status_checks
  }

  enforce_admins = try(each.value.protection.enforce_admins, false)

  allows_deletions = try(!each.value.protection.block_deletions, true)

  lifecycle {
    ignore_changes = [
      required_pull_request_reviews,
      required_status_checks,
      enforce_admins,
      allows_deletions,
      allows_force_pushes,
    ]
  }

  depends_on = [github_repository.repos]
}


resource "github_branch_protection" "branch_protection" {
  for_each = {
    for key, value in merge([
      for repo_name, repo in var.github_config.repositories : 
        merge([
          for env_name, env in repo.environments : 
            {
              for branch_name, branch_config in coalesce(env.branch_policies.rules, {}) :
                "${repo_name}-${env_name}-${branch_name}" => {
                  repo       = repo_name
                  env        = env_name
                  branch     = branch_name
                  protection = branch_config
                }
            }
        ]...)
    ]...) :
    key => value
  }

  repository_id = github_repository.repos[each.value.repo].node_id
  pattern       = each.value.branch

  enforce_admins = true
  allows_deletions = false
  allows_force_pushes = false

  required_status_checks {
    strict   = try(each.value.protection.strict_status_checks, false)
    contexts = each.value.protection.required_status_checks
  }

  required_pull_request_reviews {
    dismiss_stale_reviews           = each.value.protection.dismiss_stale_reviews
    require_code_owner_reviews      = try(each.value.protection.require_code_owner_reviews, false)
    required_approving_review_count = each.value.protection.required_approvals
    require_last_push_approval      = try(each.value.protection.require_last_push_approval, false)
  }

lifecycle {
    ignore_changes = [
      required_pull_request_reviews,
      required_status_checks,
      enforce_admins,
      allows_deletions,
      allows_force_pushes,
    ]
  }
 

  depends_on = [github_repository.repos, github_branch.default_branches]
}