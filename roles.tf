data "aws_iam_policy_document" "sceptre_policy" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackResources",
      "cloudformation:DescribeStacks",
      "cloudformation:GetStackPolicy",
      "cloudformation:GetTemplate",
      "cloudformation:GetTemplateSummary",
      "cloudformation:ListStackResources",
      "cloudformation:ListStacks",
      "cloudformation:SetStackPolicy",
      "cloudformation:TagResource",
      "cloudformation:UntagResource",
      "cloudformation:UpdateStack",
      "cloudformation:UpdateTerminationProtection",
      "cloudformation:ValidateTemplate",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:ListChangeSets",
      "iam:GetRole",
      "iam:DeleteRole",
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy"
    ]
  }
}


resource "aws_iam_role" "github_role_repo" {
  name               = "GHActionsRole${var.orgname}CICD"
  assume_role_policy = data.aws_iam_policy_document.github_allow.json
}

resource "aws_iam_role_policy" "deployment_role_policies" {
  for_each = toset(var.projects)
  name     = "GithubActionsDeploymentRolePolicy${replace(title(each.key), "-", "")}"
  policy   = data.aws_iam_policy_document.sceptre_policy.json
  role     = aws_iam_role.github_role_repo.id
}

output "github_role_arn" {
  value = aws_iam_role.github_role_repo.arn
}
