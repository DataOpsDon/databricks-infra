---
name: avm-only-terraform
description: Build Azure infrastructure in this repo's Terraform stacks using only Azure Verified Modules (AVM) from the registry. Use when adding or changing any Azure resource in stacks/*/terraform. Never write `resource` blocks or local custom modules.
---

# AVM-only Terraform

Rules for every stack under `stacks/*/terraform`:

1. **No `resource` blocks and no local/custom modules.** Every Azure resource comes from a registry module under `Azure/avm-res-*` (single resource) or `Azure/avm-ptn-*` (pattern). The only non-AVM module allowed is `Azure/naming/azurerm` (see the `azure-naming` skill).
2. **Pin exact versions** (`version = "0.23.0"`, not `~>`), and set `enable_telemetry = var.enable_telemetry`.
3. **Names** come from the `naming` module, never hardcoded.
4. **Pass `tags = var.tags`** wherever the module accepts tags, and `location = var.location` where it asks for one.
5. **Wire modules together through outputs**, for example `parent_id = module.resource_group.resource_id`. Do not reference resources by hand-built ID strings.

## Finding the right module

1. Look up the module name: `Azure/avm-res-<provider>-<resource>/azurerm`, for example `avm-res-network-virtualnetwork`. The list of AVM modules is at https://azure.github.io/Azure-Verified-Modules/indexes/terraform/tf-resource-modules/.
2. Get the latest version: `curl -s https://registry.terraform.io/v1/modules/Azure/<module>/azurerm | jq -r .version`.
3. Read the module's real inputs and outputs before writing code. Version changes often rename inputs. In a scratch folder (not the stack), create a file that declares the module, run `terraform init -backend=false`, then read `.terraform/modules/<name>/variables.tf` and `outputs.tf`.
4. If a resource needs a child resource (subnets, DNS links, private endpoints, role assignments, diagnostic settings, locks), look for it as an input of the parent module first (`subnets`, `virtual_network_links`, `private_endpoints`, `role_assignments`, `diagnostic_settings`, `lock`). Do not create a separate resource for it.
5. If no AVM module exists, stop and tell the user. Do not fall back to a `resource` block unless the user explicitly agrees.

## Conventions seen in this repo's modules

- Current AVM modules take `parent_id` (the resource group's ID) instead of `resource_group_name`.
- `module.<x>.resource_id` is the ID output on almost every module.
- Subnets are inputs of the virtual network module (`subnets = { key = { name, address_prefixes, network_security_group = { id }, delegations = [...] } }`). Attach NSGs and delegations there.
- Reference subnets by the name you pass in, for example the DNS resolver's `inbound_endpoints.<key>.subnet_name`. Add `depends_on = [module.virtual_network]` when the module only takes a name.

## Azure Databricks networking notes

- VNet injection needs two subnets (host/public and container/private), each delegated to `Microsoft.Databricks/workspaces` and each with an NSG. Databricks adds its own required NSG rules through the delegation.
- The private DNS zone for both the workspace private endpoint (`databricks_ui_api`) and browser authentication (`browser_authentication`) is `privatelink.azuredatabricks.net`. One zone serves both.
- The private DNS resolver inbound endpoint needs its own subnet, at least a /28, delegated to `Microsoft.Network/dnsResolvers`.

## Before you finish

1. `terraform fmt -recursive` in the stack.
2. `terraform init -backend=false` then `terraform validate` (the stack has an `azurerm` backend, so `-backend=false` is required locally). Delete the generated `.terraform/` and `.terraform.lock.hcl` afterwards unless asked to keep them.
3. `grep -nE '^(resource|data) ' *.tf` must only show `data` blocks that already existed (such as `azurerm_client_config`). Any `resource` line means the rule is broken.
4. Say which module versions you pinned and which inputs you set from variables.
