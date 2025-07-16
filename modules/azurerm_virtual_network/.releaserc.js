/**
 * Semantic Release Configuration – Dynamic Template
 */

const MODULE_NAME = 'azurerm_virtual_network';
const COMMIT_SCOPE = 'virtual-network';
const TAG_PREFIX = 'VNv';
const MODULE_TITLE = 'Virtual Network';

const SOURCE_URL = `github.com/PatrykIti/azurerm-terraform-modules//modules/${MODULE_NAME}?ref=${TAG_PREFIX}\${nextRelease.version}`;
const DOC_URL = `https://github.com/PatrykIti/azurerm-terraform-modules/tree/${TAG_PREFIX}\${nextRelease.version}/modules/${MODULE_NAME}`;

module.exports = {
  branches: ['main'],
  tagFormat: `${TAG_PREFIX}\${version}`,
  
  plugins: [
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
          { scope: `!${COMMIT_SCOPE}`, release: false }
        ],
        parserOpts: {
          noteKeywords: ['BREAKING CHANGE', 'BREAKING CHANGES'],
          transform(commit) {
            if (!commit.scope) return false;

            const scopes = commit.scope.split(',').map(s => s.trim());
            if (scopes.includes(COMMIT_SCOPE)) {
              commit.scope = COMMIT_SCOPE;
              return commit;
            }

            return false;
          }
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
            terraform-docs "modules/${MODULE_NAME}"
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
