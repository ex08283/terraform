locals {
  # replace() function: Converts spaces to hyphens and lower() function: Converts to lowercase
  # This ensures consistent naming convention for Azure resources (lowercase with hyphens)
  # Example: "Project ALPHA Resource" → "project-alpha-resource"
  formatted_name = replace(lower(var.project_name)," ","-")
  
  # split() function: Splits a string into a list based on the specified delimiter
  # This converts the comma-separated string of ports into individual port values
  # Example: "80,443,3306" → ["80", "443", "3306"]
  formatted_ports = split(",",var.allowed_ports)
  
  # For loop that creates NSG rules for each port in the formatted_ports list
  # This loop iterates through each port (e.g., "80", "443", "3306") and creates a map object for each
  # The syntax [for item in list : expression] creates a list of results from the expression
  # Each iteration creates a map with: name (port-{port}), port (the actual port), and description
  # Example: for port "80" → {name = "port-80", port = "80", description = "allowed traffic on port:80"}
  nsg_rules = [for port in local.formatted_ports : {
    name = "port-${port}"
    port = port
    description = "allowed traffic on port:${port}"
  }]

  # lookup() function: Retrieves a value from a map using a key, with a fallback default value
  # This function looks up the VM size based on the environment (dev/staging/prod)
  # If the environment key doesn't exist in the map, it returns "standard_D4s_v3" as fallback
  # This provides environment-specific VM sizing with a safe default
  vm_size = lookup(var.vm_sizes,var.environment,"standard_D4s_v3")

  user_location = ["eastus","westus","eastus"]
  default_location = ["centralus"]
   
  # toset() and concat() functions working together to create a unique set of locations
  # concat() function: Combines multiple lists into a single list
  # This example concatenates user_location with itself: ["eastus","westus","eastus"] + ["eastus","westus","eastus"]
  # toset() function: Converts a list to a set, automatically removing duplicates
  # Result: ["eastus", "westus"] (duplicate "eastus" is removed)
  # This is useful for ensuring unique values when combining multiple location lists
  unique_location = toset(concat(local.user_location,local.user_location))


  monthly_cost = [-50,100,75,200]
  
  # For loop with abs() function: Converts all costs to positive values
  # abs() function: Returns the absolute value of a number (removes negative sign)
  # This loop iterates through each cost and applies abs() to handle credits/refunds
  # Example: [-50,100,75,200] → [50,100,75,200] (negative becomes positive)
  positive_cost = [for cost in local.monthly_cost : abs(cost)]
  
  # max() function with spread operator (...): Finds the highest value in the list
  # The spread operator (...) expands the list into individual arguments for the max() function
  # This finds the maximum cost after converting all values to positive
  # Example: max(50,100,75,200) → 200 (highest value)
  max_cost = max(local.positive_cost...)

  # timestamp() function: Returns the current timestamp as a string
  # This provides the current date and time when Terraform runs
  # Example: "2024-01-15T10:30:45Z"
  current_time = timestamp()
  
  # formatdate() function: Formats a timestamp using a specific date format
  # "YYYYMMDD" format creates a date string suitable for resource naming
  # Example: "20240115" (for January 15, 2024)
  resource_name = formatdate("YYYYMMDD",local.current_time)
  
  # formatdate() function with "DD-MM-YYY" format for tag dates
  # This creates a more readable date format for resource tagging
  # Example: "15-01-2024" (for January 15, 2024)
  tag_date = formatdate("DD-MM-YYY",local.current_time)

  # file() function: Reads the contents of a file as a string
  # sensitive() function: Marks the content as sensitive to prevent exposure in logs
  # This is used for reading configuration files that may contain sensitive data
  # Note: The file "config.json" must exist in the same directory as the Terraform files
  config_content = sensitive(file("config.json"))

}

resource "azurerm_resource_group" "example" {

# With create_before_destroy = true in the lifecycle block of the resource group, if you make a change that requires replacing the resource group (like changing its name or location),
# Terraform will first create the new resource group, move dependent resources (like storage accounts) to it, and only then destroy the old group. This prevents downtime and accidental deletion of dependent resources.


  name     = "${local.formatted_name}-resources"
  location = var.allowed_locations[0] # Use the first allowed location from the list

tags = var.resource_tags

}

resource "azurerm_network_security_group" "nsg" {
  name = "${local.formatted_name}-nsg"
  location = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  
  #The dynamic block lets you programmatically generate nested blocks in Terraform resources
  dynamic "security_rule" {
    for_each = local.nsg_rules
    content {
      name = security_rule.key
      priority = 100
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = security_rule.value.port
      source_address_prefix = "*"
      destination_address_prefix = "*"
      description = security_rule.value.description
      
    }
  }
  
}


  


# Output the name of the created resource group
# This is useful for referencing the resource group in other modules or for CI/CD pipelines
output "rgname" {
  value = azurerm_resource_group.example.name
}

# Output the network security group rules configuration
# This displays the dynamically generated NSG rules based on the allowed_ports variable
# Each rule includes name, port, and description for network security configuration
output "nsg_rules" {
  value = local.nsg_rules
  
}

# Output the VM size configuration
# This shows the VM size determined by the lookup function based on environment
# The lookup function provides a fallback to "standard_D4s_v3" if the environment key doesn't exist
output "vm_size" {  
  value = local.vm_size
  
}

# Output the backup name variable
# This displays the backup name as defined in the variables, useful for backup management
output "backup" {
  value = var.backup_name
}


# Output the credential variable with sensitive flag
# The sensitive = true attribute prevents Terraform from displaying this value in logs and output
# This is crucial for security as credentials should never be exposed in plain text
# Terraform will show <sensitive> instead of the actual value when displaying outputs
output "credential" {
  value = var.credential
  sensitive = true
}


output "unique_location" {
  value = local.unique_location
}

output "max_cost" {
  value = local.max_cost
}

output "positive_cost" {
  value = local.positive_cost
}


output "resource_tags" {
  value = local.tag_date
}


# Output the decoded configuration content from the JSON file
# jsondecode() function: Parses a JSON string and converts it to a Terraform object/map
# This function takes the JSON content from config.json and converts it to a structured format
# nonsensitive() function: Removes the sensitive flag from a value to allow it to be displayed
# This is necessary because the original config_content was marked as sensitive with sensitive()
# The combination allows us to safely read sensitive JSON files and display their decoded content
# Example: {"name": "delawar"} becomes a Terraform map that can be accessed and displayed
output "config_content" {
  value = nonsensitive(jsondecode(local.config_content))
}