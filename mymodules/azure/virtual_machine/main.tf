resource "azurerm_public_ip" "ip" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  zones               = [var.zone]
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "sg" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "sga" {
  network_interface_id      = azurerm_network_interface.ni.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_network_interface" "ni" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.name
  location            = var.azure_region
  zone                = var.zone
  size                = var.size
  resource_group_name = var.resource_group_name

  network_interface_ids = [azurerm_network_interface.ni.id]

  os_disk {
    name                  = var.name
    caching               = "ReadWrite"
    storage_account_type  = "Premium_LRS"
  }
 
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = var.name
  admin_username                  = var.username
  disable_password_authentication = true

  admin_ssh_key {
    username = var.username
    public_key = var.ssh_key
  }

  custom_data = var.custom_data
  
}
