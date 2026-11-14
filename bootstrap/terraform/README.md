# Bootstrap Command Documentation

## 📋 Table of Contents

- [Overview](#overview)
- [ Install Ignition](#install-ignition)
- [⚙️ Configuration Reference (`config.yaml`)](#configuration-reference)
- [📝 Required Inputs Checklist](#required-inputs-checklist)
- [📍🔐 Where & What, Terraform State & UMIs](#Where-What-Terraform-State-UMIs)
   - [Where State Storage & Identity is Located](#umi-state-storage-location)
- [ ⛳ What Gets Created](#what-gets-created)
   - [In Azure](#in-azure)
   - [In GitHub](#in-github)
   - [In Azure DevOps](#in-azure-devops)

---

<a id="overview"></a>
## Overview

The `ign bootstrap` command sets up foundational Azure infrastructure required for Terraform remote state management, User Managed Identities (UMIs), and CI/CD operations (Azure DevOps / GitHub Actions).  
This is done on a environment by environment basis.  
Currently this bootstrapper does not store a statefile of the bootstrapping process.  

Command's we will use are:
- `ign bootstrap --plan-only` (to create a plan)
- `ign bootstrap --apply` (to apply the changes)

---

Steps are as follows:  
1. Instal `Ignition`
2. ADO or GitHub `Prerequisites`
3. Adjust `config.yaml`  
4. Run `ign bootstrap --plan-only`  
5. Confirm you're happy with the plan and run `ign bootstrap --apply`  

---

<a id="install-ignition"></a>
1. ## 🧰 Install Ignition

### Recommended: Using uv (Fast & Modern) ⚡
```powershell
# Install uv if you don't have it
# Windows: powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Download and install the CLI
gh release download v{Release-Version} --repo telefonicatechuki/devops-cli --pattern "*.whl"
uv tool install ign-{Release-Version}-py3-none-any.whl --force

# Verify installation
ign --help
```

### Alternative: Using pip
```powershell
# Download and install
gh release download v{Release-Version} --repo telefonicatechuki/devops-cli --pattern "*.whl"
pip install ign-{Release-Version}-py3-none-any.whl
```

### Prerequisites

- GitHub CLI: Required for downloading from private repo

   ```powershell
   winget install GitHub.cli
   gh auth login
   ```

- uv (Recommended): Fast Python package installer

   ```powershell
   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
   ```

### Usage

```powershell
ign --help
ign init
ign add-stack
```

### VS Code MCP Server (GitHub Copilot integration)
After installing, register the MCP server in VS Code with a single command:
```powershell
ign mcp install
```
This writes the server entry to your VS Code user settings so the `ign` MCP server
is available in every project. Pass `--workspace` to scope it to the current project
only, or `--copilot` to also register it in GitHub Copilot CLI.

```powershell
ign mcp install --workspace   # writes .vscode/mcp.json
ign mcp install --copilot     # also adds to ~/.copilot/mcp.json
```
Reload VS Code (Ctrl+Shift+P → "Developer: Reload Window") after running the command.

### Updating to Latest Version
```powershell
# With uv (recommended)
gh release download v{Release-Version} --repo telefonicatechuki/devops-cli --pattern "*.whl"
ign-{Release-Version}-py3-none-any.whl --force

# With pip
pip install --force-reinstall ign-{Release-Version}-py3-none-any.whl
```

---
2. ##  ADO Prerequisites
The user who's PAT code will be used to config the ADO project needs the following permissions.
 - Be a project admin of the project being configured
 - Be made an administrator of the Environments area within the project
---

<a id="configuration-reference"></a>
3. ## ⚙️ Configuration Reference (`config.yaml`)

Your `config.yaml` file defines all variables for bootstrapping. Fields marked with `<Fill Me In>` must be updated prior to running `ign bootstrap`.

---

<a id="required-inputs-checklist"></a>
## 📝 Required Inputs Checklist

Before running `ign bootstrap --apply`, you'll populate these fields in `config.yaml` everything else can be adjust or follow the default standard:

| Variable | Description | Example / Instructions |
|----------|-------------|------------------------|
| `isFirstTimeDeployToADO` | RUN ONCE: Deploys ADO permissions / variable group environments. Set to false after first run | true / false |
| `isFirstTimeDeployToGH` | GitHub only. RUN ONCE per repository: role teams + repository guardrails. Set to false for later environments | true / false |
| `app_short` | Application short code | `app1`, `dlz`, `data` |
| `subscriptionId_State` | Azure Subscription ID for State Storage | `00000000-0000-0000-0000-000000000000` |
| `containers_state` | State storage containers for stacks you are planning on building | Configure container names under `containers_state` (e.g. `network`, `infra`) |
| `subscriptionId_umi` | Azure Subscription ID for User Managed Identities | `00000000-0000-0000-0000-000000000000` |
| `subscriptionId_Application` | Azure Subscription ID for target workload deployments | `00000000-0000-0000-0000-000000000000` |
| `subscriptionName_Application` | Azure Subscription Name for target workload deployments | `Application1-Dev` |
| `adoOrgUrl` | Azure DevOps Organization URL | `https://dev.azure.com/my-org/` |
| `adoProjectName` | Azure DevOps Project Name | Landing Zone |
| `orgName_gh` / `repositoryName_gh` | GitHub only (set by `ign init --cicd github`). Organisation and repository | `my-org` / `infra-app1` |

---

<a id="Where-What-Terraform-State-UMIs"></a>
## 📍🔐 Where & What, Terraform State & UMIs

<a id="umi-state-storage-location"></a>
### Where State Storage & Identity is Located

**Terraform state is stored in an Azure Storage Account**, and deployment identities are created as **User Managed Identities (UMIs)** with Federated Identity Credentials / Azure DevOps Service Connections.

<a id="what-gets-created"></a>
## What Gets Created

<a id="in-azure"></a>
### ☁️ In Azure
When you run `ign bootstrap --apply`, the following resources are created in Azure based on your `config.yaml`:

1. **Resource Group for State Storage**
   - **Default Naming Template**: `rg-tfstate-${app_short}-${environment}-${locationShort}-${instance}`
   - **Example**: `rg-tfstate-app1-dev-uks-01`
   - **Subscription**: `subscriptionId_State`

2. **Storage Account for State Files**
   - **Default Naming Template**: `sttfstate${app_short}${environment}${locationShort}`
   - **Example**: `sttfstateapp1devuks`
   - **SKU**: Configurable via `stateStorageSku` (Default: `Standard_ZRS`)
   - **Public Access**: Configurable via `stateStoragePublic_network_access_enabled` (Default: `true`)
   - **Containers**: Dynamically created based on `containers_state` (e.g., `network`, `infra`)

3. **Resource Group for Managed Identities**
   - **Default Naming Template**: `rg-umi-${app_short}-${environment}-${locationShort}-${instance}`
   - **Subscription**: `subscriptionId_umi`

4. **User Managed Identities (UMI)**
   - **Build UMI**: `umi-tfbuild-${app_short}-${environment}-${locationShort}`
   - **Deploy UMI**: `umi-tfdeploy-${app_short}-${environment}-${locationShort}`

<a id="umi-role-assignments-and-permissions"></a>
### What User Managed Identity (UMI) Role Assignments & Permissions

The bootstrap process provisions two User Managed Identities (UMIs) with the following RBAC role assignments:

| UMI Example Name | RBAC Role | Resource / Scope |
|------------------|-----------|------------------|
| `umi-tfbuild-edp-dev-uks` | `Reader` | State Resource Group (`rg-tfstate-edp-dev-uks-01`) |
| `umi-tfbuild-edp-dev-uks` | `Storage Blob Data Contributor` | State Storage Account (`sttfstateedpdevuks`) |
| `umi-tfbuild-edp-dev-uks` | `Reader` | Application Subscription (`subscriptionId_Application`) |
| `umi-tfdeploy-edp-dev-uks` | `Owner` | State Resource Group (`rg-tfstate-edp-dev-uks-01`) |
| `umi-tfdeploy-edp-dev-uks` | `Storage Blob Data Contributor` | State Storage Account (`sttfstateedpdevuks`) |
| `umi-tfdeploy-edp-dev-uks` | `Owner` | Application Subscription (`subscriptionId_Application`) |

<a id="in-github"></a>
### 🐙 In GitHub (`cicdPlatform: github`)
When `config.yaml` has `cicdPlatform: "github"` (set automatically by `ign init --cicd github`),
no Azure DevOps resources are created. The GitHub resources mirror the Azure DevOps ones.
For a GitHub-side walkthrough of every team, ruleset, policy and environment it creates, see
[GITHUB-BOOTSTRAP.md](GITHUB-BOOTSTRAP.md).

| Azure DevOps | GitHub equivalent | Module | Runs |
|---|---|---|---|
| ADO project (`adoCreateProject`) | Repository (`ghCreateRepository`) | `modules/gh-repository` | first run (`isFirstTimeDeployToGH`) |
| Project settings | Branch ruleset, Actions policy, workflow token policy, Dependabot, secret scanning | `modules/gh-repository` | first run |
| Project permission groups | Role teams with repository roles | `modules/gh-team-permissions` | first run |
| Build service connection | `<env>` environment + variables + OIDC trust for the build UMI | `modules/gh-environment` | every environment |
| Deploy service connection + approval check | `<env>/apply` environment + required reviewers + branch policy + OIDC trust for the deploy UMI | `modules/gh-environment` | every environment |
| Variable group | Environment variables (`AZURE_*`, `TF_STATE_*`) | `modules/gh-environment` | every environment |
| (shared pipeline templates) | Shared CI/CD repo `cicdRepoName_gh` with the reusable workflow + composite actions, its maintainers team and guardrails | `modules/gh-repository` + `modules/gh-team-permissions` | first run, once per organisation (`createCicdRepo_gh`) |

#### Prerequisites
- A GitHub **organisation** (`orgName_gh`). Rulesets on private repositories need GitHub Team or Enterprise.
- A token for someone who is an **organisation owner**, or an admin of the repository who can create teams.
  `ign bootstrap` uses `--gh-token` / `GITHUB_TOKEN`, then offers the GitHub CLI's token (`gh auth token`),
  then prompts. The token is never written to disk.
  - Classic PAT scopes: `repo`, `admin:org`, `workflow`.
  - Fine-grained token: repository *Administration*, *Environments*, *Variables*, *Contents* (write) and
    organisation *Members* (write).

#### Run order
1. First environment of a repository (e.g. `dev`): `isFirstTimeDeployToGH: true`.
   Creates the repository (optional), the role teams, the ruleset and the Actions policy, then the environments.
2. Every other environment (e.g. `prd`): change `environment`, set `isFirstTimeDeployToGH: false`
   (and usually `applyBranchPatterns_gh: ["main"]`), then re-run. Only the environments, variables and OIDC
   trust are created; the Platform Admin team is looked up by slug.

#### Shared CI/CD repository
With `createCicdRepo_gh: true` (default), the first run for a repository checks whether
`<orgName_gh>/<cicdRepoName_gh>` exists:

- **Does not exist** - `ign bootstrap` renders the CI/CD templates for your organisation (org name, repo name and
  `cicd_ref` from `.ignition.json` filled in), and Terraform:
  1. creates the repository (`cicdRepoVisibility_gh`, default private) and commits the files to `main`,
     committing `.github/workflows/release.yml` last with `#major` so its single run publishes `v1.0.0`;
  2. creates the `<cicdRepoName_gh>-maintainers` team (admin, CODEOWNERS of the repo; members from `cicdRepoMaintainers_gh`);
  3. applies the same guardrails as the infrastructure repository (ruleset, Actions allow-list, Dependabot);
  4. allows every repository in the organisation to use its workflows and actions.

  The apply runs with `-parallelism=1` because GitHub rejects parallel commits to one branch.
- **Already exists** (e.g. another team bootstrapped first) - it is left untouched. Set
  `manageCicdRepoAccess_gh: true` to (re)grant organisation access to it.

The run aborts if the GitHub API cannot be reached to make this check; set `createCicdRepo_gh: false` to skip it.

#### Repository role teams
Team names are organisation-wide, so they are prefixed with `teamPrefix_gh` (default: the repository name).
Toggle each with the same `create*Group` keys used for Azure DevOps. Roles are set by `github_team_repository_roles`
in `variables.tf`; members by `teamMembers_gh` (leave empty to manage membership in GitHub or through IdP team sync).

| Team | Default role | Purpose |
|---|---|---|
| `<prefix>-platform-admin` | `admin` | Settings, CODEOWNERS for `.github/` and `bootstrap/`, ruleset bypass (pull requests only), apply approval |
| `<prefix>-lead-engineers` | `maintain` | Default code owners, manage pull requests |
| `<prefix>-engineers` | `push` | Branches and pull requests |
| `<prefix>-project-managers` | `triage` | Issues and pull requests, no code write |
| `<prefix>-lead-testers` | `triage` | Issues and pull requests, no code write |
| `<prefix>-testers` | `pull` | Read |

#### Guardrails

| Guardrail | Default | Key |
|---|---|---|
| `main` + `develop` need a pull request, no force push, no deletion | on | `enableRulesets_gh`, `protectedBranches_gh` |
| Approvals before merge | 1, stale approvals dismissed, last push approved by someone else, conversations resolved | `requiredApprovals_gh`, `requireLastPushApproval_gh` |
| Code owner approval | on | `requireCodeOwnerReview_gh` |
| Required status checks | none until the first run | `requiredStatusChecks_gh` |
| Signed commits / linear history | off | `requireSignedCommits_gh`, `requireLinearHistory_gh` |
| Only GitHub-owned, organisation-owned and listed actions may run | on | `manageActionsPermissions_gh`, `allowedActionPatterns_gh` |
| Actions must be pinned to a commit SHA | off | `shaPinningRequired_gh` |
| `GITHUB_TOKEN` read-only; Actions cannot approve pull requests | on | `manageActionsPermissions_gh` |
| Dependabot alerts + security updates | on | `enableVulnerabilityAlerts_gh` |
| Secret scanning + push protection (new repos) | off (needs a licence on private repos) | `enableSecretScanning_gh` |
| Apply needs an approval; the person who triggered it cannot approve | on | `deployApprovalRequired`, `preventSelfReviewDeploy_gh` |
| Admins cannot skip the apply approval | on | `canAdminsBypassDeploy_gh` |
| Only listed branches can reach the deploy identity | `main`, `develop` | `applyBranchPatterns_gh` |

#### OIDC trust

| Identity | Federated credential subject | Used by |
|---|---|---|
| Build UMI | `repo:<orgName_gh>@<orgId>/<repositoryName_gh>@<repoId>:environment:<environmentName_gh>` | CI + plan jobs |
| Deploy UMI | `repo:<orgName_gh>@<orgId>/<repositoryName_gh>@<repoId>:environment:<environmentName_gh>/apply` | apply job |

`<orgId>` and `<repoId>` are the numeric GitHub IDs. The bootstrap looks them up for you. This is GitHub's
immutable subject format: the default for github.com repositories created after 15 July 2026, and for older
repositories that have opted in. For an older repository that still uses the name-only format
(`repo:<org>/<repo>:...`), set `oidcSubjectFormat_gh: "legacy"`.

`environmentName_gh` defaults to `environment` and must match the `environment` input in the stack workflows.

After `ign bootstrap --apply`, `bootstrap/BOOTSTRAP-OUTPUTS-<env>.md` summarises what was created.
Add people to the approvers team (`teamName_gh`, or list them in `approvers_gh`) - nobody can approve an
apply until it has members.

> **Re-running:** like the Azure DevOps resources, bootstrap deletes its local state after apply, so a second
> run for the same environment tries to create the teams, environments and variables again and fails on the
> ones that already exist. Use `--keep-state` if you expect to re-run, or remove/import the existing objects.

<a id="in-azure-devops"></a>
### 🚀 In Azure DevOps
When you run `ign bootstrap --apply`, the following resources are created in Azure DevOps based on your `config.yaml`:

1. **A private ADO project**
   - Git version control
   - Agile work item template
   - ADO features enabled
      - Boards
      - Repositories
      - Pipelines
      - Test Plans
      - Artifacts

2. **Project Permission Groups** - With appropriate permissions assigned
   - **Platform Admin**: Configurable via `createPlatformAdminGroup` (Default: `true`)
   - **Lead Engineers**: Configurable via `createLeadEngineerGroup` (Default: `true`)
   - **Engineers**: Configurable via `createEngineerGroup` (Default: `true`)
   - **Lead Testers**: Configurable via `createLeadTesterGroup` (Default: `true`)
   - **Testers**: Configurable via `createTesterGroup` (Default: `true`)
   - **Project Manager**: Configurable via `createPlatformAdminGroup` (Default: `true`)

3. **Permissions Assigned**
   - **Project Group:**
      

      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ                 | Allow |
      | GENERIC_WRITE                | Allow |
      | DELETE                       | Deny |
      | PUBLISH_TEST_RESULTS         | Allow |
      | ADMINISTER_BUILD             | Allow |
      | START_BUILD                  | Allow |
      | EDIT_BUILD_STATUS            | Allow |
      | UPDATE_BUILD                 | Allow |
      | DELETE_TEST_RESULTS          | Allow |
      | VIEW_TEST_RESULTS            | Allow |
      | MANAGE_TEST_ENVIRONMENTS     | Allow |
      | MANAGE_TEST_CONFIGURATIONS   | Allow |
      | WORK_ITEM_DELETE             | Allow |
      | WORK_ITEM_MOVE               | Allow |
      | WORK_ITEM_PERMANENTLY_DELETE | Allow |
      | RENAME                       | Allow |
      | MANAGE_PROPERTIES            | Allow |
      | BYPASS_RULES                 | Deny |
      | SUPPRESS_NOTIFICATIONS       | Allow |
      | UPDATE_VISIBILITY            | Allow |
      | CHANGE_PROCESS               | Allow |
      | AGILETOOLS_PLANS             | Allow |


      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ                 | Allow |
      | GENERIC_WRITE                | Deny |
      | DELETE                       | Deny |
      | PUBLISH_TEST_RESULTS         | Allow |
      | ADMINISTER_BUILD             | Allow |
      | START_BUILD                  | Allow |
      | EDIT_BUILD_STATUS            | Allow |
      | UPDATE_BUILD                 | Allow |
      | DELETE_TEST_RESULTS          | Deny |
      | VIEW_TEST_RESULTS            | Allow |
      | MANAGE_TEST_ENVIRONMENTS     | Allow |
      | MANAGE_TEST_CONFIGURATIONS   | Allow |
      | WORK_ITEM_DELETE             | Allow |
      | WORK_ITEM_MOVE               | Allow |
      | WORK_ITEM_PERMANENTLY_DELETE | Deny |
      | RENAME                       | Deny |
      | MANAGE_PROPERTIES            | Allow |
      | BYPASS_RULES                 | Deny |
      | SUPPRESS_NOTIFICATIONS       | Allow |
      | UPDATE_VISIBILITY            | Allow |
      | CHANGE_PROCESS               | Deny |
      | AGILETOOLS_PLANS             | Allow |


      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ                 | Allow |
      | GENERIC_WRITE                | Deny |
      | DELETE                       | Deny |
      | PUBLISH_TEST_RESULTS         | Allow |
      | ADMINISTER_BUILD             | Allow |
      | START_BUILD                  | Allow |
      | EDIT_BUILD_STATUS            | Allow |
      | UPDATE_BUILD                 | Allow |
      | DELETE_TEST_RESULTS          | Deny |
      | VIEW_TEST_RESULTS            | Allow |
      | MANAGE_TEST_ENVIRONMENTS     | Allow |
      | MANAGE_TEST_CONFIGURATIONS   | Allow |
      | WORK_ITEM_DELETE             | Allow |
      | WORK_ITEM_MOVE               | Allow |
      | WORK_ITEM_PERMANENTLY_DELETE | Deny |
      | RENAME                       | Deny |
      | MANAGE_PROPERTIES            | Allow |
      | BYPASS_RULES                 | Deny |
      | SUPPRESS_NOTIFICATIONS       | Allow |
      | UPDATE_VISIBILITY            | Allow |
      | CHANGE_PROCESS               | Deny |
      | AGILETOOLS_PLANS             | Allow |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ                 | Allow |
      | GENERIC_WRITE                | Deny |
      | DELETE                       | Deny |
      | PUBLISH_TEST_RESULTS         | Allow |
      | ADMINISTER_BUILD             | Deny |
      | START_BUILD                  | Deny |
      | EDIT_BUILD_STATUS            | Deny |
      | UPDATE_BUILD                 | Deny |
      | DELETE_TEST_RESULTS          | Allow |
      | VIEW_TEST_RESULTS            | Allow |
      | MANAGE_TEST_ENVIRONMENTS     | Allow |
      | MANAGE_TEST_CONFIGURATIONS   | Allow |
      | WORK_ITEM_DELETE             | Allow |
      | WORK_ITEM_MOVE               | Allow |
      | WORK_ITEM_PERMANENTLY_DELETE | Deny |
      | RENAME                       | Deny |
      | MANAGE_PROPERTIES            | Allow |
      | BYPASS_RULES                 | Deny |
      | SUPPRESS_NOTIFICATIONS       | Allow |
      | UPDATE_VISIBILITY            | Allow |
      | CHANGE_PROCESS               | Deny |
      | AGILETOOLS_PLANS             | Allow |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ                 | Allow |
      | GENERIC_WRITE                | Deny |
      | DELETE                       | Deny |
      | PUBLISH_TEST_RESULTS         | Allow |
      | ADMINISTER_BUILD             | Deny |
      | START_BUILD                  | Deny |
      | EDIT_BUILD_STATUS            | Deny |
      | UPDATE_BUILD                 | Deny |
      | DELETE_TEST_RESULTS          | Allow |
      | VIEW_TEST_RESULTS            | Allow |
      | MANAGE_TEST_ENVIRONMENTS     | Allow |
      | MANAGE_TEST_CONFIGURATIONS   | Allow |
      | WORK_ITEM_DELETE             | Allow |
      | WORK_ITEM_MOVE               | Allow |
      | WORK_ITEM_PERMANENTLY_DELETE | Deny |
      | RENAME                       | Deny |
      | MANAGE_PROPERTIES            | Allow |
      | BYPASS_RULES                 | Deny |
      | SUPPRESS_NOTIFICATIONS       | Allow |
      | UPDATE_VISIBILITY            | Allow |
      | CHANGE_PROCESS               | Deny |
      | AGILETOOLS_PLANS             | Allow |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ                 | Allow |
      | GENERIC_WRITE                | Deny |
      | DELETE                       | Deny |
      | PUBLISH_TEST_RESULTS         | Deny |
      | ADMINISTER_BUILD             | Deny |
      | START_BUILD                  | Deny |
      | EDIT_BUILD_STATUS            | Deny |
      | UPDATE_BUILD                 | Deny |
      | DELETE_TEST_RESULTS          | Deny |
      | VIEW_TEST_RESULTS            | Allow |
      | MANAGE_TEST_ENVIRONMENTS     | Deny |
      | MANAGE_TEST_CONFIGURATIONS   | Deny |
      | WORK_ITEM_DELETE             | Allow |
      | WORK_ITEM_MOVE               | Allow |
      | WORK_ITEM_PERMANENTLY_DELETE | Deny |
      | RENAME                       | Deny |
      | MANAGE_PROPERTIES            | Deny |
      | BYPASS_RULES                 | Deny |
      | SUPPRESS_NOTIFICATIONS       | Allow |
      | UPDATE_VISIBILITY            | Allow |
      | CHANGE_PROCESS               | Deny |
      | AGILETOOLS_PLANS             | Allow |

   - **Iteration:**


      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ    | Allow |
      | GENERIC_WRITE   | Allow |
      | CREATE_CHILDREN | Allow |
      | DELETE          | Allow |

      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ    | Allow |
      | GENERIC_WRITE   | Allow |
      | CREATE_CHILDREN | Allow |
      | DELETE          | Deny |


      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ    | Allow |
      | GENERIC_WRITE   | Allow |
      | CREATE_CHILDREN | Deny |
      | DELETE          | Deny |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ    | Allow |
      | GENERIC_WRITE   | Allow |
      | CREATE_CHILDREN | Allow |
      | DELETE          | Deny |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ    | Allow |
      | GENERIC_WRITE   | Allow |
      | CREATE_CHILDREN | Deny |
      | DELETE          | Deny |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ    | Allow |
      | GENERIC_WRITE   | Allow |
      | CREATE_CHILDREN | Allow |
      | DELETE          | Allow |

   - **Area:**


      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ           | Allow |
      | GENERIC_WRITE          | Allow |
      | CREATE_CHILDREN        | Allow |
      | DELETE                 | Allow |
      | WORK_ITEM_READ         | Allow |
      | WORK_ITEM_WRITE        | Allow |
      | MANAGE_TEST_PLANS      | Allow |
      | MANAGE_TEST_SUITES     | Allow |
      | WORK_ITEM_SAVE_COMMENT | Allow |


      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ           | Allow |
      | GENERIC_WRITE          | Allow |
      | CREATE_CHILDREN        | Allow |
      | DELETE                 | Allow |
      | WORK_ITEM_READ         | Allow |
      | WORK_ITEM_WRITE        | Allow |
      | MANAGE_TEST_PLANS      | Allow |
      | MANAGE_TEST_SUITES     | Allow |
      | WORK_ITEM_SAVE_COMMENT | Allow |


      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ           | Allow |
      | GENERIC_WRITE          | Allow |
      | CREATE_CHILDREN        | Deny |
      | DELETE                 | Deny |
      | WORK_ITEM_READ         | Allow |
      | WORK_ITEM_WRITE        | Allow |
      | MANAGE_TEST_PLANS      | Allow |
      | MANAGE_TEST_SUITES     | Allow |
      | WORK_ITEM_SAVE_COMMENT | Allow |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ           | Allow |
      | GENERIC_WRITE          | Allow |
      | CREATE_CHILDREN        | Deny |
      | DELETE                 | Deny |
      | WORK_ITEM_READ         | Allow |
      | WORK_ITEM_WRITE        | Allow |
      | MANAGE_TEST_PLANS      | Allow |
      | MANAGE_TEST_SUITES     | Allow |
      | WORK_ITEM_SAVE_COMMENT | Allow |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ           | Allow |
      | GENERIC_WRITE          | Allow |
      | CREATE_CHILDREN        | Deny |
      | DELETE                 | Deny |
      | WORK_ITEM_READ         | Allow |
      | WORK_ITEM_WRITE        | Allow |
      | MANAGE_TEST_PLANS      | Allow |
      | MANAGE_TEST_SUITES     | Allow |
      | WORK_ITEM_SAVE_COMMENT | Allow |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | GENERIC_READ           | Allow |
      | GENERIC_WRITE          | Allow |
      | CREATE_CHILDREN        | Allow |
      | DELETE                 | Allow |
      | WORK_ITEM_READ         | Allow |
      | WORK_ITEM_WRITE        | Allow |
      | MANAGE_TEST_PLANS      | Deny |
      | MANAGE_TEST_SUITES     | Deny |
      | WORK_ITEM_SAVE_COMMENT | Allow |

   - **Service Connection:**


      **For Platform Admin**: Administrator

      **For Lead Engineers**: Administrator

      **For Engineers**: User

      **For Lead Testers**: Reader

      **For Testers**: Reader

      **For Project Manager**: Reader

   - **Repositories:**


      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | Administer              | Allow |
      | GenericRead             | Allow |
      | GenericContribute       | Allow |
      | ForcePush               | Allow |
      | CreateBranch            | Allow |
      | CreateTag               | Allow |
      | ManageNote              | Allow |
      | PolicyExempt            | Deny |
      | CreateRepository        | Allow |
      | DeleteRepository        | Deny |
      | RenameRepository        | Allow |
      | EditPolicies            | Allow |
      | RemoveOthersLocks       | Allow |
      | ManagePermissions       | Allow |
      | PullRequestContribute   | Allow |
      | PullRequestBypassPolicy | Deny |


      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | Administer              | Deny |
      | GenericRead             | Allow |
      | GenericContribute       | Allow |
      | ForcePush               | Deny |
      | CreateBranch            | Allow |
      | CreateTag               | Allow |
      | ManageNote              | Allow |
      | PolicyExempt            | Deny |
      | CreateRepository        | Allow |
      | DeleteRepository        | Deny |
      | RenameRepository        | Allow |
      | EditPolicies            | Allow |
      | RemoveOthersLocks       | Allow |
      | ManagePermissions       | Allow |
      | PullRequestContribute   | Allow |
      | PullRequestBypassPolicy | Deny |


      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | Administer              | Deny |
      | GenericRead             | Allow |
      | GenericContribute       | Allow |
      | ForcePush               | Deny |
      | CreateBranch            | Allow |
      | CreateTag               | Allow |
      | ManageNote              | Allow |
      | PolicyExempt            | Deny |
      | CreateRepository        | Deny |
      | DeleteRepository        | Deny |
      | RenameRepository        | Deny |
      | EditPolicies            | Deny |
      | RemoveOthersLocks       | Deny |
      | ManagePermissions       | Deny |
      | PullRequestContribute   | Allow |
      | PullRequestBypassPolicy | Deny |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | Administer              | Deny |
      | GenericRead             | Allow |
      | GenericContribute       | Allow |
      | ForcePush               | Deny |
      | CreateBranch            | Allow |
      | CreateTag               | Allow |
      | ManageNote              | Allow |
      | PolicyExempt            | Deny |
      | CreateRepository        | Deny |
      | DeleteRepository        | Deny |
      | RenameRepository        | Deny |
      | EditPolicies            | Deny |
      | RemoveOthersLocks       | Deny |
      | ManagePermissions       | Deny |
      | PullRequestContribute   | Allow |
      | PullRequestBypassPolicy | Deny |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | Administer              | Deny |
      | GenericRead             | Allow |
      | GenericContribute       | Allow |
      | ForcePush               | Deny |
      | CreateBranch            | Allow |
      | CreateTag               | Allow |
      | ManageNote              | Allow |
      | PolicyExempt            | Deny |
      | CreateRepository        | Deny |
      | DeleteRepository        | Deny |
      | RenameRepository        | Deny |
      | EditPolicies            | Deny |
      | RemoveOthersLocks       | Deny |
      | ManagePermissions       | Deny |
      | PullRequestContribute   | Allow |
      | PullRequestBypassPolicy | Deny |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | Administer              | Deny |
      | GenericRead             | Allow |
      | GenericContribute       | Deny |
      | ForcePush               | Deny |
      | CreateBranch            | Deny |
      | CreateTag               | Deny |
      | ManageNote              | Deny |
      | PolicyExempt            | Deny |
      | CreateRepository        | Deny |
      | DeleteRepository        | Deny |
      | RenameRepository        | Deny |
      | EditPolicies            | Deny |
      | RemoveOthersLocks       | Deny |
      | ManagePermissions       | Deny |
      | PullRequestContribute   | Deny |
      | PullRequestBypassPolicy | Deny |

   - **Work item queries:**


      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | Read              | Allow |
      | Delete            | Allow |
      | Contribute        | Allow |
      | ManagePermissions | Allow |


      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | Read              | Allow |
      | Delete            | Allow |
      | Contribute        | Allow |
      | ManagePermissions | Allow |

      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | Read              | Allow |
      | Delete            | Allow |
      | Contribute        | Allow |
      | ManagePermissions | Deny |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | Read              | Allow |
      | Delete            | Deny |
      | Contribute        | Allow |
      | ManagePermissions | Deny |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | Read              | Allow |
      | Delete            | Deny |
      | Contribute        | Allow |
      | ManagePermissions | Deny |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | Read              | Allow |
      | Delete            | Allow |
      | Contribute        | Allow |
      | ManagePermissions | Deny |

   - **Pipelines:**


      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | ViewBuilds                     | Allow |
      | EditBuildQuality               | Allow |
      | RetainIndefinitely             | Allow |
      | DeleteBuilds                   | Allow |
      | ManageBuildQualities           | Allow |
      | DestroyBuilds                  | Allow |
      | UpdateBuildInformation         | Allow |
      | QueueBuilds                    | Allow |
      | ManageBuildQueue               | Allow |
      | StopBuilds                     | Allow |
      | ViewBuildDefinition            | Allow |
      | EditBuildDefinition            | Allow |
      | DeleteBuildDefinition          | Allow |
      | OverrideBuildCheckInValidation | Allow |
      | AdministerBuildPermissions     | Allow |
      | CreateBuildDefinition          | Allow |


      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | ViewBuilds                     | Allow |
      | EditBuildQuality               | Allow |
      | RetainIndefinitely             | Allow |
      | DeleteBuilds                   | Allow |
      | ManageBuildQualities           | Allow |
      | DestroyBuilds                  | Allow |
      | UpdateBuildInformation         | Allow |
      | QueueBuilds                    | Allow |
      | ManageBuildQueue               | Allow |
      | StopBuilds                     | Allow |
      | ViewBuildDefinition            | Allow |
      | EditBuildDefinition            | Allow |
      | DeleteBuildDefinition          | Allow |
      | OverrideBuildCheckInValidation | Allow |
      | AdministerBuildPermissions     | Allow |
      | CreateBuildDefinition          | Allow |


      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | ViewBuilds                     | Allow |
      | EditBuildQuality               | Allow |
      | RetainIndefinitely             | Allow |
      | DeleteBuilds                   | Deny |
      | ManageBuildQualities           | Allow |
      | DestroyBuilds                  | Allow |
      | UpdateBuildInformation         | Allow |
      | QueueBuilds                    | Allow |
      | ManageBuildQueue               | Allow |
      | StopBuilds                     | Allow |
      | ViewBuildDefinition            | Allow |
      | EditBuildDefinition            | Allow |
      | DeleteBuildDefinition          | Deny |
      | OverrideBuildCheckInValidation | Deny |
      | AdministerBuildPermissions     | Deny |
      | CreateBuildDefinition          | Allow |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | ViewBuilds                     | Allow |
      | EditBuildQuality               | Deny |
      | RetainIndefinitely             | Deny |
      | DeleteBuilds                   | Deny |
      | ManageBuildQualities           | Deny |
      | DestroyBuilds                  | Deny |
      | UpdateBuildInformation         | Deny |
      | QueueBuilds                    | Deny |
      | ManageBuildQueue               | Deny |
      | StopBuilds                     | Deny |
      | ViewBuildDefinition            | Allow |
      | EditBuildDefinition            | Deny |
      | DeleteBuildDefinition          | Deny |
      | OverrideBuildCheckInValidation | Deny |
      | AdministerBuildPermissions     | Deny |
      | CreateBuildDefinition          | Deny |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | ViewBuilds                     | Allow |
      | EditBuildQuality               | Deny |
      | RetainIndefinitely             | Deny |
      | DeleteBuilds                   | Deny |
      | ManageBuildQualities           | Deny |
      | DestroyBuilds                  | Deny |
      | UpdateBuildInformation         | Deny |
      | QueueBuilds                    | Deny |
      | ManageBuildQueue               | Deny |
      | StopBuilds                     | Deny |
      | ViewBuildDefinition            | Allow |
      | EditBuildDefinition            | Deny |
      | DeleteBuildDefinition          | Deny |
      | OverrideBuildCheckInValidation | Deny |
      | AdministerBuildPermissions     | Deny |
      | CreateBuildDefinition          | Deny |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | ViewBuilds                     | Allow |
      | EditBuildQuality               | Deny |
      | RetainIndefinitely             | Deny |
      | DeleteBuilds                   | Deny |
      | ManageBuildQualities           | Deny |
      | DestroyBuilds                  | Deny |
      | UpdateBuildInformation         | Deny |
      | QueueBuilds                    | Deny |
      | ManageBuildQueue               | Deny |
      | StopBuilds                     | Deny |
      | ViewBuildDefinition            | Allow |
      | EditBuildDefinition            | Deny |
      | DeleteBuildDefinition          | Deny |
      | OverrideBuildCheckInValidation | Deny |
      | AdministerBuildPermissions     | Deny |
      | CreateBuildDefinition          | Deny |

   - **Environments:**


      **For Platform Admin**: Administrator

      **For Lead Engineers**: Administrator

      **For Engineers**: User

      **For Lead Testers**: Reader

      **For Testers**: Reader

      **For Project Manager**: Reader

   - **Library:**


      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | View        | Allow |
      | Create      | Allow |
      | Use         | Allow |
      | Administer  | Allow |
      | ViewSecrets | Allow |
      | Owner       | Allow |


      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | View        | Allow |
      | Create      | Allow |
      | Use         | Allow |
      | Administer  | Allow |
      | ViewSecrets | Allow |
      | Owner       | Allow |


      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | View        | Allow |
      | Create      | Allow |
      | Use         | Allow |
      | Administer  | Deny |
      | ViewSecrets | Allow |
      | Owner       | Deny |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | View        | Allow |
      | Create      | Deny |
      | Use         | Allow |
      | Administer  | Deny |
      | ViewSecrets | Allow |
      | Owner       | Deny |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | View        | Allow |
      | Create      | Deny |
      | Use         | Allow |
      | Administer  | Deny |
      | ViewSecrets | Allow |
      | Owner       | Deny |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | View        | Allow |
      | Create      | Deny |
      | Use         | Allow |
      | Administer  | Deny |
      | ViewSecrets | Deny |
      | Owner       | Deny |

   - **Tagging:**


      **For Platform Admin**

      | Permission | Assigned |
      | ----- | ---- |
      | Enumerate | Allow |
      | Create    | Allow |
      | Update    | Allow |
      | Delete    | Allow |


      **For Lead Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | Enumerate | Allow |
      | Create    | Allow |
      | Update    | Allow |
      | Delete    | Allow |


      **For Engineers**

      | Permission | Assigned |
      | ----- | ---- |
      | Enumerate | Allow |
      | Create    | Allow |
      | Update    | Allow |
      | Delete    | Allow |


      **For Lead Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | Enumerate | Allow |
      | Create    | Allow |
      | Update    | Allow |
      | Delete    | Deny |


      **For Testers**

      | Permission | Assigned |
      | ----- | ---- |
      | Enumerate | Allow |
      | Create    | Allow |
      | Update    | Allow |
      | Delete    | Deny |


      **For Project Manager**

      | Permission | Assigned |
      | ----- | ---- |
      | Enumerate | Allow |
      | Create    | Allow |
      | Update    | Allow |
      | Delete    | Allow |



4. **Service Connections / CI/CD Credentials**
   - **Build SC**: `sc-build-${app_short}-${environment}-${locationShort}-${instance}`
   - **Deploy SC**: `sc-deploy-${app_short}-${environment}-${locationShort}-${instance}`

5. **Environmets**
   - Name = `${environment}`

6. **Library**
   - Name = `${environment}`

7. **Set Up Pipeline**
   - Once the bootstrap has been deployed to a file called BOOTSTRAP-OUTPUTS.${environment}.md will be created. This holds the following settigns which can be copied over to your pipeline.
      - **State Settings**
         - Subscription ID
         - Resource Group Name
         - Storage Account Name
         - Containers
      - **User Managed Identities for Build and Deply**
         - Name
         - Principal ID
         - Object ID / Client ID
      - **Service Connection**
         - Build Service Connection
         - Deploy Service Connection
