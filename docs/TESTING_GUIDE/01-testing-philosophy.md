# Testing Philosophy & Pyramid

## Core Testing Principles

Our testing approach is built on five fundamental principles that ensure reliable, secure, and cost-effective infrastructure testing:

### 1. Test at Multiple Levels
We implement a comprehensive testing pyramid that validates infrastructure at different levels of abstraction:

- **Static Analysis** - Catch syntax and security issues before deployment
- **Unit Tests** - Validate module logic without deploying resources
- **Integration Tests** - Test real Azure/Azure DevOps resource deployment and configuration (end-to-end for a single module)

### 2. Fail Fast
Early detection of issues saves time and reduces costs:

- **Pre-commit hooks** catch formatting and basic validation issues
- **Unit tests** validate logic and constraints without Azure costs
- **Static security scanning** identifies vulnerabilities before deployment
- **Parallel execution** provides rapid feedback on multiple scenarios

### 3. Test Real Infrastructure
While mocking is valuable for unit tests, integration tests must validate actual Azure resources:

- **Real deployments** catch provider-specific issues
- **Azure SDK validation** verifies resource properties and configuration
- **Network connectivity testing** ensures security rules work correctly
- **Compliance validation** confirms actual policy adherence

### 4. Cost Conscious
Testing infrastructure can be expensive, so we optimize for cost efficiency:

- **Minimal SKUs** - Use cheapest possible resource configurations
- **Mocking strategies** - Mock expensive resources in unit tests
- **Parallel execution** - Reduce total test time
- **Automatic cleanup** - Prevent resource leaks and ongoing costs

### 5. Security First
Security testing is embedded throughout the testing pipeline:

- **Secure defaults testing** - Verify security configurations are applied
- **Compliance validation** - Test against SOC2, ISO27001, GDPR, PCI DSS
- **Network isolation testing** - Validate private endpoints and network rules
- **Vulnerability scanning** - Continuous security assessment

## The Testing Pyramid

Our testing pyramid consists of three distinct levels, each serving a specific purpose:

```
           ┌─────────────────────────────┐
           │   Integration Tests (L3)    │  ← Slower, Costs Money
           │    Real Azure/ADO resources │     5-30 minutes per module
           │      Pull requests          │     Minimal Azure costs
           └─────────────────────────────┘
                  ┌─────────────────┐
                  │ Unit Tests (L2) │  ← Fast, Free
                  │  Mocked providers │   < 2 minutes
                  │   Every push    │     No Azure costs
                  └─────────────────┘
                         ┌─────┐
                         │ L1  │  ← Fastest, Free
                         │Static│     < 30 seconds
                         │Scan │     No Azure costs
                         └─────┘
```

### Level 1: Static Analysis (Fast & Free)

**Purpose**: Catch basic issues before any testing begins

**Tools**:
- `terraform validate` - Syntax and configuration validation
- `terraform fmt` - Code formatting consistency
- `tflint` - Terraform-specific linting
- `checkov` - Infrastructure security scanning
- `tfsec` - Terraform security analysis

**When**: On every commit (recommended via pre-commit hooks)

**Duration**: < 30 seconds

**Cost**: Free

**Example Configuration**:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_checkov
      - id: terraform_tfsec
```

### Level 2: Unit Tests (Fast & Free)

**Purpose**: Test module logic without deploying infrastructure

**Tools**: Native Terraform Test (`terraform test`)

**When**: On every push to any branch

**Duration**: < 2 minutes

**Cost**: Free (uses mocked providers)

**What to Test**:
- Variable validation and constraints
- Default value application
- Conditional resource creation logic
- Output formatting and structure
- Complex local value calculations

**Example Test Structure**:
```hcl
# tests/unit/defaults.tftest.hcl
mock_provider "azurerm" {
  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id   = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.ContainerService/managedClusters/test-aks"
      name = "test-aks"
    }
  }
}

variables {
  name                = "test-aks"
  resource_group_name = "test-rg"
  location            = "northeurope"
  dns_config = {
    dns_prefix = "testaks"
  }
  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }
  network_profile = {
    network_plugin = "azure"
  }
}

run "verify_default_identity" {
  command = plan
  
  assert {
    condition     = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].type == "SystemAssigned"
    error_message = "Default identity type should be SystemAssigned"
  }
}
```

### Level 3: Integration Tests (Slower & Costs Money)

**Purpose**: Validate real Azure resource deployment and configuration

**Tools**: Terratest with Go

**When**: On pull requests and main branch pushes

**Duration**: 5-30 minutes per module

**Cost**: Minimal (uses cheapest SKUs, automatic cleanup)

**What to Test**:
- Resource creation with correct properties
- Security configuration validation
- Network connectivity and isolation
- Azure Policy compliance
- IAM permissions and role assignments

**Example Test Structure**:
```go
func TestBasicKubernetesCluster(t *testing.T) {
    t.Parallel()
    
    terraformOptions := &terraform.Options{
        TerraformDir: "./fixtures/basic",
        Vars: map[string]interface{}{
            "random_suffix": random.UniqueId(),
        },
    }
    
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)
    
    // Validate using Azure SDK
    helper := NewKubernetesClusterHelper(t)
    cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)
    assert.Equal(t, "Succeeded", string(*cluster.Properties.ProvisioningState))
}
```

## Test Execution Strategy

### CI/CD Execution

Current repository workflows run:

- **PR validation**: formatting, `terraform validate`, and `terraform test` for affected modules.
- **Module CI**: module validation, Go-based integration tests, and security scans.
- **Workflow dispatch**: allows running Module CI for a specific module (inputs exist even if not all are currently wired to selective test runs).

### Parallel Execution

Tests are executed in parallel to minimize total execution time:

```yaml
# Example GitHub Actions matrix
strategy:
  matrix:
    module: [kubernetes_cluster, virtual_network, key_vault]
    test_type: [unit, integration, security]
  max-parallel: 6
```

## Quality Gates

Each level serves as a quality gate that must pass before proceeding:

### Gate 1: Static Analysis
- **Requirement**: All static analysis tools pass
- **Blocker**: Syntax errors, security vulnerabilities, formatting issues
- **Action**: Fix issues before proceeding to testing

### Gate 2: Unit Tests
- **Requirement**: 100% unit test pass rate
- **Blocker**: Logic errors, validation failures, output issues
- **Action**: Fix module logic before integration testing

### Gate 3: Integration Tests
- **Requirement**: All integration tests pass
- **Blocker**: Deployment failures, configuration errors, security issues
- **Action**: Fix module implementation before merge

There is no separate E2E tier in CI today; integration tests are the end-to-end validation for a module.

## Cost Optimization Strategies

### 1. Smart Resource Selection

Use the cheapest possible Azure SKUs for testing:

```go
// test_helpers.go
func GetTestSKUs() map[string]interface{} {
    return map[string]interface{}{
        "vm_size":              "Standard_B1s",    // Cheapest VM
        "node_count":           1,                 // Smallest node count
        "sku_tier":             "Free",           // Lowest AKS tier
        "db_sku":              "Basic",           // Basic database
        "app_service_sku":     "F1",             // Free tier
    }
}
```

### 2. Aggressive Cleanup

Implement multiple cleanup strategies:

```go
// Immediate cleanup on test completion
defer terraform.Destroy(t, terraformOptions)

// Cleanup on test failure
defer func() {
    if r := recover(); r != nil {
        terraform.Destroy(t, terraformOptions)
        panic(r)
    }
}()

// Background cleanup for leaked resources
// (Implemented in CI/CD pipeline)
```

### 3. Resource Sharing

Share expensive resources across tests when possible:

```go
// Shared resource group for multiple tests
func getSharedResourceGroup(t *testing.T) string {
    return fmt.Sprintf("rg-terratest-shared-%s", 
        os.Getenv("GITHUB_RUN_ID"))
}
```

### 4. Test Timeouts

Set aggressive timeouts to prevent runaway costs:

```go
terraformOptions := &terraform.Options{
    TerraformDir: testFolder,
    MaxRetries:   3,
    TimeBetweenRetries: 5 * time.Second,
    // Fail fast on long-running operations
}
```

## Security-First Testing

Security testing is integrated at every level:

### Static Security Analysis
```yaml
# Continuous security scanning
- name: Security Scan
  uses: bridgecrewio/checkov-action@master
  with:
    framework: terraform
    soft_fail: false  # Block on security issues
```

### Unit Security Tests
```hcl
# Verify secure defaults
run "verify_security_defaults" {
  command = plan
  
  assert {
    condition = azurerm_kubernetes_cluster.kubernetes_cluster.azure_policy_enabled == false
    error_message = "Azure Policy should be disabled by default"
  }
  
  assert {
    condition = azurerm_kubernetes_cluster.kubernetes_cluster.workload_identity_enabled == false
    error_message = "Workload Identity should be disabled by default"
  }
}
```

### Integration Security Tests
```go
func validateSecurityConfiguration(t *testing.T, terraformOptions *terraform.Options) {
    // Validate private cluster and policy settings
    helper := NewKubernetesClusterHelper(t)
    cluster := helper.GetKubernetesClusterProperties(t, resourceGroupName, clusterName)

    require.True(t, *cluster.Properties.APIServerAccessProfile.EnablePrivateCluster)
    require.NotNil(t, cluster.Properties.AddonProfiles["azurepolicy"])
    require.True(t, *cluster.Properties.AddonProfiles["azurepolicy"].Enabled)
}
```

### Compliance Testing
```go
func validateComplianceRequirements(t *testing.T, resourceGroupName string) {
    // SOC 2 Type II requirements
    validateEncryptionInTransit(t, resourceGroupName)
    validateAccessControls(t, resourceGroupName)
    validateAuditLogging(t, resourceGroupName)
    
    // GDPR requirements
    validateDataResidency(t, resourceGroupName)
    validateDataRetention(t, resourceGroupName)
    
    // PCI DSS requirements
    validateNetworkSegmentation(t, resourceGroupName)
    validateKeyManagement(t, resourceGroupName)
}
```

## Next Steps

Now that you understand the testing philosophy and pyramid structure, proceed to:

1. **[Test Organization](02-test-organization.md)** - Learn how to structure your test files
2. **[Native Terraform Tests](03-native-terraform-tests.md)** - Implement unit tests
3. **[Terratest Go File Structure](05-terratest-file-structure.md)** - Add integration tests

---

**Key Takeaways**:
- Test at multiple levels with different tools and purposes
- Fail fast with static analysis and unit tests
- Use real infrastructure for integration tests but optimize for cost
- Embed security testing throughout the pipeline
- Implement aggressive cleanup to prevent cost overruns
