# TASK-020: AKS monitoring add-on (Container Insights) + AMPLS via AzAPI
# FileName: TASK-020_AKS_Monitoring_Addon_AMPLS_AzAPI.md

**Priority:** High  
**Category:** AKS Module / Monitoring  
**Estimated Effort:** Medium  
**Dependencies:** azurerm provider + azapi provider (new)  
**Status:** Planned

---

## Cel

Dodac wsparcie dla monitoringu Container Insights z Azure Monitor Private Link
Scope (AMPLS) w module `modules/azurerm_kubernetes_cluster`, zgodnie z MS docs,
ktore nadal wskazuja `az aks enable-addons --addon monitoring --ampls-resource-id`.

---

## Kontekst

- Microsoft docs dla Container Insights (AKS) pokazuja, ze przy Private Link
  wymagany jest `--ampls-resource-id` oraz konfiguracja AMPLS dla workspace.
- Microsoft docs wskazuja tez, ze `--data-collection-settings` jest miejscem
  ustawiania `enableContainerLogV2` oraz `streams` (nie Diagnostic Settings).
- `azurerm_kubernetes_cluster` udostepnia `oms_agent`, ale brak tam pola na AMPLS.
- W module mamy juz `oms_agent`, wiec potrzeba obejscia przez AzAPI.

---

## Zalozenia i decyzje

1) **Add-on = oms_agent**
   - Add-on "monitoring" dla AKS mapujemy na `oms_agent`.
   - Dodajemy opcjonalne `ampls_resource_id` w obiekcie `oms_agent`.

2) **AzAPI patch tylko gdy potrzebny**
   - Patch jest wlaczany tylko, gdy `var.oms_agent != null` oraz
     (`var.oms_agent.ampls_resource_id != null` lub
     `var.oms_agent.data_collection_settings != null`).

3) **Data collection settings dla streamow**
   - Dodajemy `oms_agent.data_collection_settings` i mapujemy na
     `dataCollectionSettings` w patchu (np. `enableContainerLogV2`, `streams`).
   - `streams` to jawny input (list(string)).

4) **Mapowanie wg docs (dataCollectionSettings.json)**
   - `interval` -> `dataCollectionSettings.interval`
   - `namespace_filtering_mode` -> `dataCollectionSettings.namespaceFilteringMode`
   - `namespaces` -> `dataCollectionSettings.namespaces`
   - `enable_container_log_v2` -> `dataCollectionSettings.enableContainerLogV2`
   - `streams` -> `dataCollectionSettings.streams`

   Minimalny przyklad z docs (dla odniesienia):
   ```
   {
     "interval": "1m",
     "namespaceFilteringMode": "Off",
     "enableContainerLogV2": true,
     "streams": ["Microsoft-Perf", "Microsoft-ContainerLogV2"]
   }
   ```
   - W patchu AKS addon config `dataCollectionSettings` powinno byc zapisane
     jako JSON string (mapa `addonProfiles.omsagent.config` to map[string]string).

5) **Dodatkowy, generyczny patch dla AKS**
   - Wprowadzamy dodatkowy obiekt `aks_azapi_patch` do celowego patchowania
     ManagedCluster (tylko ten resource, bez cross-resource glue).

6) **Security-first**
   - Patch jest jawny, opt-in, udokumentowany w README/SECURITY.

---

## Zakres i deliverables

### TASK-020-1: Discovery / potwierdzenie API

**Cel:** Potwierdzic faktyczne pole/polaczenie AMPLS i dataCollectionSettings w ManagedCluster.

**Do zrobienia:**
- Zweryfikowac nazwe pola w ARM/AKS API dla AMPLS (np. w addon config).
- Sprawdzic zgodnosc z MS docs:
  - `az aks enable-addons --addon monitoring --ampls-resource-id`
  - parametry `useAzureMonitorPrivateLinkScope` i
    `azureMonitorPrivateLinkScopeResourceId` w szablonach.
- Potwierdzic pola dla `--data-collection-settings`:
  - gdzie w API trafia `enableContainerLogV2`
  - gdzie w API trafia `streams` (np. `Microsoft-Perf`, `Microsoft-ContainerLogV2`)
- Potwierdzic docelowy `api_version` dla `Microsoft.ContainerService/managedClusters`.

---

### TASK-020-2: Rozszerzenie inputow `oms_agent`

**Cel:** Dodac opcjonalne inputy AMPLS + data collection settings do add-onu.

**Do zrobienia:**
- `variables.tf`: dodac:
  - `ampls_resource_id = optional(string)`
  - `data_collection_settings = optional(object({ ... }))`
    - `interval = optional(string)`
    - `namespace_filtering_mode = optional(string)`
    - `namespaces = optional(list(string))`
    - `enable_container_log_v2 = optional(bool)`
    - `streams = optional(list(string))`
- Walidacja:
  - `ampls_resource_id` tylko gdy `oms_agent != null`.
  - format Resource ID (prosta walidacja regex).
  - `streams` tylko gdy `data_collection_settings != null`.
  - `streams` niepuste i jako lista stringow.
- `README.md`: zaktualizowac opis `oms_agent`.
 - Przyklad minimalny (docs): interval + namespaceFilteringMode + enableContainerLogV2 + streams.

---

### TASK-020-3: AzAPI patch (AMPLS)

**Cel:** Zastosowac patch do AKS, gdy `ampls_resource_id` lub `data_collection_settings` sa ustawione.

**Do zrobienia:**
- `versions.tf`: dodac provider `azapi` (wersja zgodna z repo standardem).
- `main.tf`:
  - dodac `azapi_update_resource` dla `managedClusters`.
  - budowac `body` tylko gdy `ampls_resource_id` lub `data_collection_settings` ustawione.
  - `depends_on` na `azurerm_kubernetes_cluster.kubernetes_cluster`.
  - zastosowac `ignore_missing_property` jesli konieczne.
- Uwaga: patch musi byc idempotentny i nie resetowac innych pol.
 - Uwaga: `data_collection_settings` dotyczy streamow i `enableContainerLogV2`
   (nie jest to Diagnostic Settings).

---

### TASK-020-4: Generyczny patch AKS przez AzAPI

**Cel:** Dodac dodatkowy input pozwalajacy na kontrolowany patch AKS.

**Proponowany input (przyklad):**
```
variable "aks_azapi_patch" {
  type = object({
    enabled     = optional(bool, false)
    api_version = optional(string)
    body        = optional(map(any))
  })
  default = {
    enabled = false
  }
}
```

**Do zrobienia:**
- Walidacja: gdy `enabled = true`, wymagaj `api_version` i niepusty `body`.
- Patch aplikowany do `azurerm_kubernetes_cluster.kubernetes_cluster.id`.
- Polaczenie z AMPLS: finalny patch body = merge(AMPLS patch, aks_azapi_patch.body).
 - Polaczenie z dataCollectionSettings: finalny patch body = merge(AMPLS patch,
   dataCollectionSettings patch, aks_azapi_patch.body).

---

### TASK-020-5: Dokumentacja

**Cel:** Udokumentowac nowa sciezke i ryzyka.

**Do zrobienia:**
- `README.md`: opis `oms_agent.ampls_resource_id` + `aks_azapi_patch`.
- `SECURITY.md`: wzmianka o Private Link i wymaganiu AMPLS dla workspace.
- Podkreslic, ze patch jest opcjonalny i nie zastapi konfiguracji AMPLS.

---

### TASK-020-6: Examples + testy

**Cel:** Pokazac uzycie i zabezpieczyc walidacje.

**Do zrobienia:**
- Przynajmniej jeden example:
  - `examples/secure` lub nowy `examples/monitoring-ampls` z
    `oms_agent.ampls_resource_id` i `oms_agent.data_collection_settings`.
- Unit tests:
  - `ampls_resource_id` bez `oms_agent` -> fail.
  - `data_collection_settings` bez `oms_agent` -> fail.
  - `streams` puste -> fail.
  - `aks_azapi_patch.enabled=true` bez `api_version` lub `body` -> fail.
- Integration tests opcjonalne (wymaga realnego AMPLS).

---

## Acceptance Criteria

- Modul wspiera `oms_agent.ampls_resource_id` i stosuje AzAPI patch tylko wtedy,
  gdy jest podany.
- Modul wspiera `oms_agent.data_collection_settings` (streams + enableContainerLogV2).
- Dodany jest generyczny `aks_azapi_patch` z walidacjami i dokumentacja.
- README/SECURITY sa zaktualizowane.
- Unit tests pokrywaja nowe walidacje.

---

## Docs to Update After Completion

- `docs/_TASKS/README.md` (status)
