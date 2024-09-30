output "repository_names" {
  description = "A map of the GitHub repositories created"
  value = { 
    for repo in github_repository.repos : repo.name => repo.name 
  }
}
