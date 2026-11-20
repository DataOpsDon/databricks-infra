---
name: databricks-terraform
description: Build Databricks resources (Unity Catalog, catalogs, schemas, volumes, storage credentials, external locations, grants, groups, clusters, cluster policies, SQL warehouses, secret scopes, workspace assignments) in any Terraform stack of this repo, whatever the stack is called. Use the `databricks/databricks` provider and the local modules in templates/modules. Use whenever a stack creates or changes a Databricks resource.
---

# Databricks Terraform

Applies to **any** stack that manages Databricks objects, not only `stacks/databricks` and `stacks/unity-catalog`. Azure resources in the same stack still follow the `avm-only-terraform` and `azure-naming` skills. The AVM "no local modules" rule does **not** apply to Databricks resources: these use `templates/modules`.

## Rules

1. **Databricks objects use the `databricks/databricks` provider only.** Do not manage them through `azurerm`/`azapi` (for example, do not create the workspace's catalogs or clusters with Azure resources). The Azure side (workspace, access connector, storage) stays AVM.
2. **Use a module from `templates/modules` first.** Check the catalogue below before writing anything. Call it with a relative path from the stack's terraform folder:
   `source = "../../../templates/modules/<module>"` (stacks live at `stacks/<name>/terraform`).
   Do not use `../modules/...`; that path does not resolve from a stack folder.
3. **Do not put `resource "databricks_*"` blocks in a stack's `.tf` files** when a module covers it. If no module fits, either extend the closest module (add a variable with a default so existing callers keep working) or add a new `uc_*` module in `templates/modules`, then call it. Tell the user which you chose.
4. **Pass providers explicitly** to every module with `providers = { databricks = databricks.<alias> }`:
   - `databricks.accounts` (host `https://accounts.azuredatabricks.net`): metastore, metastore assignment, workspace assignment, account-level groups.
   - `databricks.workspace` (host from the workspace URL output): everything else (catalogs, schemas, volumes, credentials, external locations, grants, clusters, policies, warehouses, secret scopes, notifications).
   - `uc_databricks_workspace_assignment` declares `configuration_aliases = [databricks.accounts]`, so give it `providers = { databricks = databricks.workspace, databricks.accounts = databricks.accounts }`.
5. **Stack provider setup** (`providers.tf`): one `required_providers` entry `databricks = { source = "databricks/databricks", version = "<pinned>" }` plus two aliased `provider "databricks"` blocks (`accounts`, `workspace`). Pin an exact version and keep it consistent with the other stacks (`stacks/databricks` is the newest reference). Do not add an un-aliased default provider.
6. **Module `terraform.tf`/`providers.tf`**: new modules declare `required_providers { databricks = { source = "databricks/databricks" } }` and no `provider` blocks. Match the existing version style in that module family.
7. **Wire through outputs**, not strings: `catalog_id = module.databricks_catalogs.ids[...]`, `credential_id = module.storage_credentials.id`, `metastore_id = module.metastore.id`. Workspace and connector IDs come from the landing-zone remote state (`data.terraform_remote_state.dlz.outputs.*`) or Azure module outputs.
8. **Permissions and groups are JSON-driven.** Grants, groups and metastore config live in `stacks/<stack>/config/...` as JSON and are passed with `json_file_path = lower("../config/<area>/${var.environment}/<file>.json")`. Add or edit the JSON rather than hardcoding grants in HCL.
9. **Naming**: Databricks object names come from variables or the `naming` module (`templates/utils`), not hardcoded literals, matching the neighbouring modules.

## Module catalogue (`templates/modules`)

| Need | Module | Provider alias |
|---|---|---|
| Metastore | `uc_metastore` | accounts |
| Attach metastore to workspace | `uc_metastore_assigment` (sic) | accounts |
| Metastore grants | `uc_data_metastore_permissions` | workspace |
| Assign group to workspace | `uc_databricks_workspace_assignment` | workspace + accounts |
| Groups (from JSON) | `uc_group` | accounts or workspace, follow the existing stack |
| Storage credential (access connector) | `uc_storage_credential` | workspace |
| Storage credential grants | `uc_data_storage_credential_permissions` | workspace |
| Service credential | `uc_service_credential` | workspace |
| External location | `uc_external_location` | workspace |
| External location grants | `uc_data_external_location_permissions` | workspace |
| Catalogs (bronze/silver/gold/resources) | `uc_data_catalog` | workspace |
| Catalog grants | `uc_data_catalog_permissions` | workspace |
| Schema | `uc_schema` | workspace |
| Labs schemas + grants | `uc_labs_schemas` | workspace |
| Volume | `uc_schema_volume` | workspace |
| Shared clusters | `uc_databricks_shared_clusters` | workspace |
| Cluster policies | `uc_databricks_cluster_policy` | workspace |
| SQL warehouses | `uc_databricks_sql_warehouses` | workspace |
| Service principal entitlements | `uc_databricks_sp_permissions` | workspace |
| Key Vault-backed secret scope | `uc_kv_secret_scope` | workspace |
| Notification destination | `uc_event_notification` | workspace |

Variables and outputs change; read the module's `variables.tf` and `outputs.tf` before calling it. Do not guess input names. Some modules (`uc_databricks_cluster_policy`) have no `variables.tf`; read `main.tf`.

## Workflow

1. Identify the Databricks objects needed and map each to a module above.
2. Read each module's inputs/outputs. Look at an existing call in `stacks/unity-catalog/terraform/main.tf` or `stacks/databricks/terraform/main.tf` as the pattern.
3. Ensure the stack's `providers.tf` has the aliased providers; add them if missing.
4. Add module calls with explicit `providers`, wired through outputs, with a short `//` comment above each in the repo's existing style.
5. If something is missing from the catalogue, follow rule 3.

## Before you finish

1. `terraform fmt -recursive` in the stack (and in `templates/modules` if you touched it).
2. `terraform init -backend=false` then `terraform validate` in the stack. Delete `.terraform/` and `.terraform.lock.hcl` afterwards unless asked to keep them.
3. `grep -nE '^resource "databricks_' *.tf` in the stack must return nothing (resources belong in modules).
4. Check every `source =` for a Databricks module starts with `../../../templates/modules/`.
5. Report which modules you used, which provider alias each got, and any module you added or extended.
