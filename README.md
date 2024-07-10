# Background

GitHub Actions recently implemented a feature that allows workflows to generate signed OpenID Connect tokens, which has exciting implications for anyone using GitHub Actions to manage resources in AWS.

This feature allows secure and seamless integration with AWS IAM and eliminates the need to store and rotate long-term AWS credentials in GitHub.

## Why?

The old way of doing things looked like this:
- Create an IAM User and deployment role for the build job (hopefully through infrastructure as code)
- Generate static credentials for that user (the AWS access key / secret key pair)
- Store them in GitHub (hopefully securely)
- Retrieve IAM user credentials at build time and set them as environment variables in the build job
- Build job authenticates as IAM user, then assumes the deployment role to perform tasks in build

While this method is somewhat in line with AWS best practices - having the user assume the role to acquire permissions, and automating the configuration with code - it still requires you to generate and store keys. Furthermore, IAM Users are typically reserved for human users, who have web console access and MFA keys. These are not the type of properties we wish to associate with machines and apps running builds.

## Enter OIDC Identity Federation

Now that Github Actions has added support for OpenID Connect (OIDC), we can now securely deploy to any cloud provider that supports OIDC using short-lived keys that are automatically rotated for each deployment. This means:

- No need to store long term credentials and plan for rotation
- You can use your cloud providers native tools to configure least-privelege access for your build jobs
- Simpler infrastructure as code

Useful links:
https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect

https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services


# How to use this repo
In the `_main.tf` file you will find the IAM resources required to set up authentication with OIDC. The IAM policy document in that file is configurable using the variable `github_orgs` found in `variables.tf`:

```terraform
variable "github_orgs" {
default = {
    "myorg" = {
      "orgname" = "myorg",
      "repos" = ["myrepo", "another-repo"]
    }
  }
```

Within the `github_orgs` map, each string in `repos` and `orgname` will be used in the test condition in the IAM policy document which determines which Github repos can authenticate using this policy:
```terraform
...
	condition {
     test     = "StringLike"
     variable = "token.actions.githubusercontent.com:sub"
     values   = [
     	"repo:myorg/myrepo:*",	# These can be further scoped down to a branch or workflow in this repo
     	"repo:myorg/another-repo:*"
     	...
     ]
   }
```

## Centralising deployment roles

Another goal of this repository is to centralise deployment role policies, so that they are seperated from the IAC typically checked in with applications. This is because deployment role permissions rarely change, but applications and their IAC can change frequently. These role policies should be stored in the roles.tf file - an example exists for the Sceptre tool which at a minimum, requires Cloudformation permissions in order to run. 

## CI/CD
This repo is associated with the Terraform Cloud `myorg` organisation, and has a workspace with the [same name](https://app.terraform.io/app/myorg/workspaces/aws-oidc-github-actions). On merges to master, a CICD workflow will be triggered to update the IAM resources in the CC AWS account.

