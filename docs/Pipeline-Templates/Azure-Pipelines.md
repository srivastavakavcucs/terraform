# Azure-Pipelines

This folder contains both pipelines for testing modules as well as templates to be used for project specific pipelines.

To use these templates, this repository should be added as a resource to the pipeline and the main body of the pipeline should extend from one of the extends.* files.

Example:

```yml
resources:
  repositories:
    - repository: templates
      name: IaC\IaC
      type: git
      ref: "refs/tags/0.0.3"
```

The `ref` field should be a reference to a specific tag on the repository.  This will pin the templates to that version, not including the ref will pull the default branch (`main` in this case).
