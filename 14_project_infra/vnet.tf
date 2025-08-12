# Generate a random hostname for the load balancer to ensure unique DNS names
resource "random_pet" "lb_hostname" {

}

# Resource group to organize and manage all related resources together
# Provides logical grouping for cost management, access control, and resource lifecycle
resource "azurerm_resource_group" "rg" {
  name = "day14--rg"
  location = var.allowed_locations[0]
  tags = var.resource_tags
}

# Virtual network provides network isolation and IP address space for the application
# Enables secure communication between resources while maintaining network segmentation
resource "azurerm_virtual_network" "vnet" {
  name = "terraformvnet"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet segments the virtual network for better network management and security
# Allows for granular control over network policies and routing
resource "azurerm_subnet" "subnet" {
  name = "subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.0.0/20" ]
}

# Network Security Group controls inbound and outbound traffic flow
# Implements network-level security policies to protect application resources
resource "azurerm_network_security_group" "nsg" {
  name = "dgnsg"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow HTTP traffic for web application access
  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS traffic for secure web application access
  security_rule {
    name                       = "allow-https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH access for remote administration and troubleshooting
  security_rule {
    name                       = "allow-ssh"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
}

# Associates NSG with subnet to apply security policies to all resources in the subnet
# Ensures consistent security enforcement across all network traffic
resource "azurerm_subnet_network_security_group_association" "subnetnsgass" {
  subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  
}

# Public IP address for the load balancer to provide external access
# Enables internet-facing access to the application through a stable, public endpoint
resource "azurerm_public_ip" "pip" {
  name = "lb-publicIP"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  sku = "Standard"
  zones = [ "1","2","3"]
  domain_name_label = "${azurerm_resource_group.rg.name}-${random_pet.lb_hostname.id}"
}

# Load balancer distributes incoming traffic across multiple backend instances
# Provides high availability and scalability by preventing single points of failure
resource "azurerm_lb" "lb" {
  name = "lb-dj"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku = "Standard"
  frontend_ip_configuration {
    name = "myPublicIP" # does not have to match the of the pupic ip resource
    public_ip_address_id = azurerm_public_ip.pip.id
  }  
}

# Backend address pool defines the group of backend instances that receive traffic
# Enables load balancer to distribute requests across multiple servers for better performance
resource "azurerm_lb_backend_address_pool" "bepool" {
  name = "backendadresspool"
  loadbalancer_id = azurerm_lb.lb.id
}



# Health probe monitors backend instance health to ensure traffic only goes to healthy instances
# Automatically removes unhealthy instances from the load balancer rotation
resource "azurerm_lb_probe" "lb_probe" {
  name = "http_probe"
  loadbalancer_id = azurerm_lb.lb.id
  port = 80
  protocol = "Http"
  request_path = "/"
}

# Load balancer rule defines how traffic is distributed from frontend to backend
# Routes HTTP traffic to backend instances while maintaining session affinity and health checks
resource "azurerm_lb_rule" "lb_rule_be" {
  name = "http"
  loadbalancer_id = azurerm_lb.lb.id
  frontend_ip_configuration_name = "myPublicIP"
  protocol = "Tcp"
  frontend_port = 80 # The port on which the load balancer listens
  backend_port = 80 # The port to which traffic is forwarded
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.bepool.id ]
  probe_id = azurerm_lb_probe.lb_probe.id
}

# NAT rule enables direct SSH access to specific backend instances for administration
# Maps external ports to internal SSH ports, allowing secure remote access to individual servers
resource "azurerm_lb_nat_rule" "lb_nat_rule" {
  name = "ssh"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id = azurerm_lb.lb.id
  protocol = "Tcp"
  frontend_port_start = 50000
  frontend_port_end =   50119
  backend_port = 22
  frontend_ip_configuration_name = "myPublicIP"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bepool.id
}

# Public IP for NAT Gateway to enable outbound internet access for private resources
# Provides internet connectivity for backend instances without exposing them directly
resource "azurerm_public_ip" "atgwpip" {
  name = "natgw-publicIP"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method = "Static"
  sku = "Standard"
  zones = [ "1" ]
}

# NAT Gateway enables private resources to access the internet while remaining secure
# Translates private IP addresses to public IP for outbound traffic, hiding backend instances
resource "azurerm_nat_gateway" "natgw" {
  name = "nat-gw"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name = "Standard"
  idle_timeout_in_minutes = 10
  zones = ["1"]
}

# Associates NAT Gateway with subnet to enable outbound internet access for all resources
# Ensures all instances in the subnet can access external services (updates, APIs, etc.)
resource "azurerm_subnet_nat_gateway_association" "sngw_ass" {
  subnet_id = azurerm_subnet.subnet.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}

# Associates public IP with NAT Gateway to provide internet connectivity
# Enables the NAT Gateway to translate private traffic to public internet access
resource "azurerm_nat_gateway_public_ip_association" "nw_ip" {
  public_ip_address_id = azurerm_public_ip.atgwpip.id
  nat_gateway_id = azurerm_nat_gateway.natgw.id
}
