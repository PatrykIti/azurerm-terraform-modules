# TASK-002: AKS secrets – manual rotation (TF) + standard KV/CSI/ESO
# FileName: TASK-002_AKS_Secrets_Manual_Rotation_and_KV_Integration.md

**Priority:** 🔴 High  
**Category:** Terraform Module (AKS / Secrets)  
**Estimated Effort:** Large  
**Dependencies:** TASK-001 (AKS module stabilizacja)  
**Status:** ⏳ **To Do**

---

## Cel

Dodać spójne, “przyjazne dla ludzi” podejście do zarządzania sekretami dla workloadów na AKS, obejmujące dwa warianty:

1) **Standard (runtime)**: integracja z Azure Key Vault poprzez **CSI Secrets Store** i/lub **External Secrets Operator (ESO)** – bez przenoszenia wartości sekretów do state Terraforma.  
2) **Manual rotation (Terraform jako pośrednik)**: Terraform czyta sekrety z Key Vault i tworzy/aktualizuje **Kubernetes Secret** – z możliwością “pinowania” wersji i ręcznego sterowania rotacją.

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
  - `examples/complete/` (manual: multi-secrets + pinowanie wersji)
  - `examples/csi/` (CSI: SecretProviderClass, opcjonalnie sync do K8s Secret)
  - `examples/eso/` (ESO: SecretStore + ExternalSecret)
  - `examples/secure/` (preferowany wariant runtime: CSI/ESO bez sekretów w state, z minimalnymi uprawnieniami)

### 3) Bezpieczeństwo i operacje (ważne!)

Moduł musi w README jasno rozróżniać:

- **Manual (TF)**: wartości sekretów będą w **Terraform state** (wymaga bezpiecznego backendu, twardego RBAC, braku logowania planów z “sensitive” wartościami, itp.).  
- **CSI/ESO**: wartości sekretów nie trafiają do state, ale runtime może mieć opóźnienia/“eventual consistency”.

---

## Bloki Terraforma (co będzie użyte)

### Wspólne (dla modułu)

- `terraform { required_version, required_providers }`
  - `hashicorp/azurerm` – odczyt z Key Vault
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

### Dlaczego takie podejście

- **Czytelniejsze dla użytkowników modułu:** dla wielu osób (zwłaszcza uczących się TF) lista obiektów jest bardziej intuicyjna niż zagnieżdżone mapy.
- **Spójny schemat pracy:** użytkownik dodaje kolejny element jako “kolejny obiekt” (kopiuj/wklej), a moduł sam mapuje to do stabilnego klucza.
- **Lepsza ergonomia w PR-ach:** diffs w listach są często bardziej zrozumiałe (widać dodany/usunięty obiekt), a kluczem w module jest jawne `name`.
- **Stabilne `for_each`:** mapowanie po `name` zapewnia deterministyczne klucze zasobów i mniejsze ryzyko “recreate” przy przestawianiu kolejności listy.

Wymóg: `name` musi być unikalne w obrębie listy → moduł powinien mieć walidację unikalności.

### `strategy = "manual"` (KV → TF → K8s Secret)

- `key_vault_id` (string)
- `secrets` (map(object)):
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
  - `objectName` (string)
  - `objectType` (string) – `secret`/`key`/`cert`
  - `objectVersion` (optional(string)) – pozwala “pinować” wersję w CSI (manualny switch)
- `sync_to_kubernetes_secret` (bool, default `false`)
- jeśli `sync_to_kubernetes_secret = true`:
  - `kubernetes_secret_name` + mapowanie keys → secretObjects

### `strategy = "eso"` (KV → ESO)

- `secret_store` (object):
  - `kind` (`SecretStore` / `ClusterSecretStore`)
  - `name`
  - `tenant_id`
  - `key_vault_url` / `key_vault_name`
  - `auth` (pod identity / workload identity / service principal) – zależnie od standardu repo
- `external_secrets` (list(object)):
  - `remoteRef` (name + optional version)
  - `target` (k8s secret name + key)
  - `refreshInterval` (optional)

---

## Proponowana implementacja (sub-taski)

### TASK-002-0: Aktualizacja generatora szkieletów modułów (pre-work)

W repo jest generator: `scripts/create-new-module.sh` + templates w `scripts/templates/`.

Cel: dopiąć spójność wersji i uprościć tworzenie modułów “kubernetesowych”.

- [ ] Ujednolicić wersje w `scripts/templates/module-config.yml` do standardu repo (Terraform `>= 1.12.2`, AzureRM `>= 4.57.0`/pinned)
- [ ] Ujednolicić provider pin w `scripts/templates/versions.tf` (AzureRM `4.57.0`)
- [ ] (Opcjonalnie) dodać w `scripts/create-new-module.sh` tryb/flagę dla modułów “kubernetesowych”, aby nie generował `private-endpoint` i pozwalał zadeklarować własne przykłady (np. `manual`, `csi`, `eso`)

### TASK-002-1: Skeleton modułu + README

- [ ] Utworzyć `modules/azurerm_kubernetes_secrets/` z plikami: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`, `VERSIONING.md`, `CHANGELOG.md`
- [ ] Opisać “Decision tree”: kiedy `manual` vs `csi` vs `eso`
- [ ] Dodać ostrzeżenie o Terraform state dla `manual`

### TASK-002-2: Strategia `manual` (KV → TF → K8s Secret)

- [ ] `data.azurerm_key_vault_secret` dla każdego sekretu (z opcjonalnym `version`)
- [ ] `kubernetes_secret_v1` (lub `kubernetes_secret`) tworzący jeden Secret z mapą `data`
- [ ] Walidacje: unikalność kluczy, wymagane pola, spójność `strategy`

### TASK-002-3: Strategia `csi` (SecretProviderClass)

- [ ] `kubernetes_manifest` (lub provider `kubectl` jeśli jest standardem repo) tworzący `SecretProviderClass`
- [ ] Opcjonalnie sync do `Secret` (secretObjects)
- [ ] Walidacje: poprawne `objectType`, wymagane pola

### TASK-002-4: Strategia `eso` (SecretStore + ExternalSecret)

- [ ] `kubernetes_manifest` dla `SecretStore`/`ClusterSecretStore`
- [ ] `kubernetes_manifest` dla `ExternalSecret` (z mapowaniem keys)
- [ ] Walidacje: wymagane auth/refs, poprawne kind

### TASK-002-5: Examples + testy

- [ ] Dodać przykłady dla `manual`, `csi`, `eso`
- [ ] Przykłady utrzymać w strukturze jak AKS module (`README.md`, `main.tf`, `variables.tf`, `outputs.tf` + preferowane `.terraform-docs.yml`)
- [ ] Dodać fixtures odpowiadające przykładom (spójne nazewnictwo i zawartość)
- [ ] Dodać `terraform test` (unit) dla walidacji i “planu” (mock/provider-free tam gdzie możliwe)

---

## Kryteria akceptacji

- Moduł ma czytelne README z jednoznacznymi trade-offami.
- `strategy="manual"` umożliwia “pinowanie” wersji sekretu i kontrolowaną rotację (zmiana `version` + `apply`).
- `strategy="csi"` i `strategy="eso"` mają minimalny, działający zestaw zasobów konfiguracyjnych.
- Przykłady są spójne i przechodzą `terraform validate` (w granicach dostępnych providerów/środowiska).
