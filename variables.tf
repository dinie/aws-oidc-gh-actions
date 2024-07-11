variable "region" {
  default = "ap-southeast-2"
}

variable "orgname" {
  type    = string
  default = "dinie"
}

variable "github_orgs" {
  type = map(
    object({
      orgname = string
      repos   = list(string)
    })
  )
  # Config object containing Github orgs and the repos which should
  # have permission to use this OIDC provider
  default = {
    "IACPractice" = {
      "orgname" = "dinie",
      "repos"   = ["aws-sample-spa", "aws-oidc-gh-actions"]
    }
  }
}

variable "projects" {
  type    = list(string)
  default = ["aws-sample-spa", "aws-oidc-gh-actions"]
}
