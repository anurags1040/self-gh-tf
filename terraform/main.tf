module "github_setup" {
  source = "./modules/github-env-setup/"
  github_config = var.github_config
  # Add any necessary input variables here that the github-setup module requires
}

module "teams" {
  source = "./modules/teams/"

  teams_config       = var.teams_config
  target_environment = var.target_environment

  # Pass repository names from the github-setup module to the teams module
  repository_names   = module.github_setup.repository_names
}