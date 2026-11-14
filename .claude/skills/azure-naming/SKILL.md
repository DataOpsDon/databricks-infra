---
name: azure-naming
description: Name Azure resources in this repo's Terraform using the Azure/naming/azurerm registry module (CAF abbreviations, length and character rules). Use when adding or renaming any Azure resource, resource group or AVM module in a stack under stacks/*/terraform, or when asked what a resource should be called.
---

# Azure resource naming (Azure/naming/azurerm)

Never hardcode Azure resource names (for example `name = "rg-hub"`). Take every name from one `naming` module instance per stack, so slugs, length limits and allowed characters come from the module and not from memory.

Registry: https://registry.terraform.io/modules/Azure/naming/azurerm/latest (latest 0.4.4 when this skill was written; check with `curl -s https://registry.terraform.io/v1/modules/Azure/naming/azurerm | jq -r .version`).

## 1. Declare the module once per stack

Put it in `stacks/<stack>/terraform/main.tf`, above the resources, next to the "Module: naming" comment:

```hcl
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.4"

  # Resulting names are "<slug>-<suffix...>", for example rg-edp-dev-uks
  suffix = [var.project, var.environment, var.location_short]
}
```

Why `suffix` and not `prefix`: the module places `prefix` before the CAF slug (`edp-rg`), which breaks the `rg-...` convention used in this repo (`rg-tfstate-...`, `umi-tfbuild-...`). Use `suffix` so the slug always comes first.

Inputs already exist in the stack's `variables.tf`: `project`, `environment`, `location_short`. Reuse them. Do not add new naming variables.

Optional inputs:
- `unique-length` (default 4) and `unique-include-numbers`: control the random part of `name_unique`.
- `unique-seed`: NOT hashed. The module uses its first `unique-length` characters literally as the unique part. If you set it, use a short lowercase alphanumeric string (for example `"x7k2"`). Never derive it from names with dashes, because dashes end up in storage account names and fail validation.
- If you leave `unique-seed` unset, the module generates random characters once and keeps them in Terraform state, so `name_unique` stays stable between runs of the same state. It changes if the state is lost or the module is recreated, which would force new storage accounts and key vaults. Set `unique-seed` explicitly for anything long-lived.
- Name layout is `<prefix>-<slug>-<suffix>` (and `<slug>-<suffix>-<unique>` for `name_unique`), verified against the module's `main.tf`.

## 2. Use the outputs

Each resource type is an output object named after the resource (see the module's README for the full list). The attributes you need:

| Attribute | Meaning |
|---|---|
| `.name` | Name built from slug + suffix. Use for most resources. |
| `.name_unique` | Same, plus a deterministic random part. Use for globally unique names (storage account, key vault, container registry, Databricks managed RG, etc.). |
| `.slug` | CAF abbreviation, for example `rg`, `vnet`, `snet`, `nsg`, `kv`. |
| `.min_length`, `.max_length`, `.regex`, `.dashes`, `.scope` | The Azure rules for that type. Use them in `validation` blocks or to explain a failure. |

Typical usage:

```hcl
module "resource_group" {
  source           = "Azure/avm-res-resources-resourcegroup/azurerm"
  version          = "0.2.1"
  enable_telemetry = var.enable_telemetry
  location         = var.location
  name             = module.naming.resource_group.name
  tags             = var.tags
}

name = module.naming.virtual_network.name
name = module.naming.subnet.name              # or "${module.naming.subnet.slug}-<purpose>-..." (see section 3)
name = module.naming.storage_account.name_unique
name = module.naming.key_vault.name_unique
```

## 3. Resources that need an extra descriptor

When a stack has several resources of the same type (two subnets, two NSGs), the module alone gives the same name for both. Build the name from the slug and put the descriptor between the slug and the suffix:

```hcl
locals {
  name_suffix = join("-", [var.project, var.environment, var.location_short])
  # e.g. snet-databricks-public-edp-dev-uks
  subnet_names = {
    for k in ["databricks-public", "databricks-private", "privatelink"] :
    k => "${module.naming.subnet.slug}-${k}-${local.name_suffix}"
  }
}
```

Still check the result against `module.naming.subnet.max_length` and `.regex`. Do not invent a different abbreviation: always use `.slug` from the module.

## 4. Checklist when writing or reviewing a resource

1. Is the name coming from `module.naming.<type>` (or built from its `.slug`)? If not, fix it.
2. Globally unique type (storage account, key vault, ACR, app service, SQL server, Databricks workspace managed RG)? Use `name_unique`, and watch `max_length` (a storage account is 24 characters, lowercase letters and digits only, no dashes).
3. Is the resource type missing from the module's outputs? Say so, pick the Microsoft CAF abbreviation (https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations) and build the name the same way as section 3.
4. Are all inputs lowercase and free of characters the regex rejects?
5. Run `terraform fmt` and `terraform validate` in the stack, then `terraform plan -var-file=tfvars/dev.tfvars` and read the planned names before applying. A rename of an existing resource usually forces replacement.

## 5. What not to do

- Do not use this module for the bootstrap state, UMI and service connection names. Those come from the name templates in `bootstrap/terraform/config.yaml` (`rgName_state`, `saName_state`, `umiName_build`, ...). Leave them alone.
- Do not hardcode names in tfvars or in `locals` as plain strings.
- Do not change `suffix` on an existing stack without a plan: every resource name changes.
- Do not add random resources of your own for uniqueness. Use `name_unique` and `unique-seed`.

## 6. Looking up a name quickly

To show what the module produces without deploying:

```bash
cd stacks/<stack>/terraform
terraform init -backend=false
echo 'module.naming.storage_account' | terraform console -var-file=tfvars/dev.tfvars
```

Report the `name`, `name_unique` and `max_length` back to the user.
