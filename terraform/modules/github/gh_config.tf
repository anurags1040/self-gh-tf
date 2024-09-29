data "github_repository" "repo" {
  full_name = var.repo_name
}


resource "github_repository_environment" "environments" {
  for_each = merge([
    for repo, repo_config in var.github_config.repositories :
    {
      for env, env_config in coalesce(repo_config.environments, {}) :
      "${repo}/${env}" => {
        repository  = repo
        environment = env
      }
    }
  ]...)

  repository  = github_repository.repos[each.value.repository].name
  environment = each.value.environment
}
