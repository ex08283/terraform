
variable "environment" {
  type    = string # Type of the variable, which is a string
  default = "dev" # Default value for the variable
  description = "The environment for the resources, e.g., dev, test, prod" # Description of the variable
}