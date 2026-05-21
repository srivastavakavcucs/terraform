#####################################
## Azure Function App - Linux Python
#####################################
module "azure_function" {
  source = "./../modules/azure_function"

  region                    = "eastus"
  app_name                  = "sampleapp"
  environment               = "dev"
  environment_number_suffix = "001"

  os_type                    = "Linux"
  service_plan_id            = "/subscriptions/<subscription_id>/resourceGroups/<rg_name>/providers/Microsoft.Web/serverfarms/<plan_name>"
  storage_account_name       = "sampleappstorage001"
  storage_account_access_key = "<storage_access_key>"
  runtime                    = "python"
  runtime_version            = "3.11"

  common_tags = {
    Business_Unit        = "Finance"
    Workload             = "Application"
    Business_Criticality = "Gold"
    Owner                = "Digital Team"
    Operations_Team      = "Cloud Engineering"
    Cost_Center          = "701"
  }
}
