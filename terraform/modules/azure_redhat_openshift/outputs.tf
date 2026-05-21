#-----------------------------------------------------------------------------------------
# Output details about the Azure Red Hat OpenShift Cluster that was provisioned.
#-----------------------------------------------------------------------------------------

# Output the OpenShift Cluster's Name
output "name" {
  description = "The name of the Azure Red Hat OpenShift cluster."
  value       = azurerm_redhat_openshift_cluster.this.name
}

# Output the OpenShift Cluster's Resource Group Name
output "resource_group_name" {
  description = "The resource group name of the Azure Red Hat OpenShift cluster."
  value       = azurerm_redhat_openshift_cluster.this.resource_group_name
}

# Output the OpenShift Cluster's Console URL
output "console_url" {
  description = "The URL for the console of the Azure Red Hat OpenShift cluster."
  value       = azurerm_redhat_openshift_cluster.this.console_url
}

# Output the OpenShift Cluster's Profile
output "cluster_profile" {
  description = "The profile of the Azure Red Hat OpenShift cluster."
  value = {
    resource_group_id = azurerm_redhat_openshift_cluster.this.cluster_profile[0].resource_group_id
  }
}

# Output the OpenShift Cluster's API Server Profile
output "api_server_profile" {
  description = "The API server profile of the Azure Red Hat OpenShift cluster."
  value = {
    ip_address = azurerm_redhat_openshift_cluster.this.api_server_profile[0].ip_address
    url        = azurerm_redhat_openshift_cluster.this.api_server_profile[0].url
  }
}

# Output the OpenShift Cluster's Ingress Profile
output "ingress_profile" {
  description = "The ingress profile of the Azure Red Hat OpenShift cluster."
  value = [
    for ingress in azurerm_redhat_openshift_cluster.this.ingress_profile : {
      name       = ingress.name
      ip_address = ingress.ip_address
    }
  ]
}
