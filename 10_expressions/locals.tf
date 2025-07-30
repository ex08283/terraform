

# when to use local variables
# Local variables are used to define values that are used multiple times within a module or configuration.
# They help to avoid repetition and make the code cleaner and easier to maintain.
# compare this with the variable block above, which is used to define values that can be passed in from outside the module or configuration.
# the above environment variable can change based on the environment you are deploying to, while the local variable is fixed within the module.
locals  {
  nsg_rules = {
    allow_http = {
      priority               = 100
      destination_port_range = "80"
      description           = "Allow HTTP"
    },
    allow_https = {
      priority               = 110
      destination_port_range = "443"
      description           = "Allow HTTPS"
    }
  }
}