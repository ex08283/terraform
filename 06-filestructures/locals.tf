

# when to use local variables
# Local variables are used to define values that are used multiple times within a module or configuration.
# They help to avoid repetition and make the code cleaner and easier to maintain.
# compare this with the variable block above, which is used to define values that can be passed in from outside the module or configuration.
# the above environment variable can change based on the environment you are deploying to, while the local variable is fixed within the module.
locals {
  common_tags = { # Define common tags that can be reused across resources
    environment = var.environment # Use the variable defined in terraform.tfvars
    lob = "Banking"
    stage = "alpha"
  }
}