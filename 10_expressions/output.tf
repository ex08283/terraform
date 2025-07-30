# This output uses a for expression to iterate over each object in the local.nsg_rules list,
# extracting the 'description' attribute from each object and returning a list of descriptions.
output "demo" {
  value = [for d in local.nsg_rules : d.description]
}

# This output uses a splat expression to extract the 'allow_http' attribute from each object
# in the local.nsg_rules list, returning a list of all 'allow_http' values.
# The splat syntax is a shorthand for mapping over a list to get a specific attribute.
output "splat" {
  value = local.nsg_rules[*].allow_http
}