<!-- markdownlint-disable MD024 -->
# Azure Pipelines

[[_TOC_]]

## ci-package-terraform

[Link to Pipeline](https://dev.azure.com/vcuvs/IaC/_build?definitionId=2235)

### Description

This pipeline will zip and publish the terraform modules folder to an [Artifacts Feed](https://dev.azure.com/vcuvs/IaC/_artifacts/feed/IaC-Terraform) whenever there is an update to a `feature/`, `develop` or `main` branch.  The generated version will then be used to tag the repository and update the modules-version.yml in the terraform folder.

#### Auto-Versioning

This leverages the auto-versioning capabilities of the [UniversalPackages Task](https://learn.microsoft.com/en-us/azure/devops/pipelines/tasks/reference/universal-packages-v0?view=azure-pipelines), setting the `versionOption` input field to update with Semantic Version (MAJOR.MINOR.PATCH)

By default `PATCH` is updated. When the develop branch is updated, `MINOR` will be updated, and when main is updated `MAJOR` will be updated.

The version tag generated should be used by the terraform that utilized these modules.

### Trigger

The pipeline trigger is defined as following:

```yaml
trigger:
  branches:
    include:
      - develop
      - main
      - feature/*
  paths:
    include:
      - terraform/*
    exclude:
      - azure-pipelines
      - .gitignore
```

This means it will only trigger when there are updates (merges/pushes) to the `develop`, `main`, or any `feature/*` branches and the updates include changes to anything under the terraform folder.

## ci-iac-terraform-validate

[Link to Pipeline](https://dev.azure.com/vcuvs/IaC/_build?definitionId=2031)

### Description

This pipeline will perform the following actions on the terraform/modules folders:

- Verify the terraform format with `terraform fmt`.
- Lint the Terraform with `tflint`
- Run Security scan with `snyk iac`, erroring if anything High or above is found.

The pipe will fail if any of these jobs fail.  There is currently no explicit gate on these failures, but should be checked when PRs are open.

### Trigger

The pipeline trigger is defined as following:

```yaml
trigger:
  branches:
    include:
      - develop
      - feature/*
  paths:
    include:
      - terraform/*
    exclude:
      - azure-pipelines
      - .gitignore
```

This means it will only trigger when there are updates (merges/pushes) to the `develop` or any `feature/*` branches and the updates include changes to anything under the terraform folder.

## PR-Source-Branch-Validation

[Link to Pipeline](https://dev.azure.com/vcuvs/IaC/_build?definitionId=2308)

### Description

This pipeline is for enforcing the feature -> develop -> main branching strategy workflow.

| Source Branch | Target Branch |
|---------------|---------------|
| feature/*     | develop       |
| develop       | main          |

Any other Source Branch -> Target Branch combinations will cause a failure of the pipeline and block PRs.  The Pipeline will post an appropriate error message to the Pull Request on failure.

### Trigger

This pipeline is set to be run as part of a Branch Policy on the repository, triggering whenever a Pull Request is opened.
