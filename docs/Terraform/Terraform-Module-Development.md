# Terraform Module Development

This folder should hold common modules to be import and used in other projects.

When creating new modules do the following:

1. Create a new feature branch from `develop`
2. Check out new branch and develop the module
3. Create a folder under the `modules` folder with the name of module.
4. Inside the module folder should contain the following files and folders:
    * main.tf
    * variables.tf
    * outputs.tf (if needed)
5. Tests for the modules should be created in the `tests` folder.
   * There should be at least 1 corresponding `<module-name>.tftest.hcl` file
   * If there are multiples test files for a module, there should be a corresponding `<module-name>` folder to hold *.tftest.hcl files
6. Inside the `samples` folder, create a sample terraform file that uses the module
7. Once development is complete open a PR to `develop`
    * Validation Pipeline will run (To Be developed)
      * tflint
      * terraform fmt
      * snyk scan
      * sonarqube scan
    * PR will be blocked if validation pipeline fails
8. Once PR to develop is approved and merged, open PR to `main` when ready to "Productionalize" module or change.

## Versioning

Versioning of the modules/pipeline templates are currently handled by manually adding tags to the repository at the appropriate time.

When a feature is merged to develop, a new tag to the develop branch should be created with the latest semVer version -dev.  i.e. `0.0.1-dev`

When this develop is then merged to main, that should then be tagged with as the updated semVer Version `0.0.1`

> :warning: This is currently a manual process, automatic options are being explored.
