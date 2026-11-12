# snapcd-deployment-azure

This repository deploys Snap CD on Azure. A second Snap CD installation, the bootstrap, does the deployment. The bootstrap runs on your machine with Docker Compose.

The deployment has two parts:

- The platform: a resource group, a virtual network, an AKS cluster, an Istio gateway with a public IP address, cert-manager with Let's Encrypt issuers, and the Azure Workload Identity webhook.
- Snap CD: the Server, a Runner and an Agent. Each one has three Modules: infra (Azure resources), infra-config (generated keys and secrets) and app (the Helm chart).

## Layout

```
./                      Terraform root: the Snap CD configuration that you apply to the bootstrap
roots/<name>/           one directory for each Snap CD Module
modules/                shared child modules (akv, workload-identity, kustomization)
```

Each Module reads its code from `roots/<name>` on the `main` branch of this repository. The bootstrap namespace uses path filters. A commit starts jobs only for the Modules whose directories it changes.

## What each Module deploys

| Module | Root | Deploys |
|---|---|---|
| `base` | `roots/base` | The resource group |
| `network` | `roots/network` | The virtual network and the `apps`, `system` and `ingress` subnets |
| `cluster` | `roots/cluster` | The AKS cluster, its node pools and the Secrets Store CSI driver add-on |
| `istio_infra` | `roots/istio-infra` | The public IP address of the gateway, and an optional Azure DNS record |
| `istio` | `roots/k8s-istio` | Istio and the Istio gateway |
| `cert_manager` | `roots/k8s-cert-manager` | cert-manager |
| `cert_manager_cluster_issuer` | `roots/k8s-cert-manager-cluster-issuer-letsencrypt` | The `letsencrypt-staging` and `letsencrypt-prod` ClusterIssuers |
| `awi_webhook` | `roots/k8s-awi-webhook` | The Azure Workload Identity webhook |
| `snapcd_server_infra` | `roots/snapcd-server-infra` | The Server Key Vault, the Server workload identity, the Azure SQL server and database, and an optional Service Bus namespace |
| `snapcd_server_infra_config` | `roots/snapcd-server-infra-config` | The Server keys, the admin password and the Runner and Agent client secrets, in the Server Key Vault. The database user for the Server workload identity |
| `snapcd_server_app` | `roots/snapcd-server-app` | The `snapcd-server` chart, its certificate, Istio Gateway and VirtualService |
| `snapcd_runner_infra` | `roots/snapcd-runner-infra` | The Runner Key Vault and the Runner workload identity |
| `snapcd_runner_infra_config` | `roots/snapcd-runner-infra-config` | The Runner SSH key, in the Runner Key Vault |
| `snapcd_runner_app` | `roots/snapcd-runner-app` | The `snapcd-runner` chart |
| `snapcd_agent_infra` | `roots/snapcd-agent-infra` | The Agent workload identity, and its access to the backend Key Vault secrets |
| `snapcd_agent_app` | `roots/snapcd-agent-app` | The `snapcd-agent` chart, and the Claude sidecar when a Claude credential is set |

All keys, passwords and client secrets go into Key Vault. The `azrandom` provider generates most of them directly in the Key Vault, so their values are not in the Terraform state. The Server reads them through `externalsettings.json` and its workload identity. The Runner SSH key and the Agent credentials are files. The Secrets Store CSI driver mounts these files from Key Vault.

The Runner and the Agent do not use client secrets. Each one signs in to the Server with its projected ServiceAccount token. The Server seeds a Federated Credential for each one, with the AKS OIDC issuer and the ServiceAccount as the subject. The Runner jobs use the same token for the Snap CD provider and for the State Store. The `default` Service Principal keeps its client secret in the Server Key Vault, as `snapcd-runner-client-secret`. Use it to apply a configuration to the Server from your machine.

## Prerequisites

1. An Azure subscription. Your Azure user must be able to create resources and role assignments in it.
2. An Entra group for administrators. The group becomes the administrator of the Key Vaults, the AKS cluster and the SQL server. Your Azure user must be a member of it, because the bootstrap Runner signs in to the SQL server as your user.
3. OpenTofu on your machine.
4. The bootstrap Snap CD. Start it from `serving/snapcd-deployment-docker`. See "Start the bootstrap".
5. Optional: a backend Key Vault for the Agent credentials. See "Agent credentials".

## Start the bootstrap

The bootstrap Runner signs in to Azure with the Azure CLI. Its home directory is in memory, so the sign-in is lost when the container restarts.

1. In `serving/snapcd-deployment-docker`, start the stack and sign the Runner in to Azure:

   ```bash
   docker compose up -d && docker compose exec snapcd-runner sh -c 'az config set core.login_experience_v2=off && az login && az account set --subscription <subscription-id>'
   ```

2. Open the URL that `az login` shows, and enter the code.
3. Make sure that the bootstrap has a licence. The deployment has more than 10 Modules, which is the Community limit.
4. Make sure that the Runner can clone this repository over SSH.

The bootstrap Server is at `http://localhost:5000`. The Runner reaches it at `http://snapcd-server:5000`. These are the defaults of `bootstrap_snapcd_url` and `bootstrap_snapcd_server_url_from_runner`.

## Configure

1. Copy `terraform.tfvars.example` to `terraform.tfvars`. Git ignores `terraform.tfvars`.
2. Set the bootstrap credentials: `bootstrap_snapcd_client_id`, `bootstrap_snapcd_client_secret`, `bootstrap_snapcd_organization_id` and `bootstrap_runner_name`.
3. Set the Azure values: `tenant_id`, `subscription_id`, `location` and `administrator_object_id`.
4. Set the options that you need. See "Options".

### Main variables

| Variable | Default | Description |
|---|---|---|
| `bootstrap_snapcd_url` | `http://localhost:5000` | The bootstrap Server, as your machine reaches it |
| `bootstrap_snapcd_server_url_from_runner` | `http://snapcd-server:5000` | The bootstrap Server, as the bootstrap Runner reaches it |
| `bootstrap_stack_name` | `bootstrap` | The stack on the bootstrap that holds this deployment |
| `bootstrap_namespace_name` | `azure` | The namespace on the bootstrap that holds the Modules |
| `name` | `snapcd` | The name of the resource group, the virtual network and the AKS cluster |
| `public_dns_label` | `name` | The Azure DNS label of the Server: `<label>.<location>.cloudapp.azure.com` |
| `public_dns_label_random_suffix` | `true` | Adds a hyphen and five random characters to the label. See "DNS" |
| `snapcd_server_name` | `snapcd-server` | The Kubernetes namespace and release of the Server, and the prefix of its Azure resources |
| `snapcd_runner_name` | `snapcd-runner` | The same for the Runner |
| `snapcd_agent_name` | `snapcd-agent` | The same for the Agent |

## Apply

1. In the repository root, run:

   ```bash
   tofu init
   tofu apply
   ```

   This creates the stack, the namespace and the Modules on the bootstrap. The bootstrap then starts a job for each Module.

2. Open the bootstrap Dashboard. Find the Modules under the stack and namespace that you set.
3. Approve each job. The namespace requires one approval for each apply and each destroy.

Snap CD runs the Modules in dependency order. Approve `snapcd_server_infra_config` before `snapcd_server_app`. The Server needs its database user before it starts.

The first run takes some time:

- The AKS cluster takes 15 to 20 minutes.
- `snapcd_server_infra` and `snapcd_runner_infra` wait 120 seconds for Key Vault role assignments.
- The Server chart waits until the Server is ready. The Server message bus can take some minutes to start.

## After the deployment

### Open the Dashboard

The Server is at `https://<label>.<location>.cloudapp.azure.com`. By default, the label is `name` and five random characters, for example `platform-k3x9q`. The `url` output of `snapcd_server_app` shows the address. If you set an Azure DNS zone, the Server is also at `<dns_record_name>.<dns_zone_name>`.

### Sign in

The admin user is `admin@preseeded.io`. The `admin_email` output of `snapcd_server_app` shows it. The password is in the Server Key Vault, in the secret `snapcd-server-admin-password`. To read it:

```bash
az keyvault secret show --vault-name <server-key-vault> --name snapcd-server-admin-password --query value -o tsv
```

The `snapcd_server_akv_url` output of `snapcd_server_infra` shows the Server Key Vault.

### Apply a licence

The new Server starts with the Community limits. The Agent needs an Enterprise licence. Without one, the Agent cannot get a token, and its log shows "Agent hub connect failed" with HTTP 400. Apply the licence on the License page of the Dashboard.

### Connect to the cluster

```bash
az aks get-credentials --name <name> --resource-group <name> --subscription <subscription-id>
```

The `login_instructions` output of `cluster` shows the full command.

### Let the Runner clone repositories

The `snapcd_runner_ssh_public_key_openssh` output of `snapcd_runner_infra_config` is the public SSH key of the Runner. Add it as a deploy key to each repository that the Runner clones.

## Options

### DNS

By default, the Server uses the Azure DNS label of the gateway IP address: `<label>.<location>.cloudapp.azure.com`. Let's Encrypt issues the certificate for this name.

The label is unique in an Azure region. So by default, `istio_infra` adds a hyphen and five random characters to the label, for example `platform-k3x9q`. The label is `public_dns_label`, or `name` when you do not set it. It generates the characters one time and keeps them in its state, so the address does not change when you apply again. To use the label exactly, set `public_dns_label_random_suffix = false`. The label must then be free in the region.

To also publish the gateway in an Azure DNS zone that you own, set `dns_zone_name` and `dns_zone_resource_group_name`. `dns_record_name` sets the record name. The default is `snapcd`. The zone must exist before you apply.

### Database size

`snapcd_server_sql_database_sku` sets the service objective of the Server's Azure SQL database. The default is `S1` (20 DTU). Use `S2` (50 DTU) or larger for many Modules or many users. Do not use `Basic` (5 DTU): with jobs running, the Server's queries time out and the Dashboard becomes slow.

### Message bus

`snapcd_server_bus_type` sets the message bus of the Server.

- `AzureServiceBus` (default): `snapcd_server_infra` creates a Standard Service Bus namespace. The Server workload identity gets the Azure Service Bus Data Owner role on it.
- `SqlServer`: the bus uses the Server database. No Service Bus namespace is created.

### Agent credentials

The Agent runs without its Claude sidecar by default. The sidecar reads its credentials from a backend Key Vault. You create this Key Vault and put the secrets in it yourself.

1. Create a Key Vault with Azure RBAC authorization.
2. Put the Claude credential in it, as one of these secrets:
   - `snapcd-agent-claude-code-oauth-token`: a Claude subscription token, from `claude setup-token`.
   - `snapcd-agent-anthropic-api-key`: an Anthropic API key.
3. Optional: put a GitHub token in it, as `snapcd-agent-github-token`.
4. Set these variables:

   ```hcl
   backend_akv_name                = "<key-vault>"
   backend_akv_resource_group_name = "<resource-group>"
   claude_credential               = "OAuthToken" # or "ApiKey"
   github_token_enabled            = true         # only if the GitHub token exists
   ```

**CAUTION:** Add each secret to the Key Vault before you enable it. If an enabled secret does not exist, the role assignment in `snapcd_agent_infra` fails, and the sidecar cannot mount its credentials.

`claude_credential = "None"` turns the sidecar off. With `None`, the deployment reads no secrets from the backend Key Vault. You can change the secret names with `claude_oauth_token_secret_name`, `anthropic_api_key_secret_name` and `github_token_secret_name`.

## Troubleshooting

### The Istio gateway pod shows ImagePullBackOff for the image "auto"

The gateway pod started before istiod was ready, so Istio did not inject the proxy. Restart the gateway:

```bash
kubectl -n istio-gateway rollout restart deployment istio-gateway
```

### A job plans to create a Helm release that already exists

A failed install can leave a release in the cluster that the Terraform state does not have. The releases use `atomic`, so Helm removes a failed install. If an old release remains, remove it, then run the job again:

```bash
helm uninstall <release> -n <namespace>
```

### The Server fails with "Login failed" for "<token-identified principal>"

The Server signs in to Azure SQL with its workload identity. `snapcd_server_infra_config` creates the database user for this identity. Make sure that this Module completed before the Server started. The Server needs Snap CD 1.16.4 or later for this sign-in.

### A secret-scoped role assignment fails

The secret does not exist yet. Make sure that the infra-config Module that creates the secret completed. For the backend Key Vault, add the secret by hand.
