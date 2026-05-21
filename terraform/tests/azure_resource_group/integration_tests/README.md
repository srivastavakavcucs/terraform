# Azure Resource Group - Integration Tests

## Overview

This directory contains integration tests for the Azure Resource Group Terraform module. The tests validate both the creation of new resource groups and the usage of existing resource groups in Azure.

## Directory Structure

```
integration_tests/
├── README.md                                    # This file
├── azure_resource_group.tftest.hcl             # Test: Create new Resource Group
├── azure_resource_group_existing.tftest.hcl    # Test: Use existing Resource Group
└── setup/
    └── main.tf                                  # Setup module for test prerequisites
```

---

## Setup Module (`setup/main.tf`)

### Purpose

The setup module provides **intelligent Resource Group management** for integration tests. It dynamically handles resource groups by checking if they exist and creating them only when needed, with smart cleanup logic.

### Key Features

✅ **Idempotent Operations**
- Checks if Resource Group already exists in Azure
- Creates RG only if it doesn't exist
- Uses existing RG if already present

✅ **Smart Cleanup Logic**
- Deletes Resource Groups created by the setup during cleanup
- Preserves pre-existing Resource Groups (doesn't delete them)
- Tracks creation state using triggers

✅ **Flexible Execution**
- Can skip all operations if variable is empty
- Supports both create and use-existing scenarios
- Pipeline-ready with OIDC authentication

### Use Cases

| Use Case | Scenario | Behavior |
|----------|----------|----------|
| **1** | Variable provided + RG doesn't exist | Creates new RG, deletes on cleanup |
| **2** | Variable provided + RG exists | Uses existing RG, preserves on cleanup |
| **3** | Variable empty | Skips all execution |

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Setup Module Flow                        │
└─────────────────────────────────────────────────────────────┘

1. Input Validation
   └─ Check if custom_resource_group_name is provided
      ├─ Empty → Skip all (Use Case 3)
      └─ Provided → Continue to step 2

2. Pre-Check (External Data Source)
   └─ Run Azure CLI: az group exists --name <rg_name>
      ├─ Returns: {"exists":"false"} → RG doesn't exist
      └─ Returns: {"exists":"true"}  → RG exists

3. Conditional Provisioning (Null Resource)
   └─ Create Provisioner:
      ├─ If exists=="false" → Create RG using Azure CLI
      └─ If exists=="true"  → Skip creation
   └─ Store State:
      └─ triggers.was_provisioned = "true/false"

4. Read Resource Group (AzureRM Data Source)
   └─ Fetch RG details: name, id, location
   └─ Output for use in tests

5. Cleanup (Destroy Provisioner)
   └─ Destroy Provisioner:
      ├─ If was_provisioned=="true"  → Delete RG
      └─ If was_provisioned=="false" → Preserve RG
```

### Providers Used

**1. `azurerm` Provider**
- **Purpose:** Azure resource management
- **Usage:** Reads Resource Group details after ensuring it exists
- **Version:** `~> 3.0`

**2. `null` Provider**
- **Purpose:** Lifecycle hooks for custom logic
- **Usage:** Executes Azure CLI commands conditionally (create/destroy)
- **Version:** `~> 3.0`

**3. `external` Provider**
- **Purpose:** Execute external scripts and capture output
- **Usage:** Checks if RG exists without throwing errors
- **Version:** `~> 2.3`

### Variables

| Variable | Type | Description | Default |
|----------|------|-------------|---------|
| `custom_resource_group_name` | string | Name of the resource group to check/create | `""` |
| `region` | string | Azure region for resource group creation | - |
| `INTEGRATION_TEST_SUBSCRIPTION_ID` | string | Azure subscription ID | - |
| `TENANT_ID` | string | Azure tenant ID | - |
| `common_tags` | map(string) | Common tags to apply | `{}` |

### Outputs

| Output | Description |
|--------|-------------|
| `resource_group_name` | Name of the existing or newly created resource group |
| `resource_group_id` | Full Azure resource ID |
| `resource_group_location` | Azure region/location |
| `was_provisioned` | Boolean: true if setup created the RG, false if it already existed |
| `execution_skipped` | Boolean: true when custom_resource_group_name is empty |

### Technical Implementation

**External Data Source Check:**
```hcl
data "external" "rg_exists" {
  program = ["pwsh", "-Command", 
    "az group exists --name <name> | ConvertTo-Json"
  ]
}
```
- Uses Azure CLI to check existence
- Returns JSON output that Terraform can parse
- Doesn't fail if RG doesn't exist (unlike azurerm data source)

**Conditional Provisioning:**
```hcl
resource "null_resource" "ensure_rg_exists" {
  provisioner "local-exec" {
    when = create
    command = "if RG doesn't exist: az group create"
  }
  
  provisioner "local-exec" {
    when = destroy
    command = "if we created it: az group delete"
  }
  
  triggers = {
    was_provisioned = "true/false"  # Stored for destroy decision
  }
}
```

---

## Test Files

### 1. `azure_resource_group.tftest.hcl`

**Purpose:** Tests the creation of a **new** Resource Group using the module.

**Test Scenario:**
- Provides all required variables (region, app_name, environment, etc.)
- Does NOT provide `custom_resource_group_name` (empty/not provided)
- Module should create a new Resource Group with generated name

**Test Structure:**
```hcl
run "integration_test_create_resource_group" {
  command = apply
  
  variables {
    region = "eastus"
    app_name = "IaC"
    component_name = "testing-resource-group"
    environment = "dev"
    environment_number_suffix = "001"
    # custom_resource_group_name = NOT PROVIDED (creates new RG)
  }
  
  assert {
    condition = output.name matches naming convention
    condition = output.location matches input region
    condition = output.tags are applied correctly
  }
}
```

**Expected Outcome:**
- New Resource Group created with naming convention: `rg-<app_name>-<component_name>-<environment>-<suffix>`
- All tags applied correctly
- Proper location set

---

### 2. `azure_resource_group_existing.tftest.hcl`

**Purpose:** Tests the usage of an **existing** Resource Group by the module.

**Test Scenario:**
- Uses setup module to ensure Resource Group exists
- Provides `custom_resource_group_name` to the main module
- Module should use the existing RG (data source lookup)

**Test Structure:**

```hcl
# Step 1: Setup - Ensure RG exists
run "setup_tests" {
  module { source = "./setup" }
  
  variables {
    custom_resource_group_name = var.custom_resource_group_name
    region = var.region
    # ... other variables
  }
}

# Step 2: Test - Use existing RG
run "integration_test_use_existing_resource_group" {
  command = apply
  
  variables {
    # Provide the RG name from setup
    custom_resource_group_name = run.setup_tests.resource_group_name
    # ... other variables
  }
  
  assert {
    condition = output.name == custom_resource_group_name
    condition = output.name is not empty
    condition = output.name follows naming convention
  }
}
```

**Expected Outcome:**
- Setup ensures Resource Group exists (creates if needed)
- Main module uses existing Resource Group (data source)
- No duplicate Resource Groups created
- Existing RG is preserved after test cleanup

---

## Running the Tests

### Prerequisites

1. **Azure CLI Authentication**
   ```powershell
   az login
   # Or use service principal in pipeline
   ```

2. **Required Environment Variables**
   Create a `terraform.tfvars` file with:
   ```hcl
   region                           = "eastus"
   app_name                         = "IaC"
   environment                      = "dev"
   environment_number_suffix        = "001"
   custom_resource_group_name       = "rg-IaC-testing-resource-group-dev-001"
   INTEGRATION_TEST_SUBSCRIPTION_ID = "your-subscription-id"
   TENANT_ID                        = "your-tenant-id"
   common_tags = {
     Environment = "Development"
     ManagedBy   = "Terraform"
   }
   ```

### Running Individual Tests

**Test 1: Create New Resource Group**
```powershell
cd terraform/tests/azure_resource_group/integration_tests
terraform init
terraform test -filter=azure_resource_group.tftest.hcl
```

**Test 2: Use Existing Resource Group**
```powershell
cd terraform/tests/azure_resource_group/integration_tests
terraform init
terraform test -filter=azure_resource_group_existing.tftest.hcl
```

**Run All Tests**
```powershell
cd terraform/tests/azure_resource_group/integration_tests
terraform init
terraform test
```

### Test Execution Flow

```
┌─────────────────────────────────────────────────────────────┐
│              Terraform Test Lifecycle                        │
└─────────────────────────────────────────────────────────────┘

Phase 1: Initialization
├─ terraform init
└─ Download providers (azurerm, null, external)

Phase 2: Test Execution (Sequential)
├─ Run Block 1: setup_tests
│  ├─ Check if RG exists
│  ├─ Create if needed
│  └─ Output: resource_group_name
│     └─ RG exists in Azure ✅
│
├─ Run Block 2: integration_test
│  ├─ Use: run.setup_tests.resource_group_name
│  ├─ Test module functionality
│  └─ Validate assertions
│     └─ RG still exists in Azure ✅
│
└─ All run blocks complete ✅

Phase 3: Automatic Cleanup (Reverse Order)
├─ Destroy: integration_test resources
└─ Destroy: setup_tests resources
   └─ Check: triggers.was_provisioned
      ├─ "true"  → Delete RG from Azure ✅
      └─ "false" → Preserve RG (was pre-existing) ✅
```

---

## Common Scenarios & Solutions

### Scenario 1: Testing with Clean Azure Subscription
```
Situation: No pre-existing Resource Groups
Setup Behavior: Creates new RG
Test Behavior: Uses the newly created RG
Cleanup Behavior: Deletes the RG after tests complete
```

### Scenario 2: Testing with Existing Resource Group
```
Situation: RG already exists in Azure
Setup Behavior: Uses existing RG (no creation)
Test Behavior: Uses the existing RG
Cleanup Behavior: Preserves the RG (doesn't delete)
```

### Scenario 3: Skipping Tests
```
Situation: custom_resource_group_name variable is empty
Setup Behavior: Skips all operations (count = 0)
Test Behavior: Tests don't run or use alternative path
Cleanup Behavior: Nothing to clean up
```

---


## Best Practices

### 1. **Always Use Setup Module for Existing RG Tests**
Don't assume Resource Groups exist; use the setup module to ensure they're available.

### 2. **Don't Hardcode Subscription IDs**
Use variables for `INTEGRATION_TEST_SUBSCRIPTION_ID` and `TENANT_ID`

### 3. **Tag All Test Resources**
Apply tags like `Test_Type="Terraform_Test"` and `Temporary="true"` for easy identification

### 4. **Use Naming Conventions**
Follow the pattern: `rg-<app>-<component>-<env>-<number>`

### 5. **Verify in Azure Portal**
After tests, check Azure Portal to confirm:
- Resource Groups were created correctly
- Cleanup happened as expected
- No orphaned resources remain

---

## CI/CD Pipeline Integration

### Pipeline Configuration Example

```yaml
- task: TerraformCLI@0
  displayName: 'Run Integration Tests'
  inputs:
    command: 'test'
    workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/tests/azure_resource_group/integration_tests'
    environmentServiceNameAzureRM: '$(azureServiceConnection)'
  env:
    ARM_USE_OIDC: true
    ARM_SUBSCRIPTION_ID: $(INTEGRATION_TEST_SUBSCRIPTION_ID)
    ARM_TENANT_ID: $(TENANT_ID)
```

### Pipeline Prerequisites
- Service Principal with permissions:
  - `Contributor` role on subscription (for RG creation)
  - Or `Reader` + pre-existing Resource Group
- Variables configured in Azure DevOps Library
- Azure CLI available on build agent

---





