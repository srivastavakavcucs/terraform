# Infrastructure as Code

[[_TOSP_]]

## Quick-Start

### > Azure Pipelines

This folder contains templates to be extended for deploying infrastructure

### > Terraform

This folder contains the common modules

#### How to Use modules from external repository

Set the source of the module with `git://https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_resource_group?ref=<version tag>`

Use `ref=<version tag>` or `<branch name>` to specify version to use.  If not included, it will default to the version in `main` (default) branch

```tf
module "resource_group" {
    source = "git::https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_resource_group?ref=main"
    rg_name = var.tf_omb_infra_resource_group
    location = var.tf_omb_infra_location
}
```

When using in a pipeline, you'll need to checkout out this repository and persist the credentials and set the git config with the following so the pipeline access token is used:

Include repository in pipeline

```yaml
resources:
  repositories:
    - repository: modules
      name: IaC/IaC
      type: git
      ref: refs/tags/<appropriate tag>
```

Set Access Token from Pipeline for Git

```yaml
- bash: |
    MY_TOKEN=$(System.AccessToken)
    git config --global url."https://${MY_TOKEN}@dev.azure.com".insteadOf "https://dev.azure.com"
  displayName: 'git config - access token'
```
