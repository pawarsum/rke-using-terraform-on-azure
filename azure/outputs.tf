output "public_ip" {
  value      = data.azurerm_public_ip.pip.ip_address
  depends_on = [azurerm_virtual_machine_extension.extension]
}

output "internal_ip" {
  value = azurerm_linux_virtual_machine.vm.private_ip_address
}

output "ssh_command" {
  value = "ssh ${var.username}@${data.azurerm_public_ip.pip.ip_address}"
}