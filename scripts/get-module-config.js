#!/usr/bin/env node
/**
 * Extract module configuration from .releaserc.js file
 * Usage: node get-module-config.js <module-directory>
 */

const path = require('path');
const fs = require('fs');

const moduleDir = process.argv[2];
if (!moduleDir) {
  console.error('Error: Module directory not provided.');
  process.exit(1);
}

const configPath = path.resolve(process.cwd(), moduleDir, '.releaserc.js');
if (!fs.existsSync(configPath)) {
  console.error(`Error: Config file not found at ${configPath}`);
  process.exit(1);
}

// Clear require cache to ensure fresh load
delete require.cache[require.resolve(configPath)];
const config = require(configPath);

// 1. Extract tag prefix from tagFormat
const tagPrefix = config.tagFormat ? config.tagFormat.replace('${version}', '') : '';

// 2. Extract the primary commit scope from commit-analyzer rules
let commitScope = '';
const commitAnalyzerPlugin = config.plugins?.find(
  (p) => Array.isArray(p) && p[0].includes('@semantic-release/commit-analyzer')
);

if (commitAnalyzerPlugin && commitAnalyzerPlugin[1]?.releaseRules) {
  const releaseRules = commitAnalyzerPlugin[1].releaseRules;
  // Find the first rule with a positive scope (not starting with !)
  const scopeRule = releaseRules.find((rule) => rule.scope && !rule.scope.startsWith('!'));
  if (scopeRule) {
    commitScope = scopeRule.scope;
  }
}

if (!tagPrefix || !commitScope) {
  console.error('Error: Could not determine tag_prefix or commit_scope from module config.');
  console.error(`Found: tagPrefix="${tagPrefix}", commitScope="${commitScope}"`);
  process.exit(1);
}

// 3. Output as JSON for easy parsing in the workflow
console.log(JSON.stringify({ 
  tag_prefix: tagPrefix, 
  commit_scope: commitScope 
}));