#!/bin/bash

# Generate terraform-docs configuration for example directories with full content
# Usage: ./generate-full-example-docs-config.sh <example-path>

set -e

EXAMPLE_PATH="${1:-.}"
EXAMPLE_NAME=$(basename "$EXAMPLE_PATH")

# Generate readable example name
EXAMPLE_TITLE=$(echo "$EXAMPLE_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')

# Get description based on example type
case "$EXAMPLE_NAME" in
    basic)
        DESCRIPTION="This example demonstrates a basic Azure Storage Account configuration using secure defaults and minimal setup."
        FEATURES="- Creates a basic storage account with Standard tier and LRS replication
- Uses secure defaults (shared access keys disabled by default)
- Creates a dedicated resource group for the storage account
- Demonstrates container creation using the module's containers parameter
- Uses variables for configuration flexibility"
        KEY_CONFIG="This example uses secure defaults with shared access keys disabled. It demonstrates:
- Creating a storage container using the module's \`containers\` parameter
- Using variables for easy configuration customization
- Following security best practices by default

To enable shared access keys (for development or legacy compatibility), uncomment the security_settings block in main.tf."
        ;;
    complete)
        DESCRIPTION="This example demonstrates a comprehensive deployment of an Azure Storage Account with all available features and security configurations."
        FEATURES="- Full storage account configuration with all features enabled
- Private endpoints for secure network connectivity
- Diagnostic settings for monitoring and auditing
- Lifecycle management policies for automatic data management
- Customer-managed keys for encryption at rest
- Static website hosting configuration
- Advanced security settings and threat protection"
        KEY_CONFIG="This comprehensive example showcases all available features of the storage account module, demonstrating enterprise-grade security and management capabilities."
        ;;
    secure)
        DESCRIPTION="This example demonstrates a maximum-security Azure Storage Account configuration suitable for highly sensitive data and regulated environments."
        FEATURES="- Maximum security configuration with all security features enabled
- Infrastructure encryption for double encryption at rest
- Firewall rules restricting access to specific IP ranges
- Private endpoints for all storage services
- Advanced threat protection enabled
- Comprehensive audit logging and monitoring
- Immutability policies for compliance requirements"
        KEY_CONFIG="This example implements defense-in-depth security principles with multiple layers of protection suitable for highly regulated industries."
        ;;
    secure-private-endpoint)
        DESCRIPTION="This example demonstrates how to deploy a highly secure Azure Storage Account suitable for production environments handling sensitive data."
        FEATURES="- Private endpoint configuration for secure network isolation
- Firewall rules with strict access control
- Infrastructure encryption enabled
- Comprehensive monitoring and diagnostics
- Secure defaults with public access disabled"
        KEY_CONFIG="This example focuses on network security through private endpoints while maintaining all other security best practices."
        ;;
    data-lake-gen2)
        DESCRIPTION="This example demonstrates how to configure an Azure Storage Account as a Data Lake Storage Gen2 with hierarchical namespace, SFTP, and NFSv3 support."
        FEATURES="- Hierarchical namespace enabled for Data Lake Gen2
- SFTP endpoint for secure file transfer
- NFSv3 protocol support for Linux workloads
- Large file share support
- Optimized for big data analytics workloads"
        KEY_CONFIG="This example is optimized for big data and analytics scenarios, providing compatibility with Hadoop-compatible file systems."
        ;;
    identity-access)
        DESCRIPTION="This example demonstrates how to configure an Azure Storage Account with **keyless authentication** using managed identities and Microsoft Entra ID (formerly Azure AD) integration. This approach eliminates the need for shared access keys, providing enhanced security through identity-based access control."
        FEATURES="- Managed identity configuration for keyless authentication
- Microsoft Entra ID integration for user authentication
- Role-based access control (RBAC) for fine-grained permissions
- Shared access keys disabled for maximum security
- OAuth authentication enabled by default"
        KEY_CONFIG="This example showcases modern authentication patterns using Azure AD/Entra ID, eliminating the security risks associated with shared access keys."
        ;;
    multi-region)
        DESCRIPTION="This example demonstrates a comprehensive multi-region Azure Storage Account deployment strategy with enhanced disaster recovery capabilities, cross-tenant replication, and optimized geo-redundancy configurations."
        FEATURES="- Geo-redundant storage with read access (RA-GRS)
- Cross-tenant replication enabled
- Optimized routing for global access
- Multiple region deployment strategy
- Enhanced disaster recovery capabilities"
        KEY_CONFIG="This example is designed for globally distributed applications requiring high availability and disaster recovery across multiple Azure regions."
        ;;
    advanced-policies)
        DESCRIPTION="This example demonstrates the implementation of advanced storage account policies including SAS policies, immutability policies, routing preferences, custom domains, and SMB configurations."
        FEATURES="- SAS (Shared Access Signature) policies for controlled access
- Immutability policies for compliance requirements
- Custom domain configuration
- Advanced routing preferences
- SMB multichannel for enhanced performance
- Comprehensive lifecycle management rules"
        KEY_CONFIG="This example showcases advanced policy configurations for enterprise scenarios requiring fine-grained control over storage account behavior."
        ;;
    *)
        DESCRIPTION="This example demonstrates $EXAMPLE_TITLE configuration for Azure Storage Account."
        FEATURES="- $EXAMPLE_TITLE specific features and configurations"
        KEY_CONFIG="This example provides a $EXAMPLE_TITLE implementation pattern."
        ;;
esac

# Generate the terraform-docs configuration with full content
cat > "$EXAMPLE_PATH/.terraform-docs.yml" << 'EOFDOC'
formatter: "markdown"

version: ""

header-from: ""

recursive:
  enabled: false

sections:
  hide: []
  show: []

content: |-
  # EXAMPLE_TITLE_PLACEHOLDER Storage Account Example

  DESCRIPTION_PLACEHOLDER

  ## Features

  FEATURES_PLACEHOLDER

  ## Key Configuration

  KEY_CONFIG_PLACEHOLDER

  ## Usage

  ```bash
  terraform init
  terraform plan
  terraform apply
  ```

  {{ .Requirements }}

  {{ .Providers }}

  {{ .Modules }}

  {{ .Resources }}

  {{ .Inputs }}

  {{ .Outputs }}

output:
  file: README.md
  mode: replace
EOFDOC

# Replace placeholders
sed -i '' "s/EXAMPLE_TITLE_PLACEHOLDER/$EXAMPLE_TITLE/g" "$EXAMPLE_PATH/.terraform-docs.yml"
sed -i '' "s/DESCRIPTION_PLACEHOLDER/${DESCRIPTION//\//\\/}/g" "$EXAMPLE_PATH/.terraform-docs.yml"

# Handle multi-line replacements
perl -i -pe "s/FEATURES_PLACEHOLDER/$FEATURES/g" "$EXAMPLE_PATH/.terraform-docs.yml"
perl -i -pe "s/KEY_CONFIG_PLACEHOLDER/$KEY_CONFIG/g" "$EXAMPLE_PATH/.terraform-docs.yml"

echo "✅ Generated full .terraform-docs.yml for example: $EXAMPLE_NAME"