#!/usr/bin/env node
/**
 * Extract module configuration from module.json or .releaserc.js file
 * Usage: node get-module-config.js <module-directory>
 */

const path = require('path');
const fs = require('fs');

const moduleDir = process.argv[2];
if (!moduleDir) {
  console.error('Error: Module directory not provided.');
  process.exit(1);
}

// First try to load from module.json
const moduleJsonPath = path.resolve(process.cwd(), moduleDir, 'module.json');
if (fs.existsSync(moduleJsonPath)) {
  try {
    const moduleConfig = JSON.parse(fs.readFileSync(moduleJsonPath, 'utf8'));
    
    // Validate required fields
    if (!moduleConfig.tag_prefix || !moduleConfig.commit_scope) {
      console.error('Error: module.json missing required fields (tag_prefix, commit_scope)');
      process.exit(1);
    }
    
    // Output as JSON for easy parsing in the workflow
    console.log(JSON.stringify({ 
      tag_prefix: moduleConfig.tag_prefix, 
      commit_scope: moduleConfig.commit_scope 
    }));
    process.exit(0);
  } catch (e) {
    console.error(`Error reading module.json: ${e.message}`);
    // Fall through to try .releaserc.js
  }
}

// Fallback to .releaserc.js
const configPath = path.resolve(process.cwd(), moduleDir, '.releaserc.js');
if (!fs.existsSync(configPath)) {
  console.error(`Error: Neither module.json nor .releaserc.js found in ${moduleDir}`);
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