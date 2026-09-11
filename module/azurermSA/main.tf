resource "azurerm_storage_account" "sa" {
    for_each = var.storage_account
    name = each.value.name
    location = each.value.location
    resource_group_name = each.value.resource
    account_tier = each.value.account_tier
    account_replication_type = each.value.account_replication_type
}