provider "aws" {
  region = var.region
}

terraform {
  cloud {
    organization = "IACPractice"

    workspaces {
      name = "aws-oidc-github-actions"
    }
  }
}

locals {
  repos-list = flatten([
    for org in var.github_orgs : [
      for repo in org.repos : "repo:${org.orgname}/${repo}:*"
    ]
  ])
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
  # The last known good thumbprint is 6938fd4d98bab03faadb97b34396831e3780aea1
  # see: https://github.blog/changelog/2022-01-13-github-actions-update-on-oidc-based-deployments-to-aws/
  thumbprint_list = data.tls_certificate.github.certificates[*].sha1_fingerprint

}


data "aws_iam_policy_document" "github_allow" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_oidc.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.repos-list
    }
  }
}
