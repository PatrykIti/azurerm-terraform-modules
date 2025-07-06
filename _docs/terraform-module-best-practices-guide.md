# Terraform Module Development Best Practices Guide

Ten przewodnik został stworzony na podstawie analizy modułów Terraform w repozytoriach CDS i przedstawia najlepsze praktyki tworzenia profesjonalnych, skalowalnych modułów Terraform dla środowiska Azure.

## Spis treści

1. [Struktura modułu](#struktura-modułu)
2. [Definiowanie zmiennych](#definiowanie-zmiennych)
3. [Implementacja zasobów](#implementacja-zasobów)
4. [Outputs](#outputs)
5. [Wersjonowanie i zależności](#wersjonowanie-i-zależności)
6. [Dokumentacja](#dokumentacja)
7. [Przykłady użycia](#przykłady-użycia)
8. [Testowanie](#testowanie)
9. [CI/CD](#cicd)
10. [Wzorce zaawansowane](#wzorce-zaawansowane)
11. [Najczęstsze błędy do uniknięcia](#najczęstsze-błędy-do-uniknięcia)

## 1. Struktura modułu

### Standardowa struktura katalogów

```
terraform-azurerm-<resource-name>/
├── .azuredevops/                 # Pipeline'y CI/CD
│   ├── semanticversion.yml       # Automatyczne wersjonowanie
│   ├── sonarqube.yml            # Analiza jakości kodu
│   └── terraformdocs.yml        # Generowanie dokumentacji
├── examples/                     # Przykłady użycia
│   ├── simple/                  # Podstawowy przykład
│   │   └── main.tf
│   └── complete/                # Zaawansowany przykład
│       └── main.tf
├── modules/                     # Sub-moduły (opcjonalne)
│   └── <submodule>/
├── tests/                       # Testy automatyczne (Terratest)
├── CHANGELOG.md                 # Historia zmian (semantic versioning)
├── CONTRIBUTING.md              # Zasady kontrybuowania
├── README.md                    # Dokumentacja modułu
├── main.tf                      # Główna implementacja
├── variables.tf                 # Definicje zmiennych wejściowych
├── outputs.tf                   # Definicje outputów
└── versions.tf                  # Wymagania wersji
```

### Najlepsze praktyki:
- Używaj płaskiej struktury dla prostych modułów
- Twórz sub-moduły tylko gdy logika jest złożona
- Zawsze dodawaj katalog `examples/` z przykładami
- Nazwa pliku z outputami to `outputs.tf` (nie `output.tf`)

## 2. Definiowanie zmiennych

### 2.1 Podstawowe zasady

```hcl
variable "name" {
  description = "Nazwa zasobu - musi być unikalna w ramach subskrypcji"
  type        = string
  
  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 24
    error_message = "Długość nazwy musi być między 3 a 24 znaki."
  }
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+$", var.name))
    error_message = "Nazwa musi zaczynać się od litery i zawierać tylko małe litery, cyfry i myślniki."
  }
}
```

### 2.2 Złożone typy z opcjonalnymi polami

```hcl
variable "configuration" {
  description = <<-EOT
    Konfiguracja zasobu:
      • enabled - Czy zasób ma być włączony
      • size - Rozmiar zasobu (small, medium, large)
      • advanced_settings - Zaawansowane ustawienia
        └─ retention_days - Liczba dni retencji (1-365)
        └─ backup_enabled - Czy włączyć kopie zapasowe
    
    Pomiń cały atrybut lub ustaw wartość na null aby pominąć konfigurację.
  EOT
  
  type = object({
    enabled = optional(bool, true)
    size    = optional(string, "medium")
    advanced_settings = optional(object({
      retention_days = optional(number, 30)
      backup_enabled = optional(bool, true)
    }), {})
  })
  
  default = {}
  
  validation {
    condition = var.configuration.size == null ? true : contains(["small", "medium", "large"], var.configuration.size)
    error_message = "Size musi być: 'small', 'medium' lub 'large'."
  }
}
```

### 2.3 Walidacja list obiektów

```hcl
variable "network_rules" {
  description = "Lista reguł sieciowych"
  type = list(object({
    name        = string
    priority    = number
    direction   = string
    action      = string
    source_ip   = optional(string)
    destination_ip = optional(string)
  }))
  
  default = []
  
  validation {
    condition = alltrue([
      for rule in var.network_rules : 
        rule.priority >= 100 && rule.priority <= 4096
    ])
    error_message = "Priorytet musi być między 100 a 4096."
  }
  
  validation {
    condition = alltrue([
      for rule in var.network_rules : 
        contains(["Inbound", "Outbound"], rule.direction)
    ])
    error_message = "Direction musi być 'Inbound' lub 'Outbound'."
  }
}
```

### 2.4 Walidacja adresów IP i CIDR

```hcl
variable "ip_rules" {
  description = "Lista adresów IP lub zakresów CIDR"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for ip in var.ip_rules : 
        can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip)) || 
        can(cidrhost(ip, 0))
    ])
    error_message = "Każdy wpis musi być prawidłowym adresem IP (np. 192.168.1.1) lub CIDR (np. 192.168.0.0/24)."
  }
}
```

### Najlepsze praktyki dla zmiennych:
- **Zawsze** dodawaj opisy używając heredoc dla złożonych zmiennych
- Używaj `optional()` z wartościami domyślnymi dla opcjonalnych pól
- Implementuj kompleksową walidację z pomocnymi komunikatami błędów
- Grupuj powiązane konfiguracje w obiekty
- Ustaw bezpieczne wartości domyślne (np. `https_only = true`, `minimum_tls_version = "1.2"`)
- Używaj `sensitive = true` dla wrażliwych danych

## 3. Implementacja zasobów

### 3.1 Warunkowe tworzenie zasobów

```hcl
# Przykład dla różnych typów OS
resource "azurerm_windows_web_app" "main" {
  count = var.os_type == "Windows" ? 1 : 0
  
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  
  # Konfiguracja...
}

resource "azurerm_linux_web_app" "main" {
  count = var.os_type == "Linux" ? 1 : 0
  
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  
  # Konfiguracja...
}
```

### 3.2 Dynamiczne bloki

```hcl
resource "azurerm_storage_account" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [1] : []
    
    content {
      default_action             = "Deny"
      ip_rules                   = var.network_rules.ip_rules
      virtual_network_subnet_ids = var.network_rules.subnet_ids
      bypass                     = ["AzureServices"]
    }
  }
  
  dynamic "blob_properties" {
    for_each = var.blob_properties != null ? [1] : []
    
    content {
      versioning_enabled = try(var.blob_properties.versioning_enabled, false)
      
      dynamic "delete_retention_policy" {
        for_each = var.blob_properties.delete_retention_days != null ? [1] : []
        
        content {
          days = var.blob_properties.delete_retention_days
        }
      }
    }
  }
}
```

### 3.3 For-each z transformacją obiektów

```hcl
resource "azurerm_subnet" "main" {
  for_each = { 
    for subnet in var.subnets : subnet.name => subnet 
    if var.subnets != [] 
  }
  
  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = each.value.address_prefixes
  
  dynamic "delegation" {
    for_each = each.value.delegations
    
    content {
      name = delegation.value.name
      
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}
```

### 3.4 Lifecycle Management

```hcl
resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location
  tags     = var.tags
  
  lifecycle {
    # Ignoruj zmiany w automatycznie zarządzanych tagach
    ignore_changes = [
      tags["AlfabetAppID"],
      tags["BillingIdentifier"],
      tags["PassportRef"],
      tags["latestBackup"]
    ]
    
    # Zapobiegaj przypadkowemu usunięciu
    prevent_destroy = var.enable_delete_protection
  }
}
```

### 3.5 Bezpieczne zarządzanie hasłami

```hcl
# Generowanie hasła
resource "random_password" "admin" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
  
  lifecycle {
    ignore_changes = all  # Zapobiega regeneracji hasła
  }
}

# Przechowywanie w Key Vault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${var.name}-admin-password"
  value        = random_password.admin.result
  key_vault_id = var.key_vault_id
  
  lifecycle {
    ignore_changes = [value]
  }
}
```

### Najlepsze praktyki dla zasobów:
- Używaj `count` dla warunkowego tworzenia zasobów
- Stosuj `dynamic` bloki dla opcjonalnych konfiguracji
- Implementuj `lifecycle` rules dla stabilności
- Zawsze oznaczaj wrażliwe dane jako `sensitive`
- Używaj `for_each` zamiast `count` dla wielu instancji

## 4. Outputs

### 4.1 Podstawowe outputs

```hcl
output "id" {
  description = "ID zasobu"
  value       = azurerm_resource_group.main.id
}

output "name" {
  description = "Nazwa zasobu"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Lokalizacja zasobu"
  value       = azurerm_resource_group.main.location
}
```

### 4.2 Warunkowe outputs

```hcl
output "principal_id" {
  description = "Principal ID przypisanej tożsamości zarządzanej"
  value       = var.identity_type != "None" ? azurerm_app_service.main.identity[0].principal_id : null
}

output "windows_app_id" {
  description = "ID aplikacji Windows"
  value       = var.os_type == "Windows" ? azurerm_windows_web_app.main[0].id : null
}

output "linux_app_id" {
  description = "ID aplikacji Linux"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.main[0].id : null
}
```

### 4.3 Złożone outputs

```hcl
output "subnet_ids" {
  description = "Mapa nazw subnetów do ich ID"
  value = {
    for k, v in azurerm_subnet.main : k => v.id
  }
}

output "connection_strings" {
  description = "Connection strings dla różnych serwisów"
  value = {
    primary_sql_connection   = local.primary_sql_connection_string
    primary_blob_connection  = local.primary_blob_connection_string
    primary_table_connection = local.primary_table_connection_string
  }
  sensitive = true
}
```

### Najlepsze praktyki dla outputs:
- Zawsze dodawaj opisy
- Oznaczaj wrażliwe dane jako `sensitive = true`
- Używaj warunkowych outputs dla opcjonalnych zasobów
- Eksportuj wszystkie istotne atrybuty potrzebne przez konsumentów
- Zachowuj spójne nazewnictwo z zmiennymi wejściowymi

## 5. Wersjonowanie i zależności

### 5.1 Plik versions.tf

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75.0"
    }
    
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5.0"
    }
    
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}
```

### 5.2 Semantic Versioning

Używaj semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Zmiany niekompatybilne wstecznie
- **MINOR**: Nowe funkcjonalności kompatybilne wstecznie
- **PATCH**: Poprawki błędów

### 5.3 Conventional Commits

```bash
feat: Dodano wsparcie dla private endpoints
fix: Poprawiono walidację adresów IP
docs: Zaktualizowano przykłady użycia
refactor: Uproszczono logikę dynamic blocks
chore: Zaktualizowano wersję provider azurerm

BREAKING CHANGE: Zmieniono nazwę zmiennej 'enable_logs' na 'enable_diagnostic_settings'
```

## 6. Dokumentacja

### 6.1 README.md struktura

```markdown
# terraform-azurerm-<resource-name>

## Opis
Krótki opis modułu i jego przeznaczenia.

## Funkcjonalności
- Funkcjonalność 1
- Funkcjonalność 2
- Funkcjonalność 3

## Użycie

\```hcl
module "example" {
  source = "git::https://dev.azure.com/org/project/_git/terraform-azurerm-resource?ref=v1.0.0"
  
  name                = "my-resource"
  resource_group_name = "my-rg"
  location            = "North Europe"
  
  tags = {
    Environment = "Production"
    Owner       = "team@company.com"
  }
}
\```

## Przykłady
- [Prosty przykład](examples/simple)
- [Zaawansowany przykład](examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- Automatycznie generowana dokumentacja -->
<!-- END_TF_DOCS -->

## Wymagania
- Terraform >= 1.5.0
- Azure Provider >= 3.75.0

## Licencja
MIT
```

### 6.2 Terraform-docs konfiguracja

```yaml
# .terraform-docs.yml
formatter: "markdown table"

version: ""

header-from: main.tf
footer-from: ""

recursive:
  enabled: false

sections:
  hide:
    - modules
  show:
    - header
    - inputs
    - outputs
    - providers
    - requirements
    - resources

content: |-
  {{ .Header }}
  
  ## Zasoby
  
  {{ .Resources }}
  
  ## Wymagania
  
  {{ .Requirements }}
  
  ## Providers
  
  {{ .Providers }}
  
  ## Inputs
  
  {{ .Inputs }}
  
  ## Outputs
  
  {{ .Outputs }}

output:
  file: README.md
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: true
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

## 7. Przykłady użycia

### 7.1 Struktura przykładów

```
examples/
├── simple/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── complete/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars.example
    └── README.md
```

### 7.2 Prosty przykład

```hcl
# examples/simple/main.tf
provider "azurerm" {
  features {}
}

module "storage" {
  source = "../../"
  
  name                = "stg${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  tags = {
    Environment = "Development"
    Example     = "Simple"
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "example" {
  name     = "rg-example-simple"
  location = "North Europe"
}
```

### 7.3 Zaawansowany przykład

```hcl
# examples/complete/main.tf
module "storage" {
  source = "../../"
  
  name                = "stg${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  account_tier        = "Premium"
  account_kind        = "BlockBlobStorage"
  
  # Konfiguracja sieci
  network_rules = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
    subnet_ids     = [azurerm_subnet.example.id]
  }
  
  # Właściwości blob
  blob_properties = {
    versioning_enabled = true
    delete_retention_days = 30
    container_delete_retention_days = 7
  }
  
  # Tożsamość zarządzana
  identity = {
    type = "SystemAssigned"
  }
  
  # Kontenery
  containers = [
    {
      name                  = "data"
      container_access_type = "private"
    },
    {
      name                  = "logs"
      container_access_type = "private"
    }
  ]
  
  # Diagnostic settings
  diagnostic_settings = [
    {
      name                       = "security-logs"
      log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
      metrics = ["AllMetrics"]
      logs    = ["StorageRead", "StorageWrite", "StorageDelete"]
    }
  ]
  
  tags = {
    Environment = "Production"
    Example     = "Complete"
  }
}
```

## 8. Testowanie

### 8.1 Struktura testów

```
tests/
├── unit/
│   ├── variables_test.go
│   └── validation_test.go
├── integration/
│   ├── simple_test.go
│   └── complete_test.go
└── fixtures/
    ├── simple/
    └── complete/
```

### 8.2 Przykład testu Terratest

```go
// tests/integration/simple_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestSimpleExample(t *testing.T) {
    t.Parallel()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "../../examples/simple",
        Vars: map[string]interface{}{
            "location": "North Europe",
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    
    terraform.InitAndApply(t, terraformOptions)
    
    // Weryfikacja outputs
    resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
    assert.NotEmpty(t, resourceGroupName)
    
    storageAccountName := terraform.Output(t, terraformOptions, "storage_account_name")
    assert.NotEmpty(t, storageAccountName)
}
```

### 8.3 Testy walidacji

```hcl
# tests/fixtures/validation/invalid_name.tf
module "test" {
  source = "../../../"
  
  name                = "INVALID-NAME"  # Wielkie litery niedozwolone
  resource_group_name = "test-rg"
  location            = "North Europe"
  
  tags = {}
}
```

## 9. CI/CD

### 9.1 Azure DevOps Pipeline

```yaml
# .azuredevops/terraform-module-pipeline.yml
trigger:
  branches:
    include:
      - main
      - develop
  paths:
    exclude:
      - README.md
      - CHANGELOG.md

stages:
  - stage: Validate
    jobs:
      - job: TerraformValidate
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: TerraformInstaller@0
            inputs:
              terraformVersion: '1.5.0'
          
          - script: |
              terraform init -backend=false
              terraform validate
            displayName: 'Terraform Validate'
          
          - script: |
              terraform fmt -check -recursive
            displayName: 'Terraform Format Check'
  
  - stage: Test
    jobs:
      - job: Terratest
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - task: GoTool@0
            inputs:
              version: '1.19'
          
          - script: |
              cd tests
              go mod init test
              go mod tidy
              go test -v -timeout 30m ./...
            displayName: 'Run Terratest'
  
  - stage: Documentation
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - job: GenerateDocs
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: |
              curl -sSLo terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v0.16.0/terraform-docs-v0.16.0-linux-amd64.tar.gz
              tar -xzf terraform-docs.tar.gz
              chmod +x terraform-docs
              ./terraform-docs markdown . > README.md
            displayName: 'Generate Documentation'
  
  - stage: Release
    condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
    jobs:
      - job: SemanticRelease
        pool:
          vmImage: 'ubuntu-latest'
        steps:
          - script: |
              npm install -g semantic-release @semantic-release/git @semantic-release/changelog
              semantic-release
            displayName: 'Semantic Release'
```

### 9.2 GitHub Actions

```yaml
# .github/workflows/terraform.yml
name: Terraform Module CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        run: terraform init -backend=false
      
      - name: Terraform Format
        run: terraform fmt -check -recursive
      
      - name: Terraform Validate
        run: terraform validate
  
  test:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: actions/setup-go@v4
        with:
          go-version: '1.19'
      
      - name: Run Tests
        run: |
          cd tests
          go mod init test
          go mod tidy
          go test -v -timeout 30m ./...
  
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
```

## 10. Wzorce zaawansowane

### 10.1 Moduł kompozycyjny

```hcl
# Moduł łączący wiele zasobów
module "complete_infrastructure" {
  source = "./modules/complete"
  
  # Sieć
  vnet_address_space = ["10.0.0.0/16"]
  subnets = [
    {
      name             = "web"
      address_prefixes = ["10.0.1.0/24"]
    },
    {
      name             = "app"
      address_prefixes = ["10.0.2.0/24"]
    },
    {
      name             = "db"
      address_prefixes = ["10.0.3.0/24"]
    }
  ]
  
  # Compute
  vm_configs = [
    {
      name    = "web-vm"
      size    = "Standard_B2s"
      os_type = "Linux"
      subnet  = "web"
    }
  ]
  
  # Storage
  storage_accounts = [
    {
      name = "appdata"
      tier = "Standard"
    }
  ]
}
```

### 10.2 Wzorzec Factory

```hcl
# Tworzenie wielu podobnych zasobów z różnymi konfiguracjami
locals {
  environments = {
    dev = {
      size     = "Standard_B2s"
      replicas = 1
      tier     = "Basic"
    }
    staging = {
      size     = "Standard_D2s_v3"
      replicas = 2
      tier     = "Standard"
    }
    prod = {
      size     = "Standard_D4s_v3"
      replicas = 3
      tier     = "Premium"
    }
  }
}

module "app_service" {
  for_each = local.environments
  source   = "./modules/app-service"
  
  name                = "${var.app_name}-${each.key}"
  resource_group_name = azurerm_resource_group.main[each.key].name
  location            = var.location
  service_plan_size   = each.value.size
  instance_count      = each.value.replicas
  tier                = each.value.tier
  
  tags = merge(var.common_tags, {
    Environment = each.key
  })
}
```

### 10.3 Moduł z politykami

```hcl
# Automatyczne stosowanie polityk organizacyjnych
module "secure_storage" {
  source = "./modules/storage"
  
  name                = var.storage_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Wymuszanie polityk bezpieczeństwa
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  public_network_access_enabled   = false
  infrastructure_encryption_enabled = true
  
  network_rules = {
    default_action = "Deny"
    ip_rules       = var.allowed_ips
    bypass         = ["AzureServices"]
  }
  
  # Automatyczne włączanie diagnostyki
  diagnostic_settings = [
    {
      name                       = "security-logs"
      log_analytics_workspace_id = data.azurerm_log_analytics_workspace.central.id
      metrics = ["AllMetrics"]
      logs    = ["StorageRead", "StorageWrite", "StorageDelete"]
    }
  ]
}
```

## 11. Najczęstsze błędy do uniknięcia

### ❌ Źle:
```hcl
# Brak walidacji
variable "location" {
  type = string
}

# Brak opisu
variable "name" {
  type = string
}

# Hasło w plain text
variable "admin_password" {
  type    = string
  default = "P@ssw0rd123!"
}

# Brak lifecycle rules
resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
```

### ✅ Dobrze:
```hcl
# Walidacja z pomocnym komunikatem
variable "location" {
  description = "Lokalizacja zasobów Azure"
  type        = string
  
  validation {
    condition     = contains(["North Europe", "West Europe"], var.location)
    error_message = "Dozwolone lokalizacje: North Europe, West Europe."
  }
}

# Pełny opis
variable "name" {
  description = "Nazwa zasobu - musi być unikalna w ramach subskrypcji"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,23}$", var.name))
    error_message = "Nazwa musi zaczynać się od litery, zawierać tylko małe litery, cyfry i myślniki, długość 3-24 znaki."
  }
}

# Bezpieczne zarządzanie hasłem
resource "random_password" "admin" {
  length  = 16
  special = true
}

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "${var.name}-admin-password"
  value        = random_password.admin.result
  key_vault_id = var.key_vault_id
}

# Lifecycle rules
resource "azurerm_resource_group" "main" {
  name     = var.name
  location = var.location
  tags     = var.tags
  
  lifecycle {
    ignore_changes = [tags["AutomatedTag"]]
  }
}
```

## Podsumowanie

Ten przewodnik przedstawia najlepsze praktyki zebrane z analizy rzeczywistych modułów Terraform używanych w środowisku produkcyjnym. Kluczowe zasady to:

1. **Prostota i fokus** - Każdy moduł powinien robić jedną rzecz dobrze
2. **Bezpieczeństwo** - Zawsze stosuj bezpieczne wartości domyślne
3. **Elastyczność** - Używaj optional() i dynamic blocks
4. **Walidacja** - Implementuj kompleksową walidację z pomocnymi błędami
5. **Dokumentacja** - Automatyzuj generowanie dokumentacji
6. **Testowanie** - Zawsze testuj moduły przed wydaniem
7. **Wersjonowanie** - Stosuj semantic versioning

Pamiętaj, że najlepsze moduły to te, które są łatwe w użyciu, bezpieczne domyślnie i elastyczne gdy potrzeba.