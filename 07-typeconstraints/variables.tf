
variable "environment" {
  type    = string # Type of the variable, which is a string
  default = "staging" # Default value for the variable
  description = "The environment for the resources, e.g., dev, test, prod" # Description of the variable
}

variable "storage_disk" {
  type = number
  description = "the storage disk size in GB"
  default = 80
}

variable "is_delete" {
  type = bool
  default = true  
  description = "value to delete the OS disk on termination"
}

# allow duplicate values in the list
# a list is an ordered collection of elements, where each element can be of any type
variable "allowed_locations" {
  type = list(string)
  default = ["UK South","West Europe", "East US", "Southeast Asia", "North Europe", "Central US", "East Asia", "West US", "Australia East", "Japan East", "Canada Central", "France Central", "Germany West Central", "Switzerland North", "UAE North",  "Brazil South", "South Africa North", "Korea Central", "India Central"]
  description = "List of allowed Azure locations for resources"
}

# a map is a collection of key-value pairs, where each key is unique
# all the keys in the map must be of the same type, and all the values must also be of the same type
variable "resource_tags" {
  type = map(string) # Type of the variable is a map of strings
  default = {
        businesscriticality = "Low" # Tag to indicate the business criticality
        businessunit = "IT" # Tag to indicate the business unit
        costcentre = "tf" # Tag to indicate the cost center
        dataclassification = "Internal" # Tag to indicate the data classification
        workloadname = "tf" # Tag to indicate the workload name
  }
  description = "Map of tags to apply to resources"
  
}

# a tuple is a fixed-size collection of elements, where each element can be of a different type
# the types of the elements in the tuple are defined in the type constraint
variable "network_config" {
  type = tuple([string, string, number]) # Type of the variable is a tuple with three elements: string, string, and number
  description = "vnet address space, subnet address space, and subnet prefix length"
  default = ["10.0.0.0/16", "10.0.2.0",24] # Default value for the variable, which is a tuple with three elements
}

variable "allowed_vm_sizes" {
  type = list(string) # Type of the variable is a set of strings
  default = ["Standard_DS1_v2", "Standard_DS2_v2", "Standard_DS3_v2"] # Default value for the variable, which is a set of strings
  description = "Set of allowed VM sizes"
}



variable "vm_config" {
  type = object({
    size = string
    publisher = string
    offer = string
    sku = string
    version = string
  })

  description = "VM config"

  default = {
    size = "Standard_DS1_v2"
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  
}