
#-------------------------------------------------------------------------------------------
# Locals
#-------------------------------------------------------------------------------------------

locals {
  #-------------------------------------------------------------------------------------------
  # Generate the routes for the route table.
  #-------------------------------------------------------------------------------------------

  # Local variable to process and generate the route names
  routes = {
    for route in var.routes :
    "${replace(route.destination_name, " ", "-")}-${replace(route.address_prefix, "/", "_")}" => {
      name                   = "${replace(route.destination_name, " ", "-")}-${replace(route.address_prefix, "/", "_")}"
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = try(route.next_hop_in_ip_address, null)
    }
  }
}
