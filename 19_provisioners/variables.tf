

# Resource tags variable - comprehensive tagging strategy for Azure resources
# A map is a collection of key-value pairs, where each key is unique
# All the keys in the map must be of the same type, and all the values must also be of the same type
# These tags are crucial for:
# - Resource organization and management
# - Cost allocation and budgeting
# - Compliance and governance
# - Security classification
# - Business unit identification
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

# allow duplicate values in the list
# a list is an ordered collection of elements, where each element can be of any type
variable "allowed_locations" {
  type = list(string)
  default = ["UK South","West Europe", "East US", "Southeast Asia", "North Europe", "Central US", "East Asia", "West US", "Australia East", "Japan East", "Canada Central", "France Central", "Germany West Central", "Switzerland North", "UAE North",  "Brazil South", "South Africa North", "Korea Central", "India Central"]
  description = "List of allowed Azure locations for resources"
}
