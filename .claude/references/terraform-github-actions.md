# Terraform GitHub Actions Workflow Guidelines

This document provides comprehensive guidelines and best practices for creating GitHub Actions workflows for Terraform projects, with specific focus on Azure infrastructure modules.

## When to Use This Guideline

**MANDATORY REVIEW** when:
- Creating new GitHub Actions workflows for Terraform
- Setting up CI/CD pipelines for infrastructure code
- Implementing validation, security scanning, or deployment workflows
- Configuring automated testing for Terraform modules
- Integrating pre-commit hooks with GitHub Actions

## Core Workflow Components

### 1. Basic Terraform Validation Workflow

```yaml
name: Terraform Validation

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  terraform-validate:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v5
        with:
          fetch-depth: 0  # Fetch all history for proper diff detection

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.12.2  # Pin to specific version for consistency

      - name: Terraform Format Check
        id: fmt
        run: terraform fmt -check -recursive
        continue-on-error: true

      - name: Terraform Init
        id: init
        run: terraform init -backend=false

      - name: Terraform Validate
        id: validate
        run: terraform validate -no-color
```

### 2. Pre-commit Integration Workflow

```yaml
name: Pre-commit Checks

on:
  pull_request:
    branches: [main]

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/antonbabenko/pre-commit-terraform:latest
    defaults:
      run:
        shell: bash
    
    steps:
      - uses: actions/checkout@v5
        with:
          fetch-depth: 0
          ref: ${{ github.event.pull_request.head.sha }}

      - name: Configure Git Safe Directory
        run: |
          git config --global --add safe.directory $GITHUB_WORKSPACE
          git fetch --no-tags --prune --depth=1 origin +refs/heads/*:refs/remotes/origin/*

      - name: Get Changed Files
        id: file_changes
        run: |
          export DIFF=$(git diff --name-only origin/${{ github.base_ref }} ${{ github.sha }})
          echo "Diff between ${{ github.base_ref }} and ${{ github.sha }}"
          echo "files=$( echo \"$DIFF\" | xargs echo )" >> $GITHUB_OUTPUT

      - name: Fix Alpine Container Dependencies
        run: |
          apk --no-cache add tar
          python -m pip freeze --local

      - name: Cache Pre-commit
        uses: actions/cache@v4
        with:
          path: ~/.cache/pre-commit
          key: pre-commit-3|${{ hashFiles('.pre-commit-config.yaml') }}

      - name: Execute Pre-commit
        run: |
          pre-commit run --color=always --show-diff-on-failure --files ${{ steps.file_changes.outputs.files }}
```

### 3. Azure Backend Configuration with OIDC

For GitHub Actions with Azure backend state storage:

```yaml
name: Terraform Deploy

on:
  push:
    branches: [main]

permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  terraform-apply:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Azure Login via OIDC
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.12.2

      - name: Terraform Init with Azure Backend
        run: |
          terraform init \
            -backend-config="resource_group_name=${{ secrets.TF_STATE_RG }}" \
            -backend-config="storage_account_name=${{ secrets.TF_STATE_SA }}" \
            -backend-config="container_name=${{ secrets.TF_STATE_CONTAINER }}" \
            -backend-config="key=${{ github.repository }}.tfstate"
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

### 4. Security Scanning Workflow

```yaml
name: Security Scanning

on:
  pull_request:
    branches: [main]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Run Trivy Security Scan
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'config'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
          severity: 'CRITICAL,HIGH'

      - name: Upload Trivy Results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file_path: checkov-results.sarif

      - name: Upload Checkov Results
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'checkov-results.sarif'
```

### 5. Terraform Documentation Generation

```yaml
name: Generate Documentation

on:
  push:
    branches: [main]
    paths:
      - '*.tf'
      - '*.tfvars'

jobs:
  docs:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v5
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          ref: ${{ github.head_ref }}

      - name: Render terraform docs
        uses: terraform-docs/gh-actions@v1.0.0
        with:
          working-dir: .
          output-file: README.md
          output-method: inject
          git-push: "true"
```

## Best Practices

### 1. Workflow Triggers

```yaml
on:
  pull_request:
    branches: [main]
    paths:
      - '**.tf'
      - '**.tfvars'
      - '.github/workflows/terraform.yml'
  push:
    branches: [main]
    paths:
      - '**.tf'
      - '**.tfvars'
```

### 2. Matrix Strategy for Multiple Configurations

```yaml
jobs:
  terraform:
    strategy:
      matrix:
        terraform: [1.9.8, 1.12.2]
        module: [storage_account, virtual_network, key_vault]
    
    steps:
      - name: Setup Terraform ${{ matrix.terraform }}
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ matrix.terraform }}
      
      - name: Test Module ${{ matrix.module }}
        run: |
          cd modules/${{ matrix.module }}
          terraform init
          terraform validate
```

### 3. Caching Dependencies

```yaml
- name: Cache Terraform Plugins
  uses: actions/cache@v4
  with:
    path: |
      ~/.terraform.d/plugin-cache
      **/.terraform/providers
    key: ${{ runner.os }}-terraform-${{ hashFiles('**/.terraform.lock.hcl') }}
    restore-keys: |
      ${{ runner.os }}-terraform-
```

### 4. Environment-Specific Deployments

```yaml
jobs:
  deploy:
    strategy:
      matrix:
        environment: [dev, staging, prod]
    
    environment: ${{ matrix.environment }}
    
    steps:
      - name: Setup Environment Variables
        run: |
          echo "TF_VAR_environment=${{ matrix.environment }}" >> $GITHUB_ENV
          echo "TF_WORKSPACE=${{ matrix.environment }}" >> $GITHUB_ENV
```

### 5. Terraform Plan Output as PR Comment

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_wrapper: false  # Required for capturing output

- name: Terraform Plan
  id: plan
  run: |
    terraform plan -no-color -out=tfplan > plan_output.txt
    echo "plan<<EOF" >> $GITHUB_OUTPUT
    cat plan_output.txt >> $GITHUB_OUTPUT
    echo "EOF" >> $GITHUB_OUTPUT
  continue-on-error: true

- name: Comment PR
  uses: actions/github-script@v6
  if: github.event_name == 'pull_request'
  with:
    script: |
      const output = `#### Terraform Plan 📖\`${{ steps.plan.outcome }}\`
      
      <details><summary>Show Plan</summary>
      
      \`\`\`terraform
      ${{ steps.plan.outputs.plan }}
      \`\`\`
      
      </details>
      
      *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
      
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: output
      })
```

## Security Considerations

### 1. Secrets Management

```yaml
env:
  # Azure Authentication
  ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
  
  # Terraform Cloud
  TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
```

### 2. OIDC Authentication (Recommended)

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - name: Azure Login via OIDC
    uses: azure/login@v1
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

### 3. Least Privilege Permissions

```yaml
permissions:
  contents: read        # Read repository
  pull-requests: write  # Comment on PRs
  id-token: write      # OIDC authentication
  security-events: write # Upload SARIF results
```

## Module Testing Workflow

```yaml
name: Module Tests

on:
  pull_request:
    paths:
      - 'modules/**'
      - 'tests/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v5

      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.12.2
          terraform_wrapper: false

      - name: Run Terratest
        run: |
          cd tests
          go mod download
          go test -v -timeout 30m
        env:
          ARM_USE_OIDC: true
          ARM_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          ARM_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
          ARM_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Error Handling and Retry Logic

```yaml
- name: Terraform Apply with Retry
  uses: nick-fields/retry@v2
  with:
    timeout_minutes: 20
    max_attempts: 3
    retry_wait_seconds: 30
    command: terraform apply -auto-approve -input=false
    retry_on: error
```

## Workflow Dependencies

```yaml
jobs:
  validate:
    runs-on: ubuntu-latest
    # ... validation steps ...

  security:
    runs-on: ubuntu-latest
    needs: validate
    # ... security scanning steps ...

  deploy:
    runs-on: ubuntu-latest
    needs: [validate, security]
    if: github.ref == 'refs/heads/main'
    # ... deployment steps ...
```

## Notification and Monitoring

```yaml
- name: Notify on Failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Terraform workflow failed!'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Common Issues and Solutions

### 1. Terraform Lock File Conflicts
```yaml
- name: Update Lock File
  run: |
    terraform providers lock \
      -platform=windows_amd64 \
      -platform=darwin_amd64 \
      -platform=darwin_arm64 \
      -platform=linux_amd64
```

### 2. Rate Limiting
```yaml
- name: Setup Terraform with GitHub Token
  uses: hashicorp/setup-terraform@v3
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 3. Workspace Management
```yaml
- name: Select Terraform Workspace
  run: |
    terraform workspace select ${{ github.event.inputs.environment }} || \
    terraform workspace new ${{ github.event.inputs.environment }}
```

## Integration with TaskMaster

When using TaskMaster for task management:

```yaml
- name: Update Task Status
  if: success()
  run: |
    task-master set-status --id=${{ github.event.inputs.task_id }} --status=done
```

---

This guideline provides comprehensive patterns for implementing GitHub Actions workflows for Terraform projects, with specific considerations for Azure infrastructure and security best practices.