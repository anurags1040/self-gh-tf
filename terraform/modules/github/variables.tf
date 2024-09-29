variable "repo_name" {
  type = string
  default = "anurags1040/self-gh-tf"
}

variable "github_config" {
  description = "Configuration for GitHub repositories and their environments"
  type = object({
    repositories = map(object({
      environments = map(object({
        reviewers = list(string)
        branch_policies = object({
          protected_branches     = bool
          custom_branch_policies = bool
        })
      }))
    }))
  })
}