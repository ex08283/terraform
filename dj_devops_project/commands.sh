#tf state list
#show all resources in state file

# import existing resource using
# run using powershell instead of bash
#tf import azurerm_resource_group.rg /subscriptions/8f2f2e98-2bdf-4cb7-a893-8a0e07a806d7/resourceGroups/day24-rg 

# how to remove resource from state
#tf state rm azurerm_resource_group.rg

#import exsiting resource using aztfexport
# create an empty folder to run the command in
#aztfexport resource-group --non-interactive day24-rg

# to destroy all the resource in the statfile use below command
# terraform destroy --auto-approve
