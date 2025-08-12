resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
    name = "vmss-tf"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    sku_name = "Standard_D2s_v4"
    instances = 3
    platform_fault_domain_count = 1
    zones = [ "1" ] 

    user_data_base64 = base64encode(file("user-data.sh"))

    os_profile {
      linux_configuration {
        disable_password_authentication = true
        admin_username = "azureuser"
        admin_ssh_key {
          username = "azureuser"
          public_key = file(".ssh/azure_key.pub")
        }
      }
    }
    source_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-LTS-gen2"
        version   = "latest"
    }

    os_disk {
      storage_account_type = "Premium_LRS"
      caching = "ReadWrite"
    }

    network_interface {
      name = "nic"
      primary = true
      enable_accelerated_networking = false

      ip_configuration {
        name = "ipconfig"
        primary = true
        subnet_id = azurerm_subnet.subnet.id
        load_balancer_backend_address_pool_ids = [ azurerm_lb_backend_address_pool.bepool.id ]
      }
    }

    boot_diagnostics {
      storage_account_uri = ""
    }

    lifecycle {
      ignore_changes = [ instances ]
    }

  
}

# Auto Scale Setting for VMSS
resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "vmss-autoscale"                                    # Name of the auto scale setting
  resource_group_name = azurerm_resource_group.rg.name                      # Resource group where auto scale is created
  location            = azurerm_resource_group.rg.location                  # Azure region for the auto scale setting
  target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.vmss.id  # ID of the VMSS to monitor

  profile {
    name = "autoscale"                                                      # Name of the auto scale profile

    capacity {
      default = 2                                                           # Default number of instances when auto scale is enabled
      minimum = 1                                                           # Minimum number of instances allowed
      maximum = 4                                                           # Maximum number of instances allowed
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"                               # Metric to monitor (CPU usage percentage)
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss.id  # Resource ID of the VMSS
        time_grain        = "PT1M"    # Collect data every 1 minute
        statistic          = "Average"                                       # Statistical function to apply (Average, Min, Max, Sum)
        time_window        = "PT3M"   # Look at the last 3 minutes
        time_aggregation   = "Average" # Average the values over that window
        operator           = "GreaterThan"                                   # Comparison operator (GreaterThan, LessThan, etc.)
        threshold          = 70                                              # CPU percentage threshold to trigger scaling
      }

      scale_action {
        direction = "Increase"                                               # Scale direction (Increase or Decrease)
        type      = "ChangeCount"                                           # Type of scaling action (ChangeCount, PercentChangeCount, etc.)
        value     = "1"                                                     # Number of instances to add/remove
        cooldown  = "PT5M"                                                  # Wait time before allowing another scale action
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"                               # Metric to monitor (CPU usage percentage)
        metric_resource_id = azurerm_orchestrated_virtual_machine_scale_set.vmss.id  # Resource ID of the VMSS
        time_grain        = "PT1M"    # Collect data every 1 minute
        statistic          = "Average"                                       # Statistical function to apply (Average, Min, Max, Sum)
        time_window        = "PT10M"  # Look at the last 10 minutes
        time_aggregation   = "Average" # Average the values over that window
        operator           = "LessThan"                                      # Comparison operator (GreaterThan, LessThan, etc.)
        threshold          = 30                                              # CPU percentage threshold to trigger scaling
      }

      scale_action {
        direction = "Decrease"                                               # Scale direction (Increase or Decrease)
        type      = "ChangeCount"                                           # Type of scaling action (ChangeCount, PercentChangeCount, etc.)
        value     = "1"                                                     # Number of instances to add/remove
        cooldown  = "PT5M"                                                  # Wait time before allowing another scale action
      }
    }
  }


}

