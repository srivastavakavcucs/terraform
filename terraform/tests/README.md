# Terraform Test Files

This directory contains automated test files for Terraform modules located in `terraform/modules`.

## 📁 Directory Structure

```
terraform/tests/
├── README.md
├── environments/
│   └── variables.integration_test.tfvars 
└── <module-name>/  #azure_resource_group, azure_load_balancer
    ├── integration_tests/                    # Integration test files
    │   ├── <test-case-1>.tftest.hcl
    │   └── <test-case-2>.tftest.hcl
    └── unit_tests/                           # Unit test files (optional)
        └── <test-case>.tftest.hcl
```

## 📝 Naming Conventions

### Module Folder Structure
- **Single test file**: Name it `<module-name>.tftest.hcl` directly in the module folder
- **Multiple test files**: Create a folder named `<module-name>` containing subdirectories:
  - `integration_tests/` - Tests that deploy actual resources to Azure
  - `unit_tests/` - Tests using mocks (if applicable)

### Test File Naming
- Use descriptive names: `<module-name>_<scenario>.tftest.hcl`
- Examples:
  - `azure_resource_group.tftest.hcl` - Create new resource group
  - `azure_resource_group_existing.tftest.hcl` - Use existing resource group

## 🧪 Test Types

### Integration Tests
Located in `<module-name>/integration_tests/`
- Deploy actual Azure resources
- Validate real infrastructure behavior
- **Automatically clean up** resources after test completes
- Require Azure authentication (OIDC)

### Unit Tests
Located in `<module-name>/unit_tests/` (optional)
- Use mock providers or plan-only tests
- Faster execution, no Azure deployment
- Validate logic without creating resources

## ✅ Writing Test Files

### Required Components

Each test file must include:

1. **Variable Declarations** - All variables used must be explicitly declared:
```hcl
variable "region" {
  type        = string
  description = "Azure region for resource deployment"
}
```

2. **Provider Configuration** - Azure provider with OIDC authentication:
```hcl
provider "azurerm" {
  features {}
  use_oidc        = true
  subscription_id = var.INTEGRATION_TEST_SUBSCRIPTION_ID
  tenant_id       = var.TENANT_ID
}
```

3. **Run Blocks** - Test execution with assertions:
```hcl
run "test_name" {
  command = apply  # or 'plan' for unit tests
  
  module {
    source = "../../../modules/module_name"
  }
  
  variables {
    # Pass test variables
  }
  
  assert {
    condition     = output.name != null
    error_message = "Output should not be null"
  }
}
```

## 🔧 Running Tests

### Automated Pipeline Execution
Tests run automatically in Azure DevOps pipeline when triggered.

### Manual Execution

#### Run All Tests in a Module
```bash
cd terraform/tests/azure_resource_group/integration_tests
terraform init
terraform test -var-file="../../environments/variables.integration_test.tfvars" -verbose
```

#### Run Specific Test File
```bash
terraform test -var-file="../../environments/variables.integration_test.tfvars" -filter="test_name"
```

#### Run with Custom Variables
```bash
terraform test -var-file="path/to/custom.tfvars"
```

## 📋 Test Variables

### Shared Variables File
Location: `environments/variables.integration_test.tfvars`

Contains common variables used across all tests:
- Azure subscription and tenant IDs
- Common tags
- Region, app_name, environment
- Existing resource names for testing

### Required Variables for Integration Tests
```hcl
INTEGRATION_TEST_SUBSCRIPTION_ID = "subscription-id"
TENANT_ID                        = "tenant-id"
region                          = "eastus"
app_name                        = "IaC"
environment                     = "dev"
environment_number_suffix       = "001"
common_tags                     = { ... }
```

## 🚀 Test Lifecycle

1. **Initialize**: `terraform init` downloads providers and modules
2. **Apply**: Test creates resources (if applicable)
3. **Assert**: Validate outputs and behavior
4. **Cleanup**: Terraform automatically destroys created resources
5. **Report**: Pass/fail status with detailed errors

## 📞 Support

For questions about writing tests or test failures:
- Review existing test files for examples
- Check pipeline logs for detailed error messages
- Ensure `variables.integration_test.tfvars` has required values
