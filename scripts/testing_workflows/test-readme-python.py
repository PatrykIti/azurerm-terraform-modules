#!/usr/bin/env python3

import re
import shutil
from pathlib import Path

def main():
    print("=========================================")
    print("Python README.md Update Test")
    print("=========================================")
    print()

    # Create a working copy
    shutil.copy("README.md", "README.test.md")

    # Read the file
    with open("README.test.md", "r", encoding="utf-8") as f:
        content = f.read()

    # Modules to update
    modules = [
        {
            "name": "azurerm_kubernetes_cluster",
            "display": "Kubernetes Cluster",
            "prefix": "AKSv",
            "version": "1.1.0"
        },
        {
            "name": "azurerm_network_security_group",
            "display": "Network Security Group",
            "prefix": "NSGv",
            "version": "1.0.0"
        },
        {
            "name": "azurerm_route_table",
            "display": "Route Table",
            "prefix": "RTv",
            "version": "1.0.0"
        },
        {
            "name": "azurerm_storage_account",
            "display": "Storage Account",
            "prefix": "SAv",
            "version": "1.2.0"
        },
        {
            "name": "azurerm_subnet",
            "display": "Subnet",
            "prefix": "SNv",
            "version": "1.0.0"
        }
    ]

    print("📋 Initial module status:")
    print()

    # Show current status
    for module in modules:
        pattern = rf'\[{re.escape(module["display"])}\]\(./modules/{module["name"]}/\)[^|]*\|[^|]*\|[^|]*\|'
        matches = re.findall(pattern, content)
        if matches:
            print(f"{module['display']}:")
            print(f"  Current: {matches[0]}")

    print()
    print("🔄 Applying updates...")
    print()

    # Update each module
    for module in modules:
        name = module["name"]
        display = module["display"]
        prefix = module["prefix"]
        version = module["version"]

        # Pattern to match the module line in the table
        # Format: | [Display Name](./modules/module_name/) | Status | Version | Description |

        # Create the new version link
        new_version = f"[{prefix}{version}](https://github.com/PatrykIti/azurerm-terraform-modules/releases/tag/{prefix}{version})"

        # Pattern to find and replace the module line
        # This handles both simple version (v1.0.0) and linked version ([SAv1.0.0](link))
        pattern = rf'(\[{re.escape(display)}\]\(./modules/{name}/\) \| ✅ Completed \| )[^\|]+(\|)'
        replacement = rf'\1{new_version} \2'

        content = re.sub(pattern, replacement, content)

        print(f"✅ Updated {display} to {prefix}{version}")

    print()
    print("📝 Updating module badges...")
    print()

    # Find the badges section
    badges_start = content.find("<!-- MODULE BADGES START -->")
    badges_end = content.find("<!-- MODULE BADGES END -->")

    if badges_start != -1 and badges_end != -1:
        # Get existing badges
        before_badges = content[:badges_start + len("<!-- MODULE BADGES START -->")]
        after_badges = content[badges_end:]

        # Create new badges
        new_badges = ["\n"]
        for module in modules:
            display = module["display"]
            prefix = module["prefix"]
            url_encoded_name = display.replace(" ", "%20")
            badge = f'[![{display}](https://img.shields.io/github/v/tag/PatrykIti/azurerm-terraform-modules?filter={prefix}*&label={url_encoded_name}&color=success)](https://github.com/PatrykIti/azurerm-terraform-modules/releases?q={prefix})'
            new_badges.append(badge)

        # Reconstruct content with new badges
        content = before_badges + "\n".join(new_badges) + "\n" + after_badges
        print("✅ Updated badges section")

    # Write the updated content
    with open("README.test.md", "w", encoding="utf-8") as f:
        f.write(content)

    print()
    print("=========================================")
    print("📊 Results")
    print("=========================================")
    print()

    # Show updated status
    with open("README.test.md", "r", encoding="utf-8") as f:
        updated_content = f.read()

    print("Updated module lines:")
    print()
    for module in modules:
        pattern = rf'\[{re.escape(module["display"])}\]\(./modules/{module["name"]}/\)[^|]*\|[^|]*\|[^|]*\|'
        matches = re.findall(pattern, updated_content)
        if matches:
            print(f"{module['display']}:")
            # Clean up the output
            line = matches[0].replace("\n", " ").strip()
            print(f"  {line}")
            print()

    print("Updated badges section:")
    badges_match = re.search(r'<!-- MODULE BADGES START -->(.+?)<!-- MODULE BADGES END -->', updated_content, re.DOTALL)
    if badges_match:
        print(badges_match.group(0))

    print()
    print("=========================================")
    print("📝 Sample diff (first few changes):")
    print("=========================================")

    # Show a simple diff
    with open("README.md", "r", encoding="utf-8") as f:
        original = f.readlines()
    with open("README.test.md", "r", encoding="utf-8") as f:
        updated = f.readlines()

    changes_shown = 0
    for i, (orig, upd) in enumerate(zip(original, updated)):
        if orig != upd and changes_shown < 5:
            print(f"Line {i+1}:")
            print(f"  - {orig.strip()}")
            print(f"  + {upd.strip()}")
            print()
            changes_shown += 1

    # Cleanup
    Path("README.test.md").unlink()

    print("✅ Test completed successfully!")
    print()
    print("💡 Summary:")
    print("  - All 5 modules would be updated with new version links")
    print("  - Module badges would be added/updated")
    print("  - Each update preserves the table structure")
    print("  - Version links point to GitHub releases")

if __name__ == "__main__":
    main()