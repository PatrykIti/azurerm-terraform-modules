/**
 * Semantic Release Configuration for Storage Account Module
 */

const MODULE_NAME = 'azurerm_storage_account';
const TAG_PREFIX = 'SAv';
const COMMIT_SCOPE = 'storage-account';

module.exports = {
  branches: ['main'],
  tagFormat: `${TAG_PREFIX}\${version}`,
  
  plugins: [
    // Analyze commits to determine version bump
    ['@semantic-release/commit-analyzer', {
      preset: 'conventionalcommits',
      releaseRules: [
        // Only process commits with our module scope
        {scope: COMMIT_SCOPE, breaking: true, release: 'major'},
        {scope: COMMIT_SCOPE, type: 'feat', release: 'minor'},
        {scope: COMMIT_SCOPE, type: 'fix', release: 'patch'},
        {scope: COMMIT_SCOPE, type: 'perf', release: 'patch'},
        {scope: COMMIT_SCOPE, type: 'revert', release: 'patch'},
        {scope: COMMIT_SCOPE, type: 'docs', release: 'patch'},
        {scope: COMMIT_SCOPE, type: 'refactor', release: 'patch'},
        // Ignore all commits without our scope
        {scope: '!'+COMMIT_SCOPE, release: false}
      ],
      parserOpts: {
        noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES']
      }
    }],
    
    // Generate release notes
    ['@semantic-release/release-notes-generator', {
      preset: 'conventionalcommits',
      parserOpts: {
        noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES']
      },
      presetConfig: {
        types: [
          {type: 'feat', section: '🚀 Features', hidden: false},
          {type: 'fix', section: '🐛 Bug Fixes', hidden: false},
          {type: 'perf', section: '⚡ Performance', hidden: false},
          {type: 'revert', section: '⏪ Reverts', hidden: false},
          {type: 'docs', section: '📚 Documentation', hidden: false},
          {type: 'refactor', section: '♻️ Refactoring', hidden: false},
          {type: 'test', section: '✅ Tests', hidden: true},
          {type: 'build', section: '📦 Build', hidden: true},
          {type: 'ci', section: '👷 CI', hidden: true},
          {type: 'chore', section: '🔧 Chores', hidden: true},
          {type: 'style', section: '💄 Style', hidden: true}
        ]
      },
      writerOpts: {
        commitsSort: ['subject', 'scope']
      }
    }],
    
    // Update CHANGELOG.md
    ['@semantic-release/changelog', {
      changelogFile: 'CHANGELOG.md',
      changelogTitle: `# Changelog

All notable changes to the Azure Storage Account Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).`
    }],
    
    // Update module-config.yml with new version and examples
    ['@semantic-release/exec', {
      prepareCmd: `
        # Update module-config.yml
        CONFIG_FILE=".github/module-config.yml"
        if [[ -f "$CONFIG_FILE" ]]; then
          sed -i "s/^version: .*/version: \${nextRelease.version}/" "$CONFIG_FILE"
        fi
        
        # Update examples to use the new version tag
        find examples -name "*.tf" -type f -exec sed -i 's|source.*=.*"\.\./../"|source = "github.com/PatrykIti/azurerm-terraform-modules//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}"|g' {} +
        
        # Update module source in all README files
        # Handle ../../ pattern (from examples)
        find . -name "README.md" -type f -exec sed -i 's|source = "../../"|source = "github.com/PatrykIti/azurerm-terraform-modules//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}"|g' {} +
        
        # Handle ../ pattern (from module root)
        find . -name "README.md" -type f -exec sed -i 's|source = "../"|source = "github.com/PatrykIti/azurerm-terraform-modules//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}"|g' {} +
        
        # Also update in terraform-docs table sections
        find . -name "README.md" -type f -exec sed -i 's| ../../ | github.com/PatrykIti/azurerm-terraform-modules//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version} |g' {} +
        
        # Update module version in README
        if [[ -x "../../scripts/update-module-version.sh" ]]; then
          ../../scripts/update-module-version.sh . "\${nextRelease.version}"
        fi
        
        # Update examples list in README
        if [[ -x "../../scripts/update-examples-list.sh" ]]; then
          ../../scripts/update-examples-list.sh .
        fi
        
        # Update README.md with terraform-docs
        if command -v terraform-docs &> /dev/null; then
          terraform-docs markdown table --output-file README.md .
        fi
        
        # Update root README.md with module status and version
        if [[ -x "../../scripts/update-root-readme.sh" ]]; then
          ../../scripts/update-root-readme.sh "${MODULE_NAME}" "Storage Account" "${TAG_PREFIX}" "\${nextRelease.version}" "PatrykIti" "azurerm-terraform-modules"
        fi
      `.trim()
    }],
    
    // Commit changes
    ['@semantic-release/git', {
      assets: [
        'modules/azurerm_storage_account/CHANGELOG.md',
        'modules/azurerm_storage_account/.github/module-config.yml',
        'modules/azurerm_storage_account/examples/**/*.tf',
        'modules/azurerm_storage_account/README.md',
        'README.md'
      ],
      message: `chore(${COMMIT_SCOPE}): release ${TAG_PREFIX}\${nextRelease.version} [skip ci]`
    }],
    
    // Create GitHub release
    ['@semantic-release/github', {
      successComment: false,
      failComment: false,
      labels: ['release', 'module:storage-account'],
      releaseBodyTemplate: `## Azure Storage Account Module v\${nextRelease.version}

\${nextRelease.notes}

### Installation

\`\`\`hcl
module "storage_account" {
  source = "github.com/PatrykIti/azurerm-terraform-modules//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}"
  
  # See README for configuration options
}
\`\`\`

### Documentation

See the [module documentation](https://github.com/PatrykIti/azurerm-terraform-modules/tree/${TAG_PREFIX}\${nextRelease.version}/modules/${MODULE_NAME}/README.md) for usage details.`
    }]
  ]
};