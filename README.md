# IaC Common Modules Repository

This repository is for common IaC Modules to be imported and used by other projects

Projects utilizing these modules should be in separate repositories within the IaC Project

- [IaC Common Modules Repository](#iac-common-modules-repository)
  - [\> Azure Pipelines](#-azure-pipelines)
  - [\> Terraform](#-terraform)
    - [How to Use modules from external repository](#how-to-use-modules-from-external-repository)
  - [Repository Standard Practices](#repository-standard-practices)
    - [Branching Strategy](#branching-strategy)
    - [Versioning](#versioning)
    - [common\_tags](#common_tags)
  - [Variables](#variables)
    - [Local Variables](#local-variables)
  - [Outputs](#outputs)
    - [tags](#tags)

## > Azure Pipelines

Pipeline YAML files for:

- Terraform Validation
- Terraform Module Packaging and Versioning
- Pull Request/Branching Validation

Pipeline details can be found in the [README.md](./azure-pipelines/README.md) document in that folder

## > Terraform

This folder contains the common modules

### How to Use modules from external repository

Set the source of the module with `git://https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_resource_group?ref=<version tag>`

Use `ref=<version tag>` or `<branch name>` to specify version to use.  If not included, it will default to the version in `main` (default) branch

```tf
module "resource_group" {
    source = "git::https://dev.azure.com/vcuvs/IaC/_git/IaC//terraform/modules/azure_resource_group?ref=2.0.0"
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
```

Set Access Token from Pipeline for Git

```yaml
- bash: |
    MY_TOKEN=$(System.AccessToken)
    git config --global url."https://${MY_TOKEN}@dev.azure.com".insteadOf "https://dev.azure.com"
  displayName: 'git config - access token'
```

---

## Repository Standard Practices

### Branching Strategy

The `main` branch contains the "production" version of the modules. The `develop` branch is the working/branch and is where developers should branch on when creating new features.  Both of these branches are protected and can only be modified via pull request. One Approval is required, but the user submitting the PR cannot approve it.

### Versioning

Standard SemVer versioning is used on tags and within a modules-version.yaml file to determine the current versions of the terraform modules.  The ci-package-terraform pipeline generates these tags whenever updates to the terraform folder occur on a `feature/*` branch, the `develop`, or the `main` branch.

### common_tags

Defines a map of common tags that can be used throughout your Terraform configuration.

## Variables

variable "common_tags" {
  type = map(string)
  default = {
    BusinessUnit = "Finance"
    Technology  = "Operations"
    Organization = "OMB"
    owner        = "Vystar Credit Union"
    Project      = "OMB Cloud Implementation"
    Finance      = "701"  # Note: Changed to string to match map(string) type
  }
}

Description:

BusinessUnit: Specifies the business unit responsible for the resources.
Technology: Identifies the technology or operational aspect.
Organization: Represents the organization managing the resources.
owner: Indicates the owner or the entity responsible.
Project: Describes the project name or identifier.
Finance: Represents a financial code or identifier (string type).
Note: The Finance value is provided as a string to comply with the map(string) type.

### Local Variables

tags_vars

Local variable to store the common tags from the common_tags variable.

locals {
  tags_vars = var.common_tags
}

Description:

tags_vars: Holds the values of var.common_tags for use in other parts of the configuration.

## Outputs

### tags

Outputs the common tags defined in the local variable tags_vars.
output "tags" {
  value = local.tags_vars
}
Description:

tags: Provides the value of the local.tags_vars, which is the map of common tags.

Summary
This Terraform configuration file defines a set of common tags as a variable, uses a local variable to manage these tags, and outputs them for reference or use in other Terraform resources. Ensure that the types and values in the common_tags variable match the expected formats for your use case.
