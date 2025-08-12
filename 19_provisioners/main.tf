# =====================================================================
# TERRAFORM PROVISIONERS EXPLANATION
# =====================================================================
# 
# WHAT ARE PROVISIONERS?
# Provisioners in Terraform are used to execute scripts or commands on 
# a local machine or on remote resources after they have been created.
# They are typically used for bootstrapping, configuration management,
# or running cleanup tasks.
#
# WHY USE PROVISIONERS?
# - Bootstrap virtual machines with software installation
# - Configure applications and services after resource creation
# - Copy files to remote systems
# - Execute initialization scripts
# - Perform cleanup or preparation tasks
#
# TYPES OF PROVISIONERS USED IN THIS DEMO:
# 1. local-exec: Runs commands on the machine running Terraform
# 2. remote-exec: Runs commands on the remote resource via SSH/WinRM
# 3. file: Copies files from local machine to remote resource
#
# NOTE: Provisioners should be used sparingly as they can make 
# infrastructure less predictable. Consider using cloud-init, 
# configuration management tools, or custom images when possible.
# =====================================================================

# Terraform Provioners demo

resource "azurerm_resource_group" "app_rg" {
  name = "provisioner-demo-rg"
  location = "UK South"

  tags = var.resource_tags
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "demo-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
}

# Subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.app_rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "vm-nsg"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP
resource "azurerm_public_ip" "vm_ip" {
  name                = "demo-public-ip"
  location            = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name
  allocation_method   = "Static"
sku = "Standard"
  zones = [ "1","2","3"]
}

resource "azurerm_network_interface" "name" {
  name = "demo-nic"
  location = azurerm_resource_group.app_rg.location
  resource_group_name = azurerm_resource_group.app_rg.name

  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.vm_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id = azurerm_network_interface.name.id
    network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# =====================================================================
# LOCAL-EXEC PROVISIONER EXAMPLE
# =====================================================================
# This null_resource demonstrates the local-exec provisioner.
# 
# PURPOSE: 
# - Executes commands on the LOCAL machine where Terraform is running
# - Useful for preparation tasks, logging, or triggering external systems
# - In this case, it creates a deployment log file with a timestamp
#
# TRIGGERS:
# - Uses timestamp() to ensure it runs every time (always_run trigger)
# - Could be configured to run only when specific resources change
#
# USE CASES:
# - Creating backup files before deployment
# - Sending notifications to external systems
# - Preparing configuration files
# - Running local scripts or utilities
# =====================================================================
resource "null_resource" "deployment_prep" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Deployment started at ${timestamp()}' > deployment.log"
  }
}


resource "azurerm_linux_virtual_machine" "demo_vm" {
    name = "demo-vm"
    location              = azurerm_resource_group.app_rg.location
    resource_group_name   = azurerm_resource_group.app_rg.name
    network_interface_ids = [azurerm_network_interface.name.id]
    size                  = "Standard_B1s"

    # Ensure deployment preparation completes before VM creation
    depends_on = [ null_resource.deployment_prep ]

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    }

      source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
   
     computer_name                   = "demovm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username = "azureuser"
    public_key = file(".ssh/azure_key.pub")
  }

  # =====================================================================
  # REMOTE-EXEC PROVISIONER EXAMPLE
  # =====================================================================
  # This provisioner executes commands on the REMOTE virtual machine
  # after it has been created and is accessible via SSH.
  #
  # PURPOSE:
  # - Install and configure software on the remote system
  # - Bootstrap the VM with necessary applications
  # - Set up services and ensure they're running
  #
  # IN THIS EXAMPLE:
  # - Updates the package repository (apt-get update)
  # - Installs nginx web server
  # - Creates a custom HTML page
  # - Starts and enables the nginx service
  #
  # CONNECTION BLOCK:
  # - Defines how Terraform connects to the remote resource
  # - Uses SSH with private key authentication
  # - Connects to the public IP address of the VM
  #
  # USE CASES:
  # - Installing applications and dependencies
  # - Configuring services and daemons
  # - Setting up monitoring agents
  # - Running initialization scripts
  # =====================================================================
  provisioner "remote-exec" {
    inline = [   
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      
      # Create a sample welcome page
      "echo '<html><body><h1>#28daysofAZTerraform is Awesome!</h1></body></html>' | sudo tee /var/www/html/index.html",
      
      # Ensure nginx is running
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx" ]

    connection {
      type = "ssh"
      user = "azureuser"
      private_key = file(".ssh/azure_key")
      host = azurerm_public_ip.vm_ip.ip_address
    }
  }

  # =====================================================================
  # FILE PROVISIONER EXAMPLE
  # =====================================================================
  # This provisioner copies files from the LOCAL machine to the 
  # REMOTE virtual machine.
  #
  # PURPOSE:
  # - Transfer configuration files to remote systems
  # - Copy application code or assets
  # - Deploy certificates or keys
  # - Transfer custom scripts or utilities
  #
  # IN THIS EXAMPLE:
  # - Copies a configuration file from local "configs/sample.conf"
  # - Places it in the user's home directory on the remote VM
  #
  # CONNECTION BLOCK:
  # - Same SSH connection configuration as remote-exec
  # - Ensures secure file transfer over SSH
  #
  # USE CASES:
  # - Deploying application configuration files
  # - Copying SSL certificates
  # - Transferring custom scripts or binaries
  # - Deploying static assets or content
  #
  # NOTE: The file provisioner only copies files; you may need
  # remote-exec afterward to move, modify permissions, or process them
  # =====================================================================
  provisioner "file" {
    source = "configs/sample.conf"
    destination = "/home/azureuser/sample.conf"

    connection {
      type = "ssh"
      user = "azureuser"
      private_key = file(".ssh/azure_key")
      host = azurerm_public_ip.vm_ip.ip_address
    }
  }
}


# Outputs
output "vm_public_ip" {
  value = azurerm_public_ip.vm_ip.ip_address
}


#ssh into it using the private key using ssh -i .ssh/azure_key azureuser@172.166.83.80