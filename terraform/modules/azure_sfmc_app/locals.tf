/*
--------------------------------------------------------------------------------
  MODULE LOCALS
--------------------------------------------------------------------------------
*/

locals {
  sfmc_id                       = data.azapi_resource.sfmc.id
  managed_identity_id           = data.azapi_resource.sfmc_managed_identity.id
  managed_identity_principal_id = jsondecode(data.azapi_resource.sfmc_managed_identity.output).properties.principalId
}

