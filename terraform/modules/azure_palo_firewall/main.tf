#-------------------------------------------------------------------------------------------
# Palo Alto Firewall Resource Creation
#-------------------------------------------------------------------------------------------

#---------------------------------------------------------
# Data Sources for Subnets
#----------------------------------------------------------

data "azurerm_subnet" "management" {
  name                 = var.management_subnet_name
  virtual_network_name = var.custom_vnet_name
  resource_group_name  = var.custom_vnet_resource_group_name
}

data "azurerm_subnet" "untrust" {
  name                 = var.untrust_subnet_name
  virtual_network_name = var.custom_vnet_name
  resource_group_name  = var.custom_vnet_resource_group_name
}

data "azurerm_subnet" "trust" {
  name                 = var.trust_subnet_name
  virtual_network_name = var.custom_vnet_name
  resource_group_name  = var.custom_vnet_resource_group_name
}

#---------------------------------------------------------
# NSG Data Source
#----------------------------------------------------------

data "azurerm_network_security_group" "firewall_nsg" {
  count               = var.network_security_group_name != null ? 1 : 0
  name                = var.network_security_group_name
  resource_group_name = var.network_security_group_resource_group_name != null ? var.network_security_group_resource_group_name : module.base.resource_group_name
}

#---------------------------------------------------------
# Palo Alto Firewall VM Creation
#----------------------------------------------------------

# Public IP for Management Interface
resource "azurerm_public_ip" "palo_mgmt_pip" {
  name                    = "pip-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
  location                = module.base.location
  resource_group_name     = module.base.resource_group_name
  allocation_method       = var.public_ip_allocation_method
  sku                     = var.public_ip_sku
  sku_tier                = var.public_ip_sku_tier
  domain_name_label       = "${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
  idle_timeout_in_minutes = var.public_ip_idle_timeout

  # tags
  tags = module.base.tags
}

# Management Network Interface (eth0)
resource "azurerm_network_interface" "palo_mgmt_nic" {
  name                           = "nic-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}-eth0-mgmt"
  location                       = module.base.location
  resource_group_name            = module.base.resource_group_name
  accelerated_networking_enabled = var.mgmt_accelerated_networking_enabled
  ip_forwarding_enabled          = var.mgmt_ip_forwarding_enabled

  ip_configuration {
    name                          = "ipconfig-mgmt"
    subnet_id                     = data.azurerm_subnet.management.id
    private_ip_address_allocation = var.mgmt_private_ip_allocation
    private_ip_address            = var.mgmt_private_ip_allocation == "Static" ? var.mgmt_static_private_ip : null
    public_ip_address_id          = azurerm_public_ip.palo_mgmt_pip.id
    primary                       = true
  }

  # tags
  tags = module.base.tags
}

# Associate NSG with Management Interface
resource "azurerm_network_interface_security_group_association" "mgmt_nsg_association" {
  count                     = var.network_security_group_name != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.palo_mgmt_nic.id
  network_security_group_id = data.azurerm_network_security_group.firewall_nsg[0].id
}

# Untrust Network Interface (eth1)
resource "azurerm_network_interface" "palo_untrust_nic" {
  name                           = "nic-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}-eth1-untrust"
  location                       = module.base.location
  resource_group_name            = module.base.resource_group_name
  accelerated_networking_enabled = var.untrust_accelerated_networking_enabled
  ip_forwarding_enabled          = var.untrust_ip_forwarding_enabled

  ip_configuration {
    name                          = "ipconfig-public"
    subnet_id                     = data.azurerm_subnet.untrust.id
    private_ip_address_allocation = var.untrust_private_ip_allocation
    private_ip_address            = var.untrust_private_ip_allocation == "Static" ? var.untrust_static_private_ip : null
    primary                       = true
  }

  # tags
  tags = module.base.tags
}

# Associate NSG with Untrust Interface
resource "azurerm_network_interface_security_group_association" "untrust_nsg_association" {
  count                     = var.network_security_group_name != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.palo_untrust_nic.id
  network_security_group_id = data.azurerm_network_security_group.firewall_nsg[0].id
}

# Trust Network Interface (eth2)
resource "azurerm_network_interface" "palo_trust_nic" {
  name                           = "nic-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}-eth2-trust"
  location                       = module.base.location
  resource_group_name            = module.base.resource_group_name
  accelerated_networking_enabled = var.trust_accelerated_networking_enabled
  ip_forwarding_enabled          = var.trust_ip_forwarding_enabled

  ip_configuration {
    name                          = "ipconfig-private"
    subnet_id                     = data.azurerm_subnet.trust.id
    private_ip_address_allocation = var.trust_private_ip_allocation
    private_ip_address            = var.trust_private_ip_allocation == "Static" ? var.trust_static_private_ip : null
    primary                       = true
  }

  # tags
  tags = module.base.tags
}

# Associate NSG with Trust Interface
resource "azurerm_network_interface_security_group_association" "trust_nsg_association" {
  count                     = var.network_security_group_name != null ? 1 : 0
  network_interface_id      = azurerm_network_interface.palo_trust_nic.id
  network_security_group_id = data.azurerm_network_security_group.firewall_nsg[0].id
}

# Availability Set (optional but recommended for production)
resource "azurerm_availability_set" "palo_alto_avset" {
  count                       = var.enable_availability_set ? 1 : 0
  name                        = "avset-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
  location                    = module.base.location
  resource_group_name         = module.base.resource_group_name
  platform_fault_domain_count = var.availability_set_fault_domain_count
  managed                     = true

  # tags
  tags = module.base.tags
}

# Palo Alto VM
resource "azurerm_linux_virtual_machine" "palo_alto_vm" {
  name                = "vm-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"
  location            = module.base.location
  resource_group_name = module.base.resource_group_name
  size                = var.vm_size
  computer_name       = var.computer_name != null ? var.computer_name : "vm-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"

  # Availability Configuration (Availability Set or Zones - mutually exclusive)
  availability_set_id = var.enable_availability_zones ? null : (var.enable_availability_set ? azurerm_availability_set.palo_alto_avset[0].id : null)
  zone                = var.enable_availability_zones ? var.availability_zone : null

  # Network Interfaces (order matters!)
  network_interface_ids = [
    azurerm_network_interface.palo_mgmt_nic.id,
    azurerm_network_interface.palo_untrust_nic.id,
    azurerm_network_interface.palo_trust_nic.id
  ]

  # Authentication
  admin_username                  = var.admin_username
  disable_password_authentication = var.disable_password_authentication

  # SSH Keys Configuration
  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_keys
    content {
      username   = admin_ssh_key.value.username
      public_key = admin_ssh_key.value.public_key
    }
  }

  # VM Configuration
  provision_vm_agent         = var.provision_vm_agent
  allow_extension_operations = var.allow_extension_operations
  patch_mode                 = var.patch_mode
  patch_assessment_mode      = var.patch_assessment_mode
  extensions_time_budget     = var.extensions_time_budget

  # OS Disk
  os_disk {
    name                 = "${var.computer_name != null ? var.computer_name : "vm-${module.base.app_name}-${module.base.environment}-${module.base.environment_number_suffix}"}_OsDisk"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  # Palo Alto VM-Series Image
  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  # Plan for Marketplace Image
  plan {
    name      = var.vm_image_sku
    product   = var.vm_image_offer
    publisher = var.vm_image_publisher
  }

  # Bootstrap Configuration (optional)
  custom_data = var.custom_data != null ? base64encode(var.custom_data) : null

  # tags
  tags = module.base.tags

  # Forcing dependencies and deployment order to allow the resource group to be deployed first.
  depends_on = [module.base]
}