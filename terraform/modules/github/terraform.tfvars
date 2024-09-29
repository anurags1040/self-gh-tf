github_config = {
  repositories = {
    "self-gh-tf" = {
      environments = {
        "test" = {
          reviewers = ["anurags1040", "anujsh"]
          branch_policies = {
            protected_branches     = false
            custom_branch_policies = true
          }
          secrets = {
            "CF_SPACE" = { value = "test" }
            "CF_USER" = { value = "test-user" }
            "CF_PASSWORD" = { value = "test-password" }
          }
        }
        "staging" = {
          reviewers = ["anurags1040"]
          branch_policies = {
            protected_branches     = true
            custom_branch_policies = false
          }
          secrets = {
            "CF_SPACE" = { value = "staging" }
            "CF_USER" = { value = "staging-user" }
            "CF_PASSWORD" = { value = "staging-password" }
          }
        }
        "production" = {
          reviewers = ["anurags1040"]
          branch_policies = {
            protected_branches     = true
            custom_branch_policies = false
          }
          secrets = {
            "CF_SPACE" = { value = "prod" }
            "CF_USER" = { value = "prod-user" }
            "CF_PASSWORD" = { value = "prod-password" }
          }
        }
      }
    }
    "github-actions-solar-system" = {
      environments = {
        "staging" = {
          reviewers = ["anurags1040"]
          branch_policies = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
        "production" = {
          reviewers = ["anurags1040", "jaiswaladi246"]
          branch_policies = {
            protected_branches     = true
            custom_branch_policies = false
          }
        }
      }
    }
    "sbx-test-tf" = {
      environments = {
        "sbx" = {
          reviewers = ["anurags1040"]
          branch_policies = {
            protected_branches     = true
            custom_branch_policies = false
          }
          secrets = {
            "MY_SECRET" = { value = "sbx-secret-value" }
            "ANOTHER_SECRET" = { value = "another-sbx-secret-value" }
          }
        }
        "test" = {
          reviewers = ["anurags1040", "jaiswaladi246"]
          branch_policies = {
            protected_branches     = true
            custom_branch_policies = false
          }
          secrets = {
            "TEST_SECRET" = { value = "sbx-secret-value" }
            }
        }
      }
    }
  }
}