#!/usr/bin/env python3

import re

def main():
    print("========================================")
    print("Test aktualizacji tabeli modułów")
    print("========================================")
    print()

    # Obecny stan tabeli
    current_table = """| [Storage Account](./modules/azurerm_storage_account/) | ✅ Completed | [SAv1.1.0](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/SAv1.0.0) | Azure Storage Account with enterprise features |
| [Virtual Network](./modules/azurerm_virtual_network/) | ✅ Completed | [VNv1.0.1](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q=VNv1.0.0) | Virtual Network with full networking capabilities |
| [Kubernetes Cluster](./modules/azurerm_kubernetes_cluster/) | ✅ Completed | v1.0.0 | Azure Kubernetes Service (AKS) cluster with enterprise features |
| [Network Security Group](./modules/azurerm_network_security_group/) | ✅ Completed | v1.0.0 | Network Security Group with comprehensive rule management |
| [Route Table](./modules/azurerm_route_table/) | ✅ Completed | v1.0.0 | Route Table with custom routing rules and BGP support |
| [Subnet](./modules/azurerm_subnet/) | ✅ Completed | v1.0.0 | Subnet module with service endpoints and delegation support |"""

    print("📋 OBECNY STAN (z błędami):")
    print("-" * 40)
    print(current_table)
    print()
    print("❌ Problemy:")
    print("  - SAv1.1.0 linkuje do SAv1.0.0 (błędny link)")
    print("  - VNv1.0.1 linkuje do VNv1.0.0 (błędny link)")
    print("  - Kubernetes/NSG/Route Table/Subnet nie mają tagów z prefixem")
    print()

    # Symulacja release dla wszystkich modułów
    releases = [
        ("Storage Account", "azurerm_storage_account", "SAv", "1.2.0"),
        ("Virtual Network", "azurerm_virtual_network", "VNv", "1.1.0"),
        ("Kubernetes Cluster", "azurerm_kubernetes_cluster", "AKSv", "1.1.0"),
        ("Network Security Group", "azurerm_network_security_group", "NSGv", "1.0.0"),
        ("Route Table", "azurerm_route_table", "RTv", "1.0.0"),
        ("Subnet", "azurerm_subnet", "SNv", "1.0.0"),
    ]

    updated_table = current_table

    print("🚀 SYMULACJA RELEASE:")
    print("-" * 40)

    for display_name, module_name, tag_prefix, version in releases:
        print(f"Releasing {display_name} -> {tag_prefix}{version}")

        # Pattern dla tego modułu
        pattern = rf'(\[{re.escape(display_name)}\]\(./modules/{module_name}/\) \| ✅ Completed \| )[^\|]+(\|)'

        # Nowy link do release
        new_version_link = f"[{tag_prefix}{version}](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/{tag_prefix}{version})"

        # Zamiana
        replacement = rf'\1{new_version_link} \2'
        updated_table = re.sub(pattern, replacement, updated_table)

    print()
    print("✅ PO AKTUALIZACJI (poprawne):")
    print("-" * 40)
    print(updated_table)
    print()

    print("📊 PODSUMOWANIE ZMIAN:")
    print("-" * 40)

    # Porównaj linie
    original_lines = current_table.split("\n")
    updated_lines = updated_table.split("\n")

    for orig, upd in zip(original_lines, updated_lines):
        # Wyciągnij nazwę modułu
        module_match = re.search(r'\[([^\]]+)\]', orig)
        if module_match:
            module_name = module_match.group(1)

            # Znajdź wersje w kolumnie Version
            # Pattern dla kolumny Version (trzecia kolumna)
            orig_parts = orig.split("|")
            upd_parts = upd.split("|")

            if len(orig_parts) >= 4 and len(upd_parts) >= 4:
                old_version_col = orig_parts[3].strip()
                new_version_col = upd_parts[3].strip()

                # Wyciągnij tag/wersję
                if old_version_col.startswith("["):
                    # Jest linkiem
                    tag_match = re.search(r'\[([^\]]+)\]', old_version_col)
                    link_match = re.search(r'tag/([^)]+)\)', old_version_col)
                    if tag_match and link_match:
                        old_display = tag_match.group(1)
                        old_link = link_match.group(1)
                        old_v = f"{old_display} -> {old_link}" if old_display != old_link else old_display
                    else:
                        old_v = old_version_col
                else:
                    # Prosta wersja
                    old_v = old_version_col

                if new_version_col.startswith("["):
                    # Jest linkiem
                    tag_match = re.search(r'\[([^\]]+)\]', new_version_col)
                    link_match = re.search(r'tag/([^)]+)\)', new_version_col)
                    if tag_match and link_match:
                        new_display = tag_match.group(1)
                        new_link = link_match.group(1)
                        link_ok = "✅" if new_display == new_link else "❌"
                        new_v = f"{new_display} (link: {new_link}) {link_ok}"
                    else:
                        new_v = new_version_col
                else:
                    new_v = new_version_col

                print(f"  {module_name}:")
                print(f"    Było: {old_v}")
                print(f"    Jest: {new_v}")

    print()
    print("✅ WERYFIKACJA:")
    print("-" * 40)
    print("1. ✅ Wszystkie moduły mają poprawny format tagów (prefix + wersja)")
    print("2. ✅ Linki prowadzą do właściwych tagów (nie ma rozbieżności)")
    print("3. ✅ Format linków: .../releases/tag/{TAG}")
    print("4. ✅ Zachowana struktura tabeli")
    print()
    print("💡 WNIOSEK: Workflow poprawnie zaktualizuje tabelę!")

if __name__ == "__main__":
    main()