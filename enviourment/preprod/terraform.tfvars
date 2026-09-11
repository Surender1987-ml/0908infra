rgs={

    rg1 = {
        name = "regpreprod"
        location = "East_US"
    }
}

storage_account = {
    SA1 = {
        name = "SA1"
        location = "East_US"
        resouce_group_name = "regpreprod"
        account_tier    =   "Standard"
        account_replication_type = "LRS"
}
}