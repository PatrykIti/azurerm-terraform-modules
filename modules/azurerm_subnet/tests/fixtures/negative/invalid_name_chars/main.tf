module "subnet" {
  source = "../../../../"

  name                 = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"  # Too long - 81 characters
  resource_group_name  = "test-rg"
  virtual_network_name = "test-vnet"
  address_prefixes     = ["10.0.1.0/24"]
}