output "network_val"  {
  value = azurerm_subnet.internal.address_prefixes[0]
}