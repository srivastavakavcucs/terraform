# Variables for the Integration Tests

# Azure authentication configuration for test providers
INTEGRATION_TEST_SUBSCRIPTION_ID = "f7a6af2d-5a37-47a2-a3c2-fc832a0752f3"
SHARED_HUB_SUBSCRIPTION_ID       = "f7a6af2d-5a37-47a2-a3c2-fc832a0752f3"
TENANT_ID                        = "37bfc38e-7b8f-4bb9-8dd9-66212c4029da"

#--------------------------------------------------------
### Shared Vars
#--------------------------------------------------------
region                    = "eastus"
app_name                  = "IaC"
environment               = "dev"
environment_number_suffix = "001"


#--------------------------------------------------------
### Common_tags Vars
#--------------------------------------------------------
tags = {
  Business_Unit        = "IT"
  Workload             = "Application"
  Business_Criticality = "Gold"
  Owner                = "Infrastructure Automation/IaC"
  Operations_Team      = "Cloud Engineering"
  Cost_Center          = "701"
}

# TODO: Remove after refactoring all the code to remove all references to common_tags
### Common_tags Vars
common_tags = {
  Business_Unit        = "IT"
  Workload             = "Application"
  Business_Criticality = "Gold"
  Owner                = "Infrastructure Automation/IaC"
  Operations_Team      = "Cloud Engineering"
  Cost_Center          = "701"
}

# Add these to override Component resource group
custom_resource_group_name = "rg-iac-terraform-testing"

# Add these to override VNet and Vnet resource group
custom_vnet_name                       = "vnet-hub01-shared01-eu-vy"
custom_vnet_resource_group_name        = "rg-iac-terraform-testing"
