variable "resource_group_name" {
    type = string
    default = "test-group"
    description = "Name of the resource group"
}


# allow duplicate values in the list
# a list is an ordered collection of elements, where each element can be of any type
variable "allowed_locations" {
  type = string
  default = "UK South"
  description = "List of allowed Azure locations for resources"
}
