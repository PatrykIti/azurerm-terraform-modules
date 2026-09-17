#!/usr/bin/env node
'use strict';

const fs = require('fs');
const path = require('path');
const childProcess = require('child_process');
const { getRepoInfo } = require('./repo-info');

const repoRoot = path.resolve(__dirname, '..');
const rootReadmePath = path.join(repoRoot, 'README.md');
const modulesReadmePath = path.join(repoRoot, 'modules', 'README.md');

const args = parseArgs(process.argv.slice(2));

if (args.rootOnly && args.modulesOnly) {
  throw new Error('Use either --root-only or --modules-only, not both.');
}

const overrideModule = args.overrideModule || null;
const overrideVersion = args.overrideVersion || null;
const writeRoot = !args.modulesOnly;
const writeModules = !args.rootOnly;

const { owner: repoOwner, repo: repoName } = getRepoInfo();
const modules = loadModules();
const releasedTagByModule = buildReleasedTagMap(modules, overrideModule, overrideVersion);

if (writeRoot) {
  updateRootReadme();
}

if (writeModules) {
  updateModulesReadme();
}

function parseArgs(argv) {
  const parsed = {
    rootOnly: false,
    modulesOnly: false,
    overrideModule: null,
    overrideVersion: null
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    switch (arg) {
      case '--root-only':
        parsed.rootOnly = true;
        break;
      case '--modules-only':
        parsed.modulesOnly = true;
        break;
      case '--override-module':
        parsed.overrideModule = argv[i + 1];
        i += 1;
        break;
      case '--override-version':
        parsed.overrideVersion = argv[i + 1];
        i += 1;
        break;
      default:
        throw new Error(`Unknown argument: ${arg}`);
    }
  }

  if ((parsed.overrideModule && !parsed.overrideVersion) || (!parsed.overrideModule && parsed.overrideVersion)) {
    throw new Error('Both --override-module and --override-version must be provided together.');
  }

  return parsed;
}

function git(argsList) {
  return childProcess.execFileSync('git', argsList, {
    cwd: repoRoot,
    encoding: 'utf8',
    stdio: ['ignore', 'pipe', 'ignore']
  }).trim();
}

function loadModules() {
  const modulesDir = path.join(repoRoot, 'modules');
  const entries = fs.readdirSync(modulesDir, { withFileTypes: true });

  return entries
    .filter((entry) => entry.isDirectory())
    .map((entry) => {
      const moduleJsonPath = path.join(modulesDir, entry.name, 'module.json');
      if (!fs.existsSync(moduleJsonPath)) {
        return null;
      }

      const moduleJson = JSON.parse(fs.readFileSync(moduleJsonPath, 'utf8'));
      return {
        name: moduleJson.name || entry.name,
        title: moduleJson.title || moduleJson.name || entry.name,
        description: moduleJson.description || '',
        tagPrefix: moduleJson.tag_prefix,
        commitScope: moduleJson.commit_scope || '',
        provider: detectProvider(entry.name)
      };
    })
    .filter(Boolean)
    .sort((left, right) => left.title.localeCompare(right.title, 'en', { sensitivity: 'base' }));
}

function detectProvider(moduleName) {
  if (moduleName.startsWith('azuredevops_')) {
    return 'azuredevops';
  }

  if (moduleName.startsWith('kubernetes_')) {
    return 'kubernetes';
  }

  return 'azurerm';
}

function buildReleasedTagMap(moduleList, targetModule, targetVersion) {
  const allTags = git(['tag', '--list'])
    .split(/\r?\n/)
    .filter(Boolean);

  const releasedMap = new Map();

  for (const moduleDef of moduleList) {
    const candidates = allTags.filter((tag) => tag.startsWith(moduleDef.tagPrefix));
    if (targetModule === moduleDef.name && targetVersion) {
      candidates.push(`${moduleDef.tagPrefix}${targetVersion}`);
    }
    releasedMap.set(moduleDef.name, pickLatestTag(moduleDef.tagPrefix, candidates));
  }

  return releasedMap;
}

function pickLatestTag(tagPrefix, candidates) {
  let best = null;

  for (const tag of candidates) {
    if (!tag.startsWith(tagPrefix)) {
      continue;
    }

    const version = tag.slice(tagPrefix.length);
    if (!isValidSemver(version)) {
      continue;
    }

    if (!best || compareSemver(version, best.version) > 0) {
      best = { tag, version };
    }
  }

  return best ? best.tag : null;
}

function isValidSemver(version) {
  return /^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$/.test(version);
}

function compareSemver(left, right) {
  const parsedLeft = parseSemver(left);
  const parsedRight = parseSemver(right);

  for (const key of ['major', 'minor', 'patch']) {
    if (parsedLeft[key] !== parsedRight[key]) {
      return parsedLeft[key] > parsedRight[key] ? 1 : -1;
    }
  }

  return comparePrerelease(parsedLeft.prerelease, parsedRight.prerelease);
}

function parseSemver(version) {
  const [core, ...prereleaseParts] = version.split('-');
  const [major, minor, patch] = core.split('.').map((part) => Number(part));

  return {
    major,
    minor,
    patch,
    prerelease: prereleaseParts.length > 0 ? prereleaseParts.join('-').split('.') : []
  };
}

function comparePrerelease(left, right) {
  if (left.length === 0 && right.length === 0) {
    return 0;
  }
  if (left.length === 0) {
    return 1;
  }
  if (right.length === 0) {
    return -1;
  }

  const maxLength = Math.max(left.length, right.length);
  for (let i = 0; i < maxLength; i += 1) {
    const leftPart = left[i];
    const rightPart = right[i];

    if (leftPart === undefined) {
      return -1;
    }
    if (rightPart === undefined) {
      return 1;
    }

    if (leftPart === rightPart) {
      continue;
    }

    const leftNumeric = /^\d+$/.test(leftPart);
    const rightNumeric = /^\d+$/.test(rightPart);

    if (leftNumeric && rightNumeric) {
      return Number(leftPart) > Number(rightPart) ? 1 : -1;
    }
    if (leftNumeric) {
      return -1;
    }
    if (rightNumeric) {
      return 1;
    }

    return leftPart.localeCompare(rightPart, 'en', { sensitivity: 'base' }) > 0 ? 1 : -1;
  }

  return 0;
}

function escapeForTable(value) {
  return String(value || '').replace(/\|/g, '\\|');
}

function renderRootBadges(moduleList) {
  return moduleList
    .filter((moduleDef) => releasedTagByModule.get(moduleDef.name))
    .map((moduleDef) => {
      const releasedTag = releasedTagByModule.get(moduleDef.name);
      const badgeLabel = encodeURIComponent(moduleDef.title);
      return `[![${moduleDef.title}](https://img.shields.io/github/v/tag/${repoOwner}/${repoName}?filter=${moduleDef.tagPrefix}*&label=${badgeLabel}&color=success)](https://github.com/${repoOwner}/${repoName}/releases/tag/${releasedTag})`;
    })
    .join('\n');
}

function renderRootTable(moduleList) {
  const lines = [
    '| Module | Status | Version | Description |',
    '| --- | --- | --- | --- |'
  ];

  for (const moduleDef of moduleList) {
    const releasedTag = releasedTagByModule.get(moduleDef.name);
    const status = releasedTag ? '✅ Completed' : '🧪 Development';
    const versionCell = releasedTag
      ? `[${releasedTag}](https://github.com/${repoOwner}/${repoName}/releases/tag/${releasedTag})`
      : 'vUnreleased';

    lines.push(
      `| [${moduleDef.title}](./modules/${moduleDef.name}/) | ${status} | ${versionCell} | ${escapeForTable(moduleDef.description)} |`
    );
  }

  return lines.join('\n');
}

function renderModulesIndexTable(moduleList) {
  const lines = [
    '| Module | Tag Prefix | Description |',
    '| --- | --- | --- |'
  ];

  for (const moduleDef of moduleList) {
    lines.push(
      `| [${moduleDef.title}](./${moduleDef.name}/) (\`${moduleDef.name}\`) | \`${moduleDef.tagPrefix}\` | ${escapeForTable(moduleDef.description)} |`
    );
  }

  return lines.join('\n');
}

function replaceMarkedSection(content, startMarker, endMarker, replacement) {
  const pattern = new RegExp(`${escapeRegExp(startMarker)}[\\s\\S]*?${escapeRegExp(endMarker)}`);
  return content.replace(pattern, `${startMarker}\n${replacement}\n${endMarker}`);
}

function ensureMarkedSection(content, startMarker, endMarker, replacement, fallbackPattern, buildReplacement) {
  if (content.includes(startMarker) && content.includes(endMarker)) {
    return replaceMarkedSection(content, startMarker, endMarker, replacement);
  }

  if (!fallbackPattern.test(content)) {
    throw new Error(`Unable to locate section for markers ${startMarker} / ${endMarker}`);
  }

  return content.replace(fallbackPattern, buildReplacement(replacement));
}

function updateRootReadme() {
  const azurermModules = modules.filter((moduleDef) => moduleDef.provider === 'azurerm');
  const kubernetesModules = modules.filter((moduleDef) => moduleDef.provider === 'kubernetes');
  const azureDevOpsModules = modules.filter((moduleDef) => moduleDef.provider === 'azuredevops');

  let content = fs.readFileSync(rootReadmePath, 'utf8');

  content = ensureMarkedSection(
    content,
    '<!-- MODULE BADGES START -->',
    '<!-- MODULE BADGES END -->',
    renderRootBadges(modules),
    /<!-- MODULE BADGES START -->[\s\S]*?<!-- MODULE BADGES END -->/,
    (replacement) => `<!-- MODULE BADGES START -->\n${replacement}\n<!-- MODULE BADGES END -->`
  );

  content = ensureMarkedSection(
    content,
    '<!-- AZURERM_MODULES_TABLE_START -->',
    '<!-- AZURERM_MODULES_TABLE_END -->',
    renderRootTable(azurermModules),
    /(### AzureRM Modules\s*\n\n)([\s\S]*?)(\n### Kubernetes Modules)/,
    (replacement) => `$1<!-- AZURERM_MODULES_TABLE_START -->\n${replacement}\n<!-- AZURERM_MODULES_TABLE_END -->$3`
  );

  content = ensureMarkedSection(
    content,
    '<!-- KUBERNETES_MODULES_TABLE_START -->',
    '<!-- KUBERNETES_MODULES_TABLE_END -->',
    renderRootTable(kubernetesModules),
    /(### Kubernetes Modules\s*\n\n)([\s\S]*?)(\n### Azure DevOps Modules)/,
    (replacement) => `$1<!-- KUBERNETES_MODULES_TABLE_START -->\n${replacement}\n<!-- KUBERNETES_MODULES_TABLE_END -->$3`
  );

  content = ensureMarkedSection(
    content,
    '<!-- AZUREDEVOPS_MODULES_TABLE_START -->',
    '<!-- AZUREDEVOPS_MODULES_TABLE_END -->',
    renderRootTable(azureDevOpsModules),
    /(### Azure DevOps Modules\s*\n\nNote:[^\n]*\n\n)([\s\S]*?)(\nVersions are sourced from module changelogs and release tags\. Modules without a tagged release remain in Development\.)/,
    (replacement) => `$1<!-- AZUREDEVOPS_MODULES_TABLE_START -->\n${replacement}\n<!-- AZUREDEVOPS_MODULES_TABLE_END -->$3`
  );

  fs.writeFileSync(rootReadmePath, content);
  console.log(`Updated ${path.relative(repoRoot, rootReadmePath)}`);
}

function updateModulesReadme() {
  const azurermModules = modules.filter((moduleDef) => moduleDef.provider === 'azurerm');
  const kubernetesModules = modules.filter((moduleDef) => moduleDef.provider === 'kubernetes');
  const azureDevOpsModules = modules.filter((moduleDef) => moduleDef.provider === 'azuredevops');

  let content = fs.readFileSync(modulesReadmePath, 'utf8');

  content = ensureMarkedSection(
    content,
    '<!-- MODULES_INDEX_AZURERM_START -->',
    '<!-- MODULES_INDEX_AZURERM_END -->',
    renderModulesIndexTable(azurermModules),
    /(## AzureRM Modules\s*\n\n)([\s\S]*?)(\n## Kubernetes Modules)/,
    (replacement) => `$1<!-- MODULES_INDEX_AZURERM_START -->\n${replacement}\n<!-- MODULES_INDEX_AZURERM_END -->$3`
  );

  content = ensureMarkedSection(
    content,
    '<!-- MODULES_INDEX_KUBERNETES_START -->',
    '<!-- MODULES_INDEX_KUBERNETES_END -->',
    renderModulesIndexTable(kubernetesModules),
    /(## Kubernetes Modules\s*\n\n)([\s\S]*?)(\n## Azure DevOps Modules)/,
    (replacement) => `$1<!-- MODULES_INDEX_KUBERNETES_START -->\n${replacement}\n<!-- MODULES_INDEX_KUBERNETES_END -->$3`
  );

  content = ensureMarkedSection(
    content,
    '<!-- MODULES_INDEX_AZUREDEVOPS_START -->',
    '<!-- MODULES_INDEX_AZUREDEVOPS_END -->',
    renderModulesIndexTable(azureDevOpsModules),
    /(## Azure DevOps Modules\s*\n\nNote:[^\n]*\n\n)([\s\S]*)$/,
    (replacement) => `${content.match(/(## Azure DevOps Modules\s*\n\nNote:[^\n]*\n\n)/)[1]}<!-- MODULES_INDEX_AZUREDEVOPS_START -->\n${replacement}\n<!-- MODULES_INDEX_AZUREDEVOPS_END -->\n`
  );

  fs.writeFileSync(modulesReadmePath, content);
  console.log(`Updated ${path.relative(repoRoot, modulesReadmePath)}`);
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}
