locals {
  data_disks_by_name = { for disk in var.data_disks : disk.name => disk }
}

resource "azurerm_managed_disk" "managed_disk" {
  for_each = local.data_disks_by_name

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name

  create_option          = "Empty"
  storage_account_type   = each.value.storage_account_type
  disk_size_gb           = each.value.disk_size_gb
  disk_encryption_set_id = each.value.disk_encryption_set_id
  zone                   = var.placement.zone

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "virtual_machine_data_disk_attachment" {
  for_each = local.data_disks_by_name

  managed_disk_id           = azurerm_managed_disk.managed_disk[each.key].id
  virtual_machine_id        = azurerm_windows_virtual_machine.windows_virtual_machine.id
  lun                       = each.value.lun
  caching                   = each.value.caching
  write_accelerator_enabled = each.value.write_accelerator_enabled
}
