# We have to create a vm in the shared network and we have to use the data sources to get the resource group, virtual network and subnet
# The vm has to be created different resource group than the shared network

variable "prefix" {
  default = "day13"
  type = string
}


data "azurerm_resource_group" "rg-shared" {
  name = "shared-network-rg"
}

data "azurerm_virtual_network" "vnet-shared" {
  name = "shared-network-vnet"
  resource_group_name = data.azurerm_resource_group.rg-shared.name
}


data "azurerm_subnet" "sn-shared" {
  name = "shared-primary-sn"
  resource_group_name = data.azurerm_resource_group.rg-shared.name
  virtual_network_name = data.azurerm_virtual_network.vnet-shared.name
}

resource "azurerm_resource_group" "rg" {
  name = "${var.prefix}-rg"
  location = data.azurerm_resource_group.rg-shared.location
  tags = var.resource_tags
}

resource "azurerm_network_interface" "nic" {
  name = "${var.prefix}-nic"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name = "internal"
    subnet_id = data.azurerm_subnet.sn-shared.id
    private_ip_address_allocation = "Dynamic"
    }
}



resource "azurerm_virtual_machine" "main" {
  name = "${var.prefix}-vm"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [ azurerm_network_interface.nic.id ]
  vm_size = "Standard_DS1_v2"

  delete_os_disk_on_termination = true


  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}






# resource "azurerm_resource_group" "rg" {

# # With create_before_destroy = true in the lifecycle block of the resource group, if you make a change that requires replacing the resource group (like changing its name or location),
# # Terraform will first create the new resource group, move dependent resources (like storage accounts) to it, and only then destroy the old group. This prevents downtime and accidental deletion of dependent resources.


#   name     = "shared-network-rg"
#   location = var.allowed_locations[0] # Use the first allowed location from the list

# tags = var.resource_tags

# }


# resource "azurerm_virtual_network" "vnet" {
#   name = "shared-network-vnet"
#   location = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   address_space = ["10.0.0.0/16"]
# }

# resource "azurerm_subnet" "sn" {
#   name = "shared-primary-sn"
#   resource_group_name = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes = ["10.0.0.0/24"]
# }

