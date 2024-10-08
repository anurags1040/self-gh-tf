# due to key-value map in for_each expression, nested loops fail and are not built properly. Hence I'm using locals 
# block now to creae a flat list first and then convert to map that can iterate over using for_each

# locals {
#   environment_secrets = flatten([
#     for repo, repo_config in var.github_config.repositories : [
#       for env, env_config in coalesce(repo_config.environments, {}) : [
#         for secret, secret_config in coalesce(env_config.secrets, {}) : {
#           repository_name  = repo
#           environment_name = env
#           secret_name      = secret
#           secret_value     = secret_config.value
#         }
#       ]
#     ]
#   ])
# }