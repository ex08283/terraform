
variable "environment" {
  type    = string # Type of the variable, which is a string
  default = "UAT" # Default value for the variable
  description = "The environment for the resources, e.g., dev, test, prod" # Description of the variable
}

variable "account_names" {
  type = set(string)
  default = [ "djtutorial71","djtutorial72", "djtutorial73" ]    
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

# allow duplicate values in the list
# a list is an ordered collection of elements, where each element can be of any type
variable "allowed_locations" {
  type = list(string)
  default = ["UK South","West Europe", "East US", "Southeast Asia", "North Europe", "Central US", "East Asia", "West US", "Australia East", "Japan East", "Canada Central", "France Central", "Germany West Central", "Switzerland North", "UAE North",  "Brazil South", "South Africa North", "Korea Central", "India Central"]
  description = "List of allowed Azure locations for resources"
}

