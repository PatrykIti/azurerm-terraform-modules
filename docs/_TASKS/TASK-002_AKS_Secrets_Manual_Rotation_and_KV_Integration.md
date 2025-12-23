# TASK-002: AKS secrets – manual rotation (TF) + standard KV/CSI/ESO
# FileName: TASK-002_AKS_Secrets_Manual_Rotation_and_KV_Integration.md

**Priority:** 🔴 High  
**Category:** Terraform Module (AKS / Secrets)  
**Estimated Effort:** Large  
**Dependencies:** TASK-001 (AKS module stabilizacja)  
**Status:** ✅ **Done** (2025-12-23)

---

## Cel

Dodać spójne, “przyjazne dla ludzi” podejście do zarządzania sekretami dla workloadów na AKS, obejmujące dwa warianty:

1) **Standard (runtime)**: integracja z Azure Key Vault poprzez **CSI Secrets Store** i/lub **External Secrets Operator (ESO)** – bez przenoszenia wartości sekretów do state Terraforma.  
2) **Manual rotation (Terraform jako pośrednik)**: Terraform czyta sekrety z Key Vault i tworzy/aktualizuje **Kubernetes Secret** – z możliwością “pinowania” wersji i ręcznego sterowania rotacją.

Manual jest **pełnoprawną, wspieraną ścieżką**, aby w wybranych przypadkach **nie używać KV/CSI/ESO w runtime** i uniknąć spowolnień rolloutów/`helm upgrade`.

---

## Kontekst / problem

W niektórych scenariuszach (np. dużo sekretów + częste releasy) podłączenie workloadów “wprost” do KV (CSI/ESO) może wydłużać rollout/`helm upgrade` (np. przez rotację/pobieranie i synchronizację). Celem jest możliwość wyboru: bezpieczeństwo i “runtime sync” vs. przewidywalność i ręczne sterowanie rotacją.

---

## Zakres (co ma powstać)

### 1) Nowy moduł: `modules/azurerm_kubernetes_secrets/` (propozycja nazwy)

Moduł ma zapewniać **jednolite API** dla trzech strategii:

- `strategy = "manual"`: KV → (Terraform) → Kubernetes Secret  
- `strategy = "csi"`: KV → CSI SecretProviderClass (opcjonalnie sync do K8s Secret)  
- `strategy = "eso"`: KV → ESO ExternalSecret/SecretStore (runtime sync)

> Uwaga: instalacja CSI/ESO (np. przez Helm) może być poza zakresem modułu (oddzielny moduł/addon). Ten moduł może tworzyć jedynie zasoby konfiguracyjne w klastrze.

### 2) Dokumentacja i przykłady

- README dla modułu, z jasnym “kiedy użyć której strategii”.
- Przykłady użycia (co najmniej):
  - `examples/basic/` (manual: KV → TF → K8s Secret)
  - `examples/complete/` (CSI: SecretProviderClass + opcjonalny sync do K8s Secret)
  - `examples/secure/` (ESO: SecretStore + ExternalSecret, runtime bez sekretów w state)

Nazwy katalogów **muszą** być spójne ze standardem repo i AKS module (`basic`, `complete`, `secure`), ponieważ dokumentacja i skrypty opierają się na tych nazwach.

### 3) Bezpieczeństwo i operacje (ważne!)

Moduł musi w README jasno rozróżniać:

- **Manual (TF)**: wartości sekretów będą w **Terraform state** (wymaga bezpiecznego backendu, twardego RBAC, braku logowania planów z “sensitive” wartościami, itp.).  
- **CSI/ESO**: wartości sekretów nie trafiają do state, ale runtime może mieć opóźnienia/“eventual consistency”.

### 4) Integracja z AKS module (ważne)

Moduł `azurerm_kubernetes_secrets` **nie tworzy** klastra AKS, ale powinien być spójny z istniejącym `modules/azurerm_kubernetes_cluster/`:

- `strategy = "csi"` zakłada, że w AKS włączono `key_vault_secrets_provider` (addon CSI) oraz skonfigurowano odpowiednią tożsamość i uprawnienia do KV.
- `strategy = "eso"` zakłada, że ESO jest zainstalowane w klastrze (poza zakresem modułu; preferowany osobny addon/helm).
- Przykłady powinny pokazać “pełny flow”: AKS outputs (`oidc_issuer_url`, `key_vault_secrets_provider` itd.) → konfiguracja auth w module sekretów → obiekty K8s.
- W dokumentacji i przykładach jawnie mapujemy wyjścia z AKS modułu:
  - `module.kubernetes_cluster.oidc_issuer_url` + `module.kubernetes_cluster.identity.tenant_id` → konfiguracja Workload Identity (FIC poza modułem, ale pokazana w przykładach).
  - `module.kubernetes_cluster.key_vault_secrets_provider.*` → MSI/Client ID dla CSI (jeśli wymagane przez KV policy/RBAC).

---

## Bloki Terraforma (co będzie użyte)

### Wspólne (dla modułu)

- `terraform { required_version, required_providers }`
  - `hashicorp/azurerm` – odczyt z Key Vault (pin `4.57.0`, docelowy standard repo)
  - `hashicorp/kubernetes` – tworzenie `Secret` + CRD manifesty (`kubernetes_manifest`)
  - opcjonalnie: `hashicorp/helm` – tylko jeśli zdecydujemy się instalować CSI/ESO w tym module (preferowane jako osobny moduł/addon)
- `locals { ... }` – normalizacja mapowań (np. keys, nazwy, adnotacje)
- `variable` + `validation` – walidacje per `strategy`
- `output` – nazwy/ID tworzonej konfiguracji (np. `kubernetes_secret_name`, `secret_provider_class_name`, `external_secret_name`)

### `strategy = "manual"` (KV → TF → Kubernetes Secret)

- `data "azurerm_key_vault_secret" "..."` (z opcjonalnym `version` = pinowanie do manual rotation)
- `resource "kubernetes_secret_v1" "..."`
  - `metadata { name, namespace, labels, annotations }`
  - `data`/`string_data` mapujące klucze na wartości

### `strategy = "csi"` (KV → CSI Secrets Store)

- `resource "kubernetes_manifest" "secret_provider_class" { ... }`
  - `SecretProviderClass` (`secrets-store.csi.x-k8s.io/v1`)
  - `parameters.objects` (opcjonalnie `objectVersion`)
- opcjonalnie (gdy `sync_to_kubernetes_secret = true`):
  - `secretObjects` w `SecretProviderClass` (sync do K8s Secret)

### `strategy = "eso"` (KV → External Secrets Operator)

- `resource "kubernetes_manifest" "secret_store" { ... }`
  - `SecretStore` / `ClusterSecretStore` (`external-secrets.io/v1beta1`)
- `resource "kubernetes_manifest" "external_secret" { ... }`
  - `ExternalSecret` (`external-secrets.io/v1beta1`)
- gdy `auth.type = "service_principal"`:
  - `resource "kubernetes_secret_v1" "eso_sp_credentials"` (sekret z `client_id`/`client_secret`)
  - `SecretStore` referuje ten sekret przez `authSecretRef`

---

## Skrypty (czy będą i do czego)

Zakładamy **brak nowych skryptów “produktowych”** do rotacji; manual rotation ma się odbywać przez zmianę `key_vault_secret_version` i `terraform apply`.

W trakcie wdrożenia modułu wykorzystamy istniejące narzędzia repo:

- `scripts/create-new-module.sh` – wygenerowanie szkieletu modułu (z templates)
- `./modules/<moduł>/generate-docs.sh` + `terraform-docs` – generowanie README
- `scripts/update-examples-list.sh` – aktualizacja listy przykładów w README modułu

Opcjonalnie (jeśli będzie realna potrzeba): mały helper do “pinowania” wersji (np. generowanie `.tfvars`), ale tylko jeśli będzie zgodny ze standardami repo i bez wciągania dodatkowych zależności.

---

## Struktura przykładów (wymóg)

Utrzymujemy **tę samą strukturę** co `modules/azurerm_kubernetes_cluster/examples/*`:

- `examples/<example>/README.md`
- `examples/<example>/main.tf`
- `examples/<example>/variables.tf`
- `examples/<example>/outputs.tf`
- (preferowane) `examples/<example>/.terraform-docs.yml`

Analogicznie dla fixtures (jak w `modules/azurerm_kubernetes_cluster/tests/fixtures/*`):

- `tests/fixtures/<fixture>/README.md` (jeśli dotyczy)
- `tests/fixtures/<fixture>/main.tf`
- `tests/fixtures/<fixture>/variables.tf`
- `tests/fixtures/<fixture>/outputs.tf`

---

## Minimalny flow w przykładach (AKS outputs → auth → obiekty K8s)

W przykładach pokazujemy **pełną ścieżkę**: AKS outputs → konfiguracja auth/identity → obiekty K8s.

**Checklisty wymagań (manual / csi / eso):**

- Manual (KV → TF → K8s Secret):
  - Dostęp TF do KV: `data.azurerm_key_vault_secret` musi mieć uprawnienia do odczytu
  - Provider `kubernetes` skonfigurowany (kubeconfig z AKS)
  - Świadomość, że wartości trafią do state
- CSI (SecretProviderClass):
  - AKS: `key_vault_secrets_provider` włączony
  - KV RBAC/Access Policy dla `module.kubernetes_cluster.key_vault_secrets_provider.secret_identity.object_id`
  - `SecretProviderClass` w namespace gdzie działa workload
  - (Opcjonalnie) `secretObjects` jeśli sync do K8s Secret jest wymagany
- ESO (SecretStore/ExternalSecret):
  - ESO zainstalowane w klastrze (CRD dostępne)
  - `SecretStore`/`ClusterSecretStore` + `ExternalSecret` w odpowiednim namespace
  - Auth zgodny z wybranym modelem (Workload Identity / SP / MI)

**Gotchas / uwagi praktyczne:**

- KV RBAC vs Access Policies: jeśli używasz `enable_rbac_authorization = true`, musisz dodać role RBAC (`Key Vault Secrets User`); w przeciwnym razie Access Policies.
- `kubernetes_manifest`: wymaga CRD w klastrze (ESO/CSI); bez CRD plan przejdzie, apply może się wywalić.
- `manual`: wartości sekretów trafiają do state; `sensitive = true` w outputach i brak logowania planów.
- `string_data` vs `data`: `string_data` przyjmuje plaintext i K8s sam base64-uje; `data` wymaga już base64.
- CSI sync: opcjonalny sync do K8s Secret może mieć opóźnienia; rollouty zależne od `secretObjects`.
- ESO refresh: `refresh_interval` ustawiaj świadomie (zbyt krótkie = load na API/KV).
- Name collisions: `SecretProviderClass` i `ExternalSecret` w tym samym namespace muszą mieć unikalne `metadata.name`.

### `examples/basic` (manual)

AKS module + Key Vault + sekrety KV + module secrets w trybie manual.

```hcl
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-secrets-basic"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-basic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-aks-basic"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=AKSv1.0.4"

  name                = "aks-basic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  dns_config = {
    dns_prefix = "aks-basic"
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2s_v3"
    node_count     = 1
    vnet_subnet_id = azurerm_subnet.example.id
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.kube_config.host
  client_certificate     = base64decode(module.kubernetes_cluster.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes_cluster.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes_cluster.kube_config.cluster_ca_certificate)
}

resource "azurerm_key_vault" "example" {
  name                = "kv-aks-basic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
  sku_name            = "standard"
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "change-me"
  key_vault_id = azurerm_key_vault.example.id
}

module "kubernetes_secrets" {
  source = "../../"

  strategy  = "manual"
  namespace = "app"
  name      = "app-secrets"

  manual = {
    key_vault_id           = azurerm_key_vault.example.id
    kubernetes_secret_type = "Opaque"
    secrets = [
      {
        name                     = "db-password"
        key_vault_secret_name    = azurerm_key_vault_secret.db_password.name
        key_vault_secret_version = null
        kubernetes_secret_key    = "DB_PASSWORD"
      }
    ]
  }
}
```

### `examples/complete` (csi)

AKS z włączonym `key_vault_secrets_provider` + `SecretProviderClass` (opcjonalnie sync do Secret).

```hcl
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-secrets-complete"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-complete"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-aks-complete"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=AKSv1.0.4"

  name                = "aks-complete"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  dns_config = {
    dns_prefix = "aks-complete"
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2s_v3"
    node_count     = 1
    vnet_subnet_id = azurerm_subnet.example.id
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.kube_config.host
  client_certificate     = base64decode(module.kubernetes_cluster.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes_cluster.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes_cluster.kube_config.cluster_ca_certificate)
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-aks-complete"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization  = true
  sku_name                   = "standard"
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "change-me"
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_role_assignment" "kv_csi" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.kubernetes_cluster.key_vault_secrets_provider.secret_identity.object_id
}

module "kubernetes_secrets" {
  source = "../../"

  strategy  = "csi"
  namespace = "app"
  name      = "app-spc"

  csi = {
    tenant_id                 = module.kubernetes_cluster.identity.tenant_id
    key_vault_name            = azurerm_key_vault.example.name
    sync_to_kubernetes_secret = true
    kubernetes_secret_name    = "app-secrets"
    objects = [
      {
        name           = "db-password"
        object_name    = "db-password"
        object_type    = "secret"
        object_version = null
        secret_key     = "DB_PASSWORD"
      }
    ]
  }
}
```

### `examples/secure` (eso + workload identity)

AKS z Workload Identity + ESO SecretStore/ExternalSecret.

```hcl
provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = "rg-aks-secrets-secure"
  location = "westeurope"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks-secure"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "snet-aks-secure"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "kubernetes_cluster" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/azurerm_kubernetes_cluster?ref=AKSv1.0.4"

  name                = "aks-secure"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  dns_config = {
    dns_prefix = "aks-secure"
  }

  identity = {
    type = "SystemAssigned"
  }

  default_node_pool = {
    name           = "default"
    vm_size        = "Standard_D2s_v3"
    node_count     = 1
    vnet_subnet_id = azurerm_subnet.example.id
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
  }

  features = {
    workload_identity_enabled = true
    oidc_issuer_enabled       = true
  }
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.kube_config.host
  client_certificate     = base64decode(module.kubernetes_cluster.kube_config.client_certificate)
  client_key             = base64decode(module.kubernetes_cluster.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.kubernetes_cluster.kube_config.cluster_ca_certificate)
}

resource "azurerm_key_vault" "example" {
  name                       = "kv-aks-secure"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization  = true
  sku_name                   = "standard"
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = "change-me"
  key_vault_id = azurerm_key_vault.example.id
}

resource "azurerm_user_assigned_identity" "eso" {
  name                = "uai-eso"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_federated_identity_credential" "eso" {
  name                = "eso-fic"
  resource_group_name = azurerm_resource_group.example.name
  parent_id           = azurerm_user_assigned_identity.eso.id
  issuer              = module.kubernetes_cluster.oidc_issuer_url
  subject             = "system:serviceaccount:app:eso-sa"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "kv_eso" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.eso.principal_id
}

resource "kubernetes_service_account_v1" "eso" {
  metadata {
    name      = "eso-sa"
    namespace = "app"
    annotations = {
      "azure.workload.identity/client-id" = azurerm_user_assigned_identity.eso.client_id
    }
  }
}

module "kubernetes_secrets" {
  source = "../../"

  strategy  = "eso"
  namespace = "app"
  name      = "app-eso"

  eso = {
    secret_store = {
      kind           = "SecretStore"
      name           = "kv-store"
      tenant_id      = module.kubernetes_cluster.identity.tenant_id
      key_vault_name = azurerm_key_vault.example.name
      auth = {
        type = "workload_identity"
        workload_identity = {
          service_account_name      = kubernetes_service_account_v1.eso.metadata[0].name
          service_account_namespace = "app"
          client_id                 = azurerm_user_assigned_identity.eso.client_id
        }
      }
    }
    external_secrets = [
      {
        name             = "db-secret"
        refresh_interval = "1h"
        remote_ref = {
          name    = "db-password"
          version = null
        }
        target = {
          secret_name = "app-secrets"
          secret_key  = "DB_PASSWORD"
        }
      }
    ]
  }
}
```

#### Dodatkowe warianty auth dla ESO (opcjonalnie, działające)

Poniższe warianty są **wspierane przez ESO** dla Azure Key Vault. Używaj ich tylko, jeśli pasują do Twojego modelu tożsamości; w przeciwnym razie preferuj Workload Identity.

**Checklisty wymagan (per wariant):**

- Workload Identity:
  - AKS: `features.workload_identity_enabled = true` i `features.oidc_issuer_enabled = true`
  - UAI + `azurerm_federated_identity_credential` z `issuer = module.kubernetes_cluster.oidc_issuer_url`
  - ServiceAccount z adnotacja `azure.workload.identity/client-id`
  - KV RBAC: rola (np. `Key Vault Secrets User`) dla UAI
  - ESO zainstalowane w klastrze
- Service Principal:
  - Istniejacy SP (client_id/client_secret/tenant_id)
  - KV RBAC: rola dla SP object_id
  - K8s Secret z danymi SP (authSecretRef)
  - ESO zainstalowane w klastrze
- Managed Identity:
  - Tozsamosc przypieta do node pool (kubelet identity) lub inna dostepna w klastrze
  - KV RBAC: rola dla MI object_id
  - ESO zainstalowane w klastrze

**Service Principal (istniejący SP + KV RBAC):**

Założenia: masz już SP i jego `client_id`, `client_secret`, `object_id` (do RBAC).

```hcl
variable "eso_sp_client_id" {
  type = string
}

variable "eso_sp_client_secret" {
  type      = string
  sensitive = true
}

variable "eso_sp_object_id" {
  type = string
}

resource "azurerm_role_assignment" "kv_eso_sp" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.eso_sp_object_id
}

module "kubernetes_secrets" {
  source = "../../"

  strategy  = "eso"
  namespace = "app"
  name      = "app-eso-sp"

  eso = {
    secret_store = {
      kind           = "SecretStore"
      name           = "kv-store"
      tenant_id      = data.azurerm_client_config.current.tenant_id
      key_vault_name = azurerm_key_vault.example.name
      auth = {
        type = "service_principal"
        service_principal = {
          client_id     = var.eso_sp_client_id
          client_secret = var.eso_sp_client_secret
          tenant_id     = data.azurerm_client_config.current.tenant_id
        }
      }
    }
    external_secrets = [
      {
        name = "db-secret"
        remote_ref = {
          name    = "db-password"
          version = null
        }
        target = {
          secret_name = "app-secrets"
          secret_key  = "DB_PASSWORD"
        }
      }
    ]
  }
}
```

Opcjonalnie można nadpisać nazwy kluczy w Sekrecie K8s (np. `username`/`password`), nadal pozostając przy auth typu **service_principal**:

```hcl
service_principal = {
  client_id     = var.eso_sp_client_id
  client_secret = var.eso_sp_client_secret
  tenant_id     = data.azurerm_client_config.current.tenant_id
  secret_keys = {
    client_id     = "username"
    client_secret = "password"
  }
}
```

**Managed Identity (node-assigned / kubelet identity):**

Założenia: identity jest przypięta do node pool (kubelet identity) i ma RBAC do KV.

```hcl
resource "azurerm_role_assignment" "kv_eso_mi" {
  scope                = azurerm_key_vault.example.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.kubernetes_cluster.kubelet_identity.object_id
}

module "kubernetes_secrets" {
  source = "../../"

  strategy  = "eso"
  namespace = "app"
  name      = "app-eso-mi"

  eso = {
    secret_store = {
      kind           = "SecretStore"
      name           = "kv-store"
      tenant_id      = data.azurerm_client_config.current.tenant_id
      key_vault_name = azurerm_key_vault.example.name
      auth = {
        type = "managed_identity"
        managed_identity = {
          client_id = module.kubernetes_cluster.kubelet_identity.client_id
        }
      }
    }
    external_secrets = [
      {
        name = "db-secret"
        remote_ref = {
          name    = "db-password"
          version = null
        }
        target = {
          secret_name = "app-secrets"
          secret_key  = "DB_PASSWORD"
        }
      }
    ]
  }
}
```

## Proponowane API modułu (szkic)

### Wspólne wejścia (dla wszystkich strategii)

- `namespace` (string)
- `name` (string) – nazwa “obiektu” (np. Secret / SecretProviderClass / ExternalSecret)
- `labels` / `annotations` (map)

---

## Konwencje wejść (czytelność dla użytkowników)

W większości miejsc, gdzie potrzebujemy iteracji po wielu elementach, preferujemy:

- **`list(object(...))`** zamiast `map(object(...))` (wejściowo)
- wewnętrznie w module: konwersję na mapę pod `for_each` przez wzorzec:
  - `{ for x in var.xs : x.name => x }`
- **snake_case** w nazwach zmiennych wejściowych (spójne z repo i AKS module)
- w manifestach K8s mapujemy do camelCase tylko tam, gdzie wymagają tego CRD (np. `objectVersion`, `secretObjects`)

### Dlaczego takie podejście

- **Czytelniejsze dla użytkowników modułu:** dla wielu osób (zwłaszcza uczących się TF) lista obiektów jest bardziej intuicyjna niż zagnieżdżone mapy.
- **Spójny schemat pracy:** użytkownik dodaje kolejny element jako “kolejny obiekt” (kopiuj/wklej), a moduł sam mapuje to do stabilnego klucza.
- **Lepsza ergonomia w PR-ach:** diffs w listach są często bardziej zrozumiałe (widać dodany/usunięty obiekt), a kluczem w module jest jawne `name`.
- **Stabilne `for_each`:** mapowanie po `name` zapewnia deterministyczne klucze zasobów i mniejsze ryzyko “recreate” przy przestawianiu kolejności listy.

Wymóg: `name` musi być unikalne w obrębie listy → moduł powinien mieć walidację unikalności.

---

## UX / user-friendly guidelines (dla tego modułu)

Cel: maksymalnie proste wejścia dla użytkownika, bez utraty kontroli nad przypadkami “manual / csi / eso”.

**Projekt API i defaulty:**
- jeden poziom “root” (`strategy`, `namespace`, `name`) + dokładnie **jedna** sekcja strategii (`manual`/`csi`/`eso`).
- `namespace` i `name` używane konsekwentnie jako `metadata.name`/`metadata.namespace` dla obiektów K8s (bez ukrytego sufiksowania).
- `labels` i `annotations` aplikowane do wszystkich zasobów K8s.
- `key_vault_name` preferowane nad `key_vault_url` (URL wyliczany w `locals`), ale dopuszczamy oba.
- `kubernetes_secret_type` domyślnie `"Opaque"`.
- `refresh_interval` dla ESO domyślnie np. `"1h"` (jeśli brak – zostawić po stronie CRD).

**Walidacje i komunikaty:**
- walidacje powinny zwracać jasny komunikat “co i jak poprawić”.
- wymuszamy:
  - `strategy` zgodne z jedną sekcją (pozostałe `null`).
  - unikalność nazw w listach (`secrets[*].name`, `external_secrets[*].name`).
  - poprawne wartości `object_type` w CSI i `kind` w ESO.
  - wymagane pola przy `sync_to_kubernetes_secret = true`.

**Bezpieczeństwo UX:**
- nigdy nie outputujemy wartości sekretów.
- `client_secret` zawsze `sensitive`.
- README musi mieć ostrzeżenie, że `manual` trafia do state.

**Outputy przydatne użytkownikom:**
- `strategy` (string).
- `kubernetes_secret_name` (manual / csi sync).
- `secret_provider_class_name` (csi).
- `secret_store_name` + `external_secret_names` (eso).
- `namespace` i `name` jako echo wejść.

**Dokumentacja i decyzje:**
- README: krótki “decision tree”, trade-offy i tabela “kiedy manual vs csi vs eso”.
- README: sekcja “Permissions matrix” (jakie role dla KV w każdym wariancie).
- README: minimalny przykład wklejany z `examples/basic/main.tf`.

**Spójność z repo:**
- trzymamy standardy z `docs/MODULE_GUIDE/*` (strukturę, naming, examples).
- we wszystkich przykładach stosujemy naming wg `docs/MODULE_GUIDE/06-examples.md`.

---

## Gotowe fragmenty do README (do wklejenia)

**Decision tree (krótko):**
- **manual**: gdy zależy Ci na przewidywalnym rollout/`helm upgrade` i akceptujesz state z sekretami.
- **csi**: gdy chcesz runtime sync i możesz polegać na CSI (SecretProviderClass).
- **eso**: gdy chcesz runtime sync z dodatkowymi opcjami (np. refresh, target mapping) i masz ESO w klastrze.

**Permissions matrix (skrót):**

| Strategy | Identity | KV dostęp | State zawiera wartości |
|---|---|---|---|
| manual | TF (caller) | odczyt `azurerm_key_vault_secret` | tak |
| csi | AKS CSI MI | `Key Vault Secrets User` dla `key_vault_secrets_provider.secret_identity.object_id` | nie |
| eso (WI) | UAI + FIC | `Key Vault Secrets User` dla UAI | nie |
| eso (SP) | Service Principal | `Key Vault Secrets User` dla SP object_id | nie |
| eso (MI) | Managed Identity | `Key Vault Secrets User` dla MI object_id | nie |

### `strategy = "manual"` (KV → TF → K8s Secret)

- `key_vault_id` (string)
- `secrets` (list(object)):
  - `name` (string) – unikalny klucz do `for_each`
  - `key_vault_secret_name` (string)
  - `key_vault_secret_version` (optional(string)) – **pinowanie** wersji do manual rotation
  - `kubernetes_secret_key` (string) – klucz w `data` K8s Secret
- `kubernetes_secret_type` (optional(string), default `"Opaque"`)

Zasady:
- jeśli `key_vault_secret_version` jest ustawione → moduł czyta dokładnie tę wersję (manual rotation = zmieniamy version i robimy `apply`).  
- jeśli `key_vault_secret_version` jest `null` → moduł czyta “latest” (auto-update przy kolejnym `apply`) – opcjonalne, ale w README opisać konsekwencje.

### `strategy = "csi"` (KV → CSI)

- `tenant_id` (string)
- `key_vault_name` (string)
- `objects` (list(object)):
  - `object_name` (string)
  - `object_type` (string) – `secret`/`key`/`cert`
  - `object_version` (optional(string)) – pozwala “pinować” wersję w CSI (manualny switch)
- `sync_to_kubernetes_secret` (bool, default `false`)
- jeśli `sync_to_kubernetes_secret = true`:
  - `kubernetes_secret_name` + mapowanie keys → secretObjects

### `strategy = "eso"` (KV → ESO)

- `secret_store` (object):
  - `kind` (`SecretStore` / `ClusterSecretStore`)
  - `name`
  - `tenant_id`
  - `key_vault_url` / `key_vault_name`
  - `auth` (object) – jeden z wariantów:
    - `type = "workload_identity"`:
      - `service_account_name`
      - `service_account_namespace` (optional)
      - `client_id` (optional, jeśli nie wynika z kontekstu)
    - `type = "service_principal"`:
      - `client_id`
      - `client_secret` (sensitive)
      - `tenant_id`
    - `type = "managed_identity"`:
      - `client_id` (optional)
      - `resource_id` (optional)
- `external_secrets` (list(object)):
  - `remote_ref` (object):
    - `name` (string)
    - `version` (optional(string))
  - `target` (object):
    - `secret_name` (string)
    - `secret_key` (string)
  - `refresh_interval` (optional)

---

## Szczegółowy szkic API (types + walidacje)

Poniżej konkretna propozycja zmiennych wejściowych z typami oraz walidacjami (do dopracowania w implementacji).

### Wejścia wspólne

- `strategy` (string) – **required**, `manual`/`csi`/`eso`
  - walidacja: `contains(["manual","csi","eso"], var.strategy)`
- `namespace` (string) – **required**, DNS-1123
- `name` (string) – **required**, DNS-1123
- `labels` / `annotations` (map(string), default `{}`)

### `manual` (KV → TF → K8s Secret)

```
manual = object({
  key_vault_id            = string
  kubernetes_secret_type  = optional(string, "Opaque")
  secrets = list(object({
    name                     = string
    key_vault_secret_name    = string
    key_vault_secret_version = optional(string)
    kubernetes_secret_key    = string
  }))
})
```

Walidacje:
- `strategy == "manual"` → `manual != null`, `csi == null`, `eso == null`
- unikalność `secrets[*].name` i `secrets[*].kubernetes_secret_key`
- `kubernetes_secret_type` zgodny z K8s (np. `"Opaque"`, `"kubernetes.io/dockerconfigjson"`, itd.)

### `csi` (SecretProviderClass)

```
csi = object({
  tenant_id                  = string
  key_vault_name             = string
  sync_to_kubernetes_secret  = optional(bool, false)
  kubernetes_secret_name     = optional(string)
  objects = list(object({
    name           = string
    object_name    = string
    object_type    = string   # secret|key|cert
    object_version = optional(string)
    secret_key     = optional(string) # wymagane jeśli sync_to_kubernetes_secret=true
  }))
})
```

Walidacje:
- `strategy == "csi"` → `csi != null`, `manual == null`, `eso == null`
- `object_type` w `["secret","key","cert"]`
- jeśli `sync_to_kubernetes_secret = true` → `kubernetes_secret_name` i `objects[*].secret_key` wymagane

### `eso` (SecretStore + ExternalSecret)

```
eso = object({
  secret_store = object({
    kind           = string # SecretStore|ClusterSecretStore
    name           = string
    tenant_id      = string
    key_vault_url  = optional(string)
    key_vault_name = optional(string)
    auth = object({
      type = string # workload_identity|service_principal|managed_identity
      workload_identity = optional(object({
        service_account_name      = string
        service_account_namespace = optional(string)
        client_id                 = optional(string)
      }))
      service_principal = optional(object({
        client_id     = string
        client_secret = string
        tenant_id     = string
      }))
      managed_identity = optional(object({
        client_id   = optional(string)
        resource_id = optional(string)
      }))
    })
  })
  external_secrets = list(object({
    name             = string
    refresh_interval = optional(string)
    remote_ref = object({
      name    = string
      version = optional(string)
    })
    target = object({
      secret_name = string
      secret_key  = string
    })
  }))
})
```

Walidacje:
- `strategy == "eso"` → `eso != null`, `manual == null`, `csi == null`
- `secret_store.kind` w `["SecretStore","ClusterSecretStore"]`
- `key_vault_url` XOR `key_vault_name`
- `auth.type` zgodny z ustawionym sub-objektem (dokładnie jeden wariant)
- unikalność `external_secrets[*].name`

Uwagi implementacyjne:
- snake_case w wejściach; mapowanie do camelCase wyłącznie w manifestach CRD.
- wartości wrażliwe (`client_secret`) zawsze `sensitive`.

---

## Proponowana implementacja (sub-taski)

### TASK-002-0: Wykorzystanie zaktualizowanego generatora (pre-work)

Generator został już zaktualizowany w **TASK-003** (standard repo, `module.json`/`.releaserc.js`, pin AzureRM `4.57.0`).

- [x] Użyć `scripts/create-new-module.sh` z nowymi template’ami do wygenerowania szkieletu modułu.
- [x] Nie wprowadzać dodatkowych zmian w generatorze w ramach TASK-002.
- [x] Dokumentacja generatora: `docs/_TASKS/TASK-003_Module_Scaffold_Fix.md` → sekcja **Specyfikacja CLI (flagi i skladnia)** oraz `docs/PROMPT_FOR_MODULE_CREATION.md` → sekcja **Use scaffolding script**.

### TASK-002-1: Skeleton modułu + README

- [x] Wygenerować szkielet modułu przez `scripts/create-new-module.sh` (templates repo), a następnie **tylko** dostosować/uzupełnić pliki do standardu (AKS jako wzorzec), m.in.:
  - `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
  - `README.md`, `CHANGELOG.md`, `VERSIONING.md`, `CONTRIBUTING.md`, `SECURITY.md`
  - `module.json`, `.releaserc.js`, `.terraform-docs.yml`, `generate-docs.sh`, `Makefile`
- [x] Opisać “Decision tree”: kiedy `manual` vs `csi` vs `eso`
- [x] Dodać ostrzeżenie o Terraform state dla `manual`

### TASK-002-2: Strategia `manual` (KV → TF → K8s Secret)

- [x] `data.azurerm_key_vault_secret` dla każdego sekretu (z opcjonalnym `version`)
- [x] `kubernetes_secret_v1` (lub `kubernetes_secret`) tworzący jeden Secret z mapą `data`
- [x] Walidacje: unikalność kluczy, wymagane pola, spójność `strategy`

### TASK-002-3: Strategia `csi` (SecretProviderClass)

- [x] `kubernetes_manifest` (lub provider `kubectl` jeśli jest standardem repo) tworzący `SecretProviderClass`
- [x] Opcjonalnie sync do `Secret` (secretObjects)
- [x] Walidacje: poprawne `objectType`, wymagane pola

### TASK-002-4: Strategia `eso` (SecretStore + ExternalSecret)

- [x] `kubernetes_manifest` dla `SecretStore`/`ClusterSecretStore`
- [x] `kubernetes_manifest` dla `ExternalSecret` (z mapowaniem keys)
- [x] Walidacje: wymagane auth/refs, poprawne kind

### TASK-002-5: Examples + testy

- [x] Dodać przykłady dla `manual`, `csi`, `eso`
- [x] Przykłady utrzymać w strukturze jak AKS module (`README.md`, `main.tf`, `variables.tf`, `outputs.tf` + preferowane `.terraform-docs.yml`)
- [x] Dodać fixtures odpowiadające przykładom (spójne nazewnictwo i zawartość)
- [x] Struktura testów identyczna jak w innych modułach (AKS jako wzorzec):
  - `tests/` z `Makefile`, `README.md`, `test_config.yaml`, `test_helpers.go`
  - `tests/unit/*.tftest.hcl` (walidacje wejść, strategii, nazw)
  - `tests/fixtures/*` odpowiadające przykładom
  - Go testy: `{module}_test.go`, `integration_test.go`, `performance_test.go`
- [x] Dodać `terraform test` (unit) + Terratest (integracja) zgodnie z `docs/TESTING_GUIDE/*`

---

## Kryteria akceptacji

- Moduł ma czytelne README z jednoznacznymi trade-offami.
- `strategy="manual"` umożliwia “pinowanie” wersji sekretu i kontrolowaną rotację (zmiana `version` + `apply`).
- `strategy="csi"` i `strategy="eso"` mają minimalny, działający zestaw zasobów konfiguracyjnych.
- Przykłady są spójne i przechodzą `terraform validate` (w granicach dostępnych providerów/środowiska).
