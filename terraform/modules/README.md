# Terraform Module Development Guide

This guide outlines the **standard process** for creating a reusable Terraform module in this repository. All modules developed here are designed to be **portable**, **maintainable**, and **easily consumable** across different infrastructure environments.

---

## Table of Contents

- [Terraform Module Development Guide](#terraform-module-development-guide)
  - [Table of Contents](#table-of-contents)
  - [Repository Structure](#repository-structure)
  - [Steps to Create a New Terraform Module](#steps-to-create-a-new-terraform-module)
    - [1. Create a New Feature Branch](#1-create-a-new-feature-branch)
    - [2. Create the Module Directory](#2-create-the-module-directory)
    - [3. Add Required Files to the Module Folder](#3-add-required-files-to-the-module-folder)
      - [Usage of iac\_base module](#usage-of-iac_base-module)
      - [Creating Documentation For New Module](#creating-documentation-for-new-module)
      - [1. Create a `README.md` File](#1-create-a-readmemd-file)
      - [2. Structure the Documentation](#2-structure-the-documentation)
        - [2.1 Module Name and Description](#21-module-name-and-description)
        - [2.2 Module Usage](#22-module-usage)
        - [2.3 Input Variables](#23-input-variables)
          - [Required Variables](#required-variables)
          - [Optional Variables](#optional-variables)
        - [2.5 Output Values](#25-output-values)
        - [2.6 References](#26-references)
    - [6. Commit and Push Your Code](#6-commit-and-push-your-code)
    - [7. Open a Pull Request to `develop`](#7-open-a-pull-request-to-develop)
    - [8. Merge to `main`](#8-merge-to-main)
  - [Summary Checklist](#summary-checklist)
  - [Tips for Module Quality](#tips-for-module-quality)

---

## Repository Structure

This folder (`modules/`) holds reusable Terraform modules to be imported and used in various projects. Each module should follow the structure and guidelines outlined below.

---

## Steps to Create a New Terraform Module

### 1. Create a New Feature Branch

Start by creating a feature branch from the `develop` branch:

```bash
git checkout develop
git pull origin develop
git checkout -b feature/<module-name>
```

### 2. Create the Module Directory

Create a new folder under the `modules/` directory:

<pre> <code> modules/
└── &lt;module-name&gt;/ </code> </pre>

### 3. Add Required Files to the Module Folder

Each module should include the following files:

| File Name       | Description |
|-----------------|-------------|
| `main.tf`       | The core logic of the module (resources, data blocks, etc.). Keep it modular and organized. |
| `variables.tf`  | Input variables required by the module. Each variable should have a description, type, and (optional) default value. |
| `outputs.tf`    | (Optional) Outputs from the module to be used by root modules or other modules. |
| `main.base.tf`  | Used for configure name, resource_groupe_name,location from the iac_base module and some common config across environments (e.g., locals, common tags).|
| `providers.tf`  | (Optional) Defines the required providers and versions, if the module needs to explicitly declare them. |
| `README.md`     | Documentation for the module usage, variables, outputs, and examples. Clearly explain how to use the module. |

> ✅ **Best Practice**: Group related logic (e.g., resource groups, networking, compute) together and avoid hard-coding values.

#### Usage of iac_base module

> The `main.base.tf` file is specifically used to configure foundational settings such as `name`, `resource_group_name`, and `location` by leveraging the shared `iac_base` module. It also includes reusable configurations like `locals` and `common_tags` to maintain consistency across environments.
> For a detailed understanding, refer to the [iac_base module documentation](https://dev.azure.com/vcuvs/_git/IaC?path=/terraform/modules/iac_base/ReadMe.md&version=GBfeature/AKS-Core-Demo&_a=preview).

#### Creating Documentation For New Module

Every new module should include a well-structured `README.md` file to ensure clarity, usability, and maintainability. Follow these steps to create comprehensive documentation:

#### 1. Create a `README.md` File

Inside your module folder:

<pre><code>modules/
└── &lt;module-name&gt;/
    └── README.md
</code></pre>

#### 2. Structure the Documentation

Use the following recommended sections:

##### 2.1 Module Name and Description
Start with a title and a short summary of what the module does.

##### 2.2 Module Usage
Provide a minimal working example using the module.

##### 2.3 Input Variables
Document all variables declared in `variables.tf` Required and Optional Variables.

###### Required Variables
Use a table format for clarity:
```
| Name                  | Type     | Description                        | Default     | Required |
|-----------------------|----------|------------------------------------|-------------|----------|
```
###### Optional Variables
Use a table format for clarity:
```
| Name                  | Type     | Description                        | Default     | Required |
|-----------------------|----------|------------------------------------|-------------|----------|
```
##### 2.5 Output Values
Document all outputs declared in `outputs.tf`.
```
| Name         | Description                         |
|--------------|-------------------------------------|
```
##### 2.6 References
Include links to any relevant modules or external documentation. 

---

### 6. Commit and Push Your Code

Use your preferred Git workflow to stage, commit, and push the module code to the remote repository.

---

### 7. Open a Pull Request to `develop`

Once your code is pushed, open a PR targeting the `develop` branch.

A **Validation Pipeline** will automatically run:

- ✅ `tflint` – Terraform linter to catch syntax and best practice issues
- ✅ `terraform fmt` – Code formatting check
- ✅ `snyk` – Security scan for Terraform configurations

> ❗**Note**: The PR will be blocked if any validation step fails.

---

### 8. Merge to `main`

Once your PR to `develop` is approved and all tests/validations pass:

- Open a PR to `main` when the module is ready for production use.
- Tag releases if versioning is used.

---

## Summary Checklist

| Step                                | Required |
|-------------------------------------|----------|
| Feature branch from `develop`       | ✅       |
| Module folder with required files   | ✅       |
| PR to `develop` branch              | ✅       |
| PR to `main` branch (after review)  | ✅       |

---

## Tips for Module Quality

- Use [Terraform variable validation](https://developer.hashicorp.com/terraform/language/values/variables#custom-validation-rules).
- Keep the module logic generic and reusable.
- Avoid setting defaults that tie the module to a specific environment unless necessary.
- Add inline comments for clarity and maintainability.
