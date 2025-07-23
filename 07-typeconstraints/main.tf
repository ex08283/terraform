resource "azurerm_resource_group" "example" {
  name     = "${var.environment}-resources"
  location = var.allowed_locations[0] # Use the first allowed location from the list
  tags = {
    businesscriticality = var.resource_tags.businesscriticality
    businessunit        = var.resource_tags.businessunit
    costcentre         = var.resource_tags.costcentre
    dataclassification = var.resource_tags.dataclassification
    workloadname       = var.resource_tags.workloadname
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.environment}-network"
  address_space       = [var.network_config[0]]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["${var.network_config[1]}/${var.network_config[2]}"] # Use the second element of the tuple for the subnet address space
}

resource "azurerm_network_interface" "main" {
  name                = "${var.environment}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.environment}-vm"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.allowed_vm_sizes[0] # Use the first allowed VM size from the set

  # Uncomment this line to delete the OS disk automatically when deleting the VM
   delete_os_disk_on_termination = var.is_delete

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = var.vm_config.publisher
    offer     = var.vm_config.offer
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb = var.storage_disk
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
    environment = var.environment
  }
}