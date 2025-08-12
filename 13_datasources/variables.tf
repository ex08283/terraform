variable "project_name" {
  type = string
  description = "name of proj"  
  default = "Porjct ALPHA Resouce"
}

variable "default_tags" {
  type = map(string)
  default = {
    "company" = "CloudOps"  
    "managed_by" = "terraform"
  }
}

variable "environment_tags" {
  type = map(string)
  default = {
    "environemt" = "prod"
    "cost_center" = "cc-123"
  }

}

variable "allowed_ports" {
  
  type = string
  default = "80,443,3306"
}




# Environment variable - determines the deployment environment
# This variable is used with the lookup() function to select appropriate VM sizes and other environment-specific settings
# The validation block ensures only valid environments are used, preventing configuration errors
# Valid values: dev, staging, prod - each typically has different resource requirements and configurations
variable "environment" {
  type    = string # Type of the variable, which is a string
  default = "dev"
  validation {
    condition = contains(["dev","staging","prod"],var.environment)
    error_message = "Enter valid value for env"
  }
  description = "The environment for the resources, e.g., dev, test, prod" # Description of the variable
}

# VM sizes variable - maps environment names to appropriate VM sizes
# This map is used with the lookup() function to automatically select the right VM size based on environment
# Different environments get different VM sizes: dev (smaller), staging (medium), prod (larger)
# This ensures cost optimization while meeting performance requirements for each environment
variable "vm_sizes" {
  type = map(string)
  default = {
    dev     = "standard_D2s_v3"
    staging = "standard_D4s_v3"
    prod    = "standard_D8s_v3"
  }
}


variable "account_names" {
  type = set(string)
  default = [ "djtutorial71","djtutorial72", "djtutorial73" ]    
}

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

# VM size variable - defines the specific VM size for resources
# This variable includes multiple validation rules to ensure proper VM size format
# Validation 1: Ensures the VM size name is between 2 and 20 characters
# Validation 2: Ensures the VM size contains "standard" (case-insensitive)
# These validations help prevent deployment errors and ensure consistent naming conventions
# The strcontains() function with lower() ensures case-insensitive validation
variable "vm_size" {
  type = string
  default = "standard_D2s_v3"
  validation {
    condition = length(var.vm_size) >= 2 && length(var.vm_size) <= 20
    error_message = "char length"
  }

  validation {
    condition = strcontains(lower(var.vm_size),"standard")
    error_message = "containsstandard"
  }
  
}

# Backup name variable - defines the name for backup resources
# This variable includes validation to ensure the name ends with "_backup"
# The endswith() function validates the naming convention for backup resources
# This naming convention helps with resource organization and backup management
# The validation prevents deployment errors by ensuring consistent backup naming
variable "backup_name" {
  default = "test_backup"
  type = string
  validation {
    condition = endswith(var.backup_name,"_backup")
    error_message = "has to end with _backup"
  }
}

# Credential variable - stores sensitive authentication information
# The sensitive = true attribute is crucial for security
# This prevents Terraform from displaying the credential value in logs, output, and state files
# Sensitive values are automatically encrypted in the state file and masked in console output
# This is essential for protecting passwords, API keys, and other confidential information
variable "credential" {
  default = "124xuys"
  type = string
  sensitive = true
}


