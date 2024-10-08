output "repository_names" {
  description = "A map of the GitHub repositories created"
  value = { 
    for repo in github_repository.repos : repo.name => repo.name 
  }
}

output "debug_branch_protection_structure" {
  value = merge([
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
  ]...)
}
