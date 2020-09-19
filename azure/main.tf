provider "azurerm" {
  version = "~>2.0"
  features {}
}

resource "azurerm_resource_group" "rke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "network" {
  source              = "Azure/network/azurerm"
  vnet_name           = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.rke.name
  address_space       = var.address_spaces
  subnet_prefixes     = var.address_prefixes
  subnet_names        = ["${var.prefix}-subnet1"]

  tags = var.tags

  depends_on = [azurerm_resource_group.rke]

}

locals {
  ipallocation = "Dynamic"
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rke.name
  location            = azurerm_resource_group.rke.location
  allocation_method   = local.ipallocation
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rke.location
  resource_group_name = azurerm_resource_group.rke.name

  ip_configuration {
    name                          = "internalnetworkinterface"
    subnet_id                     = module.network.vnet_subnets[0]
    private_ip_address_allocation = local.ipallocation
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                       = "${var.prefix}-vm"
  resource_group_name        = azurerm_resource_group.rke.name
  location                   = azurerm_resource_group.rke.location
  size                       = var.size
  admin_username             = var.username
  network_interface_ids      = [azurerm_network_interface.nic.id]
  allow_extension_operations = true

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}

data "azurerm_public_ip" "pip" {
  name                = azurerm_public_ip.pip.name
  resource_group_name = azurerm_linux_virtual_machine.vm.resource_group_name
  depends_on          = [azurerm_public_ip.pip]
}

resource "azurerm_virtual_machine_extension" "extension" {
  name                 = "rke-pre-deployment-setup"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
  protected_settings   = <<PROT
    {
        "script": "${base64encode(templatefile("${path.module}/pre_rke_setup.bash", { username = var.username }))}"
    }
    PROT
  tags                 = var.tags
}

