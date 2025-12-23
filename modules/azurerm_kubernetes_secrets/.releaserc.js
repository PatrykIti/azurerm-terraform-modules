/**
 * Semantic Release Configuration with Auto-loaded Module Config
 * This configuration automatically loads module settings from module.json
 */

const path = require('path');
const fs = require('fs');

// Auto-detect module directory
const moduleDir = __dirname;
const moduleName = path.basename(moduleDir);

// Load module configuration
const configPath = path.join(moduleDir, 'module.json');
if (!fs.existsSync(configPath)) {
  throw new Error(`Module configuration not found at ${configPath}. Please create module.json with required fields.`);
}

const moduleConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));

// Validate required fields
const requiredFields = ['name', 'title', 'commit_scope', 'tag_prefix'];
for (const field of requiredFields) {
  if (!moduleConfig[field]) {
    throw new Error(`Missing required field '${field}' in module.json`);
  }
}

// Extract configuration
const MODULE_NAME = moduleConfig.name;
const COMMIT_SCOPE = moduleConfig.commit_scope;
const TAG_PREFIX = moduleConfig.tag_prefix;
const MODULE_TITLE = moduleConfig.title;

// Validate that directory name matches module name
if (moduleName !== MODULE_NAME) {
  console.warn(`Warning: Directory name '${moduleName}' doesn't match module name '${MODULE_NAME}' in module.json`);
}

const SOURCE_URL = `github.com/PatrykIti/azurerm-terraform-modules//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}`;
const DOC_URL = `https://github.com/PatrykIti/azurerm-terraform-modules/tree/${TAG_PREFIX}\${nextRelease.version}/modules/${MODULE_NAME}`;

console.log(`📦 Semantic Release Configuration for ${MODULE_TITLE}`);
console.log(`   Module: ${MODULE_NAME}`);
console.log(`   Scope: ${COMMIT_SCOPE}`);
console.log(`   Tag Prefix: ${TAG_PREFIX}`);

module.exports = {
  branches: ['main'],
  tagFormat: `${TAG_PREFIX}\${version}`,
  
  plugins: [
    // Custom plugin to filter multi-scope commits
    ['./../../scripts/semantic-release-multi-scope-plugin.js', {
      targetScope: COMMIT_SCOPE
    }],
    
    [
      '@semantic-release/commit-analyzer',
      {
        preset: 'conventionalcommits',
        releaseRules: [
          { scope: COMMIT_SCOPE, breaking: true, release: 'major' },
          { scope: COMMIT_SCOPE, type: 'feat', release: 'minor' },
          { scope: COMMIT_SCOPE, type: 'fix', release: 'patch' },
          { scope: COMMIT_SCOPE, type: 'docs', release: 'patch' },
          { scope: COMMIT_SCOPE, type: 'refactor', release: 'patch' },
          { scope: COMMIT_SCOPE, type: 'perf', release: 'patch' },
          { scope: COMMIT_SCOPE, type: 'revert', release: 'patch' },
          { scope: COMMIT_SCOPE, type: 'test', release: false },
          { scope: COMMIT_SCOPE, type: 'build', release: false },
          { scope: COMMIT_SCOPE, type: 'ci', release: false },
          { scope: COMMIT_SCOPE, type: 'chore', release: false },
          { scope: COMMIT_SCOPE, type: 'style', release: false }
        ],
        parserOpts: {
          noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES']
        }
      }
    ],

    [
      '@semantic-release/release-notes-generator',
      {
        preset: 'conventionalcommits',
        parserOpts: {
          noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES']
        },
        presetConfig: {
          types: [
            { type: 'feat', section: '🚀 Features', hidden: false },
            { type: 'fix', section: '🐛 Bug Fixes', hidden: false },
            { type: 'perf', section: '⚡ Performance', hidden: false },
            { type: 'revert', section: '⏪ Reverts', hidden: false },
            { type: 'docs', section: '📚 Documentation', hidden: false },
            { type: 'refactor', section: '♻️ Refactoring', hidden: false },
            { type: 'test', section: '✅ Tests', hidden: true },
            { type: 'build', section: '📦 Build', hidden: true },
            { type: 'ci', section: '👷 CI', hidden: true },
            { type: 'chore', section: '🔧 Chores', hidden: true },
            { type: 'style', section: '💄 Style', hidden: true }
          ]
        },
        writerOpts: {
          commitsSort: ['subject', 'scope']
        }
      }
    ],

    [
      '@semantic-release/changelog',
      {
        changelogFile: 'CHANGELOG.md',
        changelogTitle: `# Changelog

All notable changes to the ${MODULE_TITLE} Terraform module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).`
      }
    ],

    [
      '@semantic-release/exec',
      {
        prepareCmd: `
          CONFIG_FILE="modules/${MODULE_NAME}/.github/module-config.yml"
          if [[ -f "$CONFIG_FILE" ]]; then
            sed -i "s/^version: .*/version: \${nextRelease.version}/" "$CONFIG_FILE"
          fi

          find "modules/${MODULE_NAME}/examples" -name "*.tf" -type f -exec sed -i 's|source.*=.*"|source = "${SOURCE_URL}"|g' {} +

          find "modules/${MODULE_NAME}" -name "README.md" -type f -exec sed -i 's|source = "../../"|source = "${SOURCE_URL}"|g' {} +
          find "modules/${MODULE_NAME}" -name "README.md" -type f -exec sed -i 's|source = "../"|source = "${SOURCE_URL}"|g' {} +
          find "modules/${MODULE_NAME}" -name "README.md" -type f -exec sed -i 's| ../../ | ${SOURCE_URL} |g' {} +
          find "modules/${MODULE_NAME}" -name "README.md" -type f -exec sed -i 's| ../.. | ${SOURCE_URL} |g' {} +

          if [[ -x "./scripts/update-module-version.sh" ]]; then
            ./scripts/update-module-version.sh "modules/${MODULE_NAME}" "\${nextRelease.version}"
          fi

          if [[ -x "./scripts/update-examples-list.sh" ]]; then
            ./scripts/update-examples-list.sh "modules/${MODULE_NAME}"
          fi

          if command -v terraform-docs &> /dev/null; then
            cd "modules/${MODULE_NAME}" && terraform-docs markdown table --output-file README.md --output-mode inject .
          fi

          if [[ -x "./scripts/update-root-readme.sh" ]]; then
            ./scripts/update-root-readme.sh "${MODULE_NAME}" "${MODULE_TITLE}" "${TAG_PREFIX}" "\${nextRelease.version}" "PatrykIti" "azurerm-terraform-modules"
          fi
        `.trim()
      }
    ],

    [
      '@semantic-release/git',
      {
        assets: [
          `modules/${MODULE_NAME}/CHANGELOG.md`,
          `modules/${MODULE_NAME}/.github/module-config.yml`,
          `modules/${MODULE_NAME}/examples/**/*.tf`,
          `modules/${MODULE_NAME}/README.md`,
          'README.md'
        ],
        message: `chore(${COMMIT_SCOPE}): release ${TAG_PREFIX}\${nextRelease.version} [skip ci]`
      }
    ],

    [
      '@semantic-release/github',
      {
        successComment: false,
        failComment: false,
        labels: ['release', `module:${COMMIT_SCOPE}`],
        releaseBodyTemplate: `## ${MODULE_TITLE} Module v\${nextRelease.version}

\${nextRelease.notes}

### Installation

\`\`\`hcl
module "${COMMIT_SCOPE}" {
  source = "${SOURCE_URL}"
}
\`\`\`

### Documentation

See the [module documentation](${DOC_URL}/README.md) for usage details.`
      }
    ]
  ]
};