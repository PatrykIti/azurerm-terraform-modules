/**
 * Semantic Release Configuration Template for Terraform Modules
 * 
 * This template should be copied to each module directory and customized:
 * 1. Update MODULE_NAME with actual module name
 * 2. Update TAG_PREFIX with module-specific prefix (e.g., 'SAv', 'VNv')
 * 3. Update COMMIT_SCOPE with the scope used in commit messages
 */

const MODULE_NAME = 'MODULE_NAME_PLACEHOLDER';
const TAG_PREFIX = 'PREFIX_PLACEHOLDER';
const COMMIT_SCOPE = 'SCOPE_PLACEHOLDER';

module.exports = {
  branches: ['main'],
  tagFormat: `${TAG_PREFIX}\${version}`,
  
  // Analyze only commits that affect this module
  repositoryUrl: 'https://github.com/yourusername/azurerm-terraform-modules.git',
  
  plugins: [
    // Analyze commits to determine version bump
    ['@semantic-release/commit-analyzer', {
      preset: 'conventionalcommits',
      releaseRules: [
        {breaking: true, release: 'major'},
        {type: 'feat', release: 'minor'},
        {type: 'fix', release: 'patch'},
        {type: 'perf', release: 'patch'},
        {type: 'revert', release: 'patch'},
        {type: 'docs', scope: 'README', release: 'patch'},
        {type: 'refactor', release: 'patch'},
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

All notable changes to the ${MODULE_NAME} Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).`
    }],
    
    // Update module-config.yml with new version
    ['@semantic-release/exec', {
      prepareCmd: `
        CONFIG_FILE=".github/module-config.yml"
        if [[ -f "$CONFIG_FILE" ]]; then
          sed -i "s/^version: .*/version: \${nextRelease.version}/" "$CONFIG_FILE"
        fi
      `.trim()
    }],
    
    // Commit changes
    ['@semantic-release/git', {
      assets: [
        'CHANGELOG.md',
        '.github/module-config.yml'
      ],
      message: `chore(release): ${TAG_PREFIX}\${nextRelease.version} [skip ci]

\${nextRelease.notes}`
    }],
    
    // Create GitHub release
    ['@semantic-release/github', {
      successComment: false,
      failComment: false,
      labels: ['release', `module:${MODULE_NAME}`],
      releaseBodyTemplate: `## ${MODULE_NAME} v\${nextRelease.version}

\${nextRelease.notes}

### Installation

\`\`\`hcl
module "${MODULE_NAME}" {
  source = "github.com/\${context.repo.owner}/\${context.repo.repo}//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}"
  
  # Configuration goes here
}
\`\`\`

### Documentation

See the [module documentation](https://github.com/\${context.repo.owner}/\${context.repo.repo}/tree/${TAG_PREFIX}\${nextRelease.version}/modules/${MODULE_NAME}/README.md) for usage details.`
    }]
  ],
  
  // Filter commits to only include those affecting this module
  filterCommits: (commits) => {
    return commits.filter(commit => {
      // Include commits with module scope
      if (commit.scope === COMMIT_SCOPE) {
        return true;
      }
      
      // Include commits that touch module files
      // This requires the commit to have file information
      // which semantic-release provides in certain contexts
      return false;
    });
  }
};