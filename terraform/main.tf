module "github_setup" {
  source = "./modules/github-env-setup/"
  github_config = var.github_config
  # Add any necessary input variables here that the github-setup module requires
}

module "teams" {
  source = "./modules/teams/"

  teams_config       = var.teams_config
  repository_names   = var.repository_names
}