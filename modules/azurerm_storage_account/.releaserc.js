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
        {scope: '!'+COMMIT_SCOPE, release: false},
        // Default rules for commits without scope (ignore them)
        {type: 'feat', release: false},
        {type: 'fix', release: false},
        {type: 'style', release: false},
        {type: 'chore', release: false},
        {type: 'test', release: false},
        {type: 'ci', release: false},
        {type: 'build', release: false}
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
        find examples -name "*.tf" -type f -exec sed -i 's|source.*=.*"\.\./../"|source = "github.com/\${context.repo.owner}/\${context.repo.repo}//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}"|g' {} +
      `.trim()
    }],
    
    // Commit changes
    ['@semantic-release/git', {
      assets: [
        'CHANGELOG.md',
        '.github/module-config.yml',
        'examples/**/*.tf'
      ],
      message: `chore(release): ${TAG_PREFIX}\${nextRelease.version} [skip ci]

\${nextRelease.notes}`
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
  source = "github.com/\${context.repo.owner}/\${context.repo.repo}//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}"
  
  # See README for configuration options
}
\`\`\`

### Documentation

See the [module documentation](https://github.com/\${context.repo.owner}/\${context.repo.repo}/tree/${TAG_PREFIX}\${nextRelease.version}/modules/${MODULE_NAME}/README.md) for usage details.`
    }]
  ]
};