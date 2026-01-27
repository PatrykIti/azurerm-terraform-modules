# TASK-022: PostgreSQL Flexible Server missing provider arguments
# FileName: TASK-022_PostgreSQL_Flexible_Server_Missing_Arguments.md

**Priority:** Medium  
**Category:** Module Alignment / Provider Coverage  
**Estimated Effort:** Medium  
**Dependencies:** TASK-016  
**Status:** Done

---

## Cel

Uzupelnic modul `azurerm_postgresql_flexible_server` o brakujace argumenty
resource'a `azurerm_postgresql_flexible_server` wskazane w dokumentacji
providera:

- `administrator_password_wo`
- `administrator_password_wo_version`
- `auto_grow_enabled`
- `replication_role`

---

## Analiza stanu obecnego

1) Modul mapuje tylko `administrator_password` i nie wspiera write-only password
   oraz wersjonowania dla wymuszenia rotacji.
2) `server.storage` nie zawiera `auto_grow_enabled`.
3) `replication_role` nie jest wystawione jako input.

---

## Zalozenia i decyzje

1) **Write-only admin password**  
   Dodac pola do `authentication.administrator` (np. `password_wo`,
   `password_wo_version`) i mapowac na top-level `administrator_password_wo`
   i `administrator_password_wo_version`.

2) **Walidacje login/haslo**  
   Dla `create_mode = Default` i `password_auth_enabled = true` wymagac loginu
   oraz jednego z: `password` lub `password_wo`.

3) **Auto-grow**  
   `auto_grow_enabled` jako opcjonalny bool w `server.storage`.

4) **Replication role**  
   `replication_role` jako opcjonalny string w `server` z walidacja dozwolonych
   wartosci (aktualnie `None`).

---

## Zakres i deliverables

### TASK-022-1: Inputs i walidacje
- [ ] Dodac `authentication.administrator.password_wo` i
      `authentication.administrator.password_wo_version`.
- [ ] Zaktualizowac walidacje admin hasla (akceptowac `password` lub `password_wo`).
- [ ] Dodac `server.storage.auto_grow_enabled` + walidacje typu.
- [ ] Dodac `server.replication_role` + walidacje dozwolonych wartosci.

### TASK-022-2: Implementacja w `main.tf`
- [ ] Zmapowac `administrator_password_wo` i `administrator_password_wo_version`.
- [ ] Zmapowac `auto_grow_enabled` w resource.
- [ ] Zmapowac `replication_role` w resource.

### TASK-022-3: Dokumentacja
- [ ] Zaktualizowac opisy inputow w `variables.tf` (terraform-docs -> README).
- [ ] Zaktualizowac `docs/README.md` oraz `SECURITY.md` jesli potrzeba.

### TASK-022-4: Testy
- [ ] Unit testy dla walidacji hasel (`password` vs `password_wo`).
- [ ] Unit testy dla `auto_grow_enabled` i `replication_role` (wartosci dozwolone).
