


module "resource_groups" {
    source = "../../module/azurermRG"
    resource_groups = var.rgs

}   

variable "storage_account" {}

module "storage_account" {
    source = "../../module/azurermSA"
    storage_account = var.storage_account
  
}