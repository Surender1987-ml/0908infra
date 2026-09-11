# Azure Infrastructure with Terraform (0908infra)

[![Terraform](https://img.shields.io/badge/Terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Azure-0078D4?style=flat&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Infrastructure as Code](https://img.shields.io/badge/IaC-Terraform_Modules-blue.svg)](https://www.terraform.io/)

A modular Terraform repository for provisioning and managing Microsoft Azure cloud infrastructure across multiple environments (`preprod`, `prod`).

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Modules](#modules)
  - [Resource Group Module (`azurermRG`)](#resource-group-module-azurermrg)
  - [Storage Account Module (`azurermSA`)](#storage-account-module-azurermsa)
- [Environments](#environments)
  - [Pre-Production (`preprod`)](#pre-production-preprod)
  - [Production (`prod`)](#production-prod)
- [Prerequisites](#prerequisites)
- [Getting Started & Deployment](#getting-started--deployment)
  - [1. Authenticate with Azure](#1-authenticate-with-azure)
  - [2. Initialize Terraform](#2-initialize-terraform)
  - [3. Review the Plan](#3-review-the-plan)
  - [4. Apply Infrastructure](#4-apply-infrastructure)
  - [5. Teardown / Destroy](#5-teardown--destroy)
- [Configuration & Variables](#configuration--variables)
- [Key Considerations & Best Practices](#key-considerations--best-practices)

---

## Overview

This repository demonstrates Infrastructure as Code (IaC) best practices using reusable Terraform child modules to provision Azure resources dynamically using `for_each` maps. 

Key benefits:
- **Reusable Modules**: Resource Group and Storage Account modules can be called by multiple environments without duplicating resource blocks.
- **Environment Isolation**: Separate configurations and state for pre-production and production.
- **Data-Driven Configuration**: Resource definitions are driven by `.tfvars` maps, enabling multi-resource provisioning from a single block.

---

## Repository Structure

```text
0908infra/
├── .gitignore                      # Standard Terraform and local state ignore rules
├── README.md                       # Project documentation
├── enviourment/                    # Environment-specific deployment configurations
│   ├── preprod/                    # Pre-production environment
│   │   ├── main.tf                 # Calls azurermRG and azurermSA modules
│   │   ├── terraform.tfvars        # Values for preprod resources
│   │   └── variable.tf             # Variable declarations for preprod
│   └── prod/                       # Production environment
│       ├── main.tf                 # Calls azurermSA module
│       ├── terraform.tfvars        # Values for prod resources
│       └── variable.tf             # Variable declarations for prod
└── module/                         # Reusable Terraform modules
    ├── azurermRG/                  # Azure Resource Group module
    │   ├── main.tf                 # azurerm_resource_group resource with for_each
    │   └── variable.tf             # Module input variables
    └── azurermSA/                  # Azure Storage Account module
        ├── main.tf                 # azurerm_storage_account resource with for_each
        └── variable.tf             # Module input variables
```

---

## Modules

### Resource Group Module (`azurermRG`)

Located in `module/azurermRG/`. Creates one or more Azure Resource Groups dynamically.

- **Source Code**: [module/azurermRG/main.tf](file:///module/azurermRG/main.tf)
- **Inputs**:
  - `resource_groups`: A map of objects containing:
    - `name` (string): The name of the resource group.
    - `location` (string): The Azure region (e.g., `"East US"` or `"eastus"`).

### Storage Account Module (`azurermSA`)

Located in `module/azurermSA/`. Creates one or more Azure Storage Accounts dynamically.

- **Source Code**: [module/azurermSA/main.tf](file:///module/azurermSA/main.tf)
- **Inputs**:
  - `storage_account`: A map of objects containing:
    - `name` (string): Globally unique name for the storage account (3–24 lowercase alphanumeric characters).
    - `location` (string): Target Azure region.
    - `resource` (string): Name of the parent resource group.
    - `account_tier` (string): Tier of the storage account (e.g., `"Standard"`, `"Premium"`).
    - `account_replication_type` (string): Replication strategy (e.g., `"LRS"`, `"GRS"`, `"ZRS"`).

---

## Environments

Deployments are segregated into environments under `enviourment/`:

| Environment | Path | Managed Resources | Modules Used |
| :--- | :--- | :--- | :--- |
| **Pre-Production** | `enviourment/preprod/` | Resource Groups & Storage Accounts | `azurermRG`, `azurermSA` |
| **Production** | `enviourment/prod/` | Storage Accounts | `azurermSA` |

---

## Prerequisites

Before running Terraform commands, ensure you have:

1. **Terraform CLI** (v1.0+ recommended): [Install Terraform](https://developer.hashicorp.com/terraform/downloads)
2. **Azure CLI**: [Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. An active **Microsoft Azure Subscription** with appropriate permissions (e.g., Contributor role).

---

## Getting Started & Deployment

### 1. Authenticate with Azure

Log into your Azure account and select the target subscription:

```bash
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID_OR_NAME>"
```

### 2. Initialize Terraform

Navigate to the desired environment directory (for example, `preprod`):

```bash
cd enviourment/preprod
terraform init
```

This initializes the working directory and downloads any required provider plugins.

### 3. Review the Plan

Generate an execution plan to verify the resources that will be created or modified:

```bash
terraform plan
```

### 4. Apply Infrastructure

Apply the configuration to provision resources in Azure:

```bash
terraform apply
```

Review the planned actions and type `yes` to confirm.

### 5. Teardown / Destroy

To clean up all resources created by an environment:

```bash
terraform destroy
```

---

## Configuration & Variables

### Example `terraform.tfvars` (Pre-Production)

```hcl
rgs = {
  rg1 = {
    name     = "regpreprod"
    location = "eastus"
  }
}

storage_account = {
  sa1 = {
    name                     = "sa0908preprod"
    location                 = "eastus"
    resource                 = "regpreprod"
    account_tier             = "Standard"
    account_replication_type = "LRS"
  }
}
```

---

## Key Considerations & Best Practices

1. **Storage Account Naming**:
   - Azure Storage Account names must be **globally unique across all Azure customers**, between 3 and 24 characters long, and contain **only lowercase letters and numbers** (no underscores, hyphens, or uppercase characters).
2. **Azure Regions**:
   - Use standard Azure region identifiers without underscores (e.g., `eastus` instead of `East_US`).
3. **Attribute Consistency**:
   - Verify that the attribute key used in the `.tfvars` map matches the key accessed in `module/azurermSA/main.tf` (e.g., `each.value.resource` vs `resouce_group_name`).
4. **Remote State**:
   - For production use, configure a Terraform remote backend (such as Azure Blob Storage with state locking) instead of relying on local `.tfstate` files.
