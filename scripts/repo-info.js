'use strict';

const fs = require('fs');
const path = require('path');
const childProcess = require('child_process');

function parseRepoFromUrl(input) {
  if (!input || typeof input !== 'string') {
    return null;
  }

  let url = input.trim();
  if (!url) {
    return null;
  }

  const simpleMatch = url.match(/^([^/]+)\/([^/]+)$/);
  if (simpleMatch) {
    return { owner: simpleMatch[1], repo: simpleMatch[2].replace(/\.git$/, '') };
  }

  url = url.replace(/^git\+/, '');

  const patterns = [
    /^https?:\/\/github\.com\/(.+)$/,
    /^ssh:\/\/git@github\.com\/(.+)$/,
    /^git@github\.com:(.+)$/,
    /^github\.com\/(.+)$/
  ];

  let pathPart = null;
  for (const pattern of patterns) {
    const match = url.match(pattern);
    if (match) {
      pathPart = match[1];
      break;
    }
  }

  if (!pathPart) {
    return null;
  }

  pathPart = pathPart.replace(/\/+$/, '');
  const parts = pathPart.split('/');
  if (parts.length < 2) {
    return null;
  }

  const owner = parts[0];
  const repo = parts[1].replace(/\.git$/, '');

  if (!owner || !repo) {
    return null;
  }

  return { owner, repo };
}

function readPackageJsonRepo(rootDir) {
  const packageJsonPath = path.join(rootDir, 'package.json');
  if (!fs.existsSync(packageJsonPath)) {
    return null;
  }

  try {
    const pkg = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
    const repoField = pkg && pkg.repository;
    const repoUrl = typeof repoField === 'string' ? repoField : repoField && repoField.url;
    return parseRepoFromUrl(repoUrl);
  } catch (err) {
    return null;
  }
}

function readGitRemoteRepo(rootDir) {
  try {
    const remoteUrl = childProcess.execSync('git config --get remote.origin.url', {
      cwd: rootDir,
      stdio: ['ignore', 'pipe', 'ignore']
    }).toString().trim();
    return parseRepoFromUrl(remoteUrl);
  } catch (err) {
    return null;
  }
}

function getRepoInfo() {
  const envOwner = process.env.REPO_OWNER;
  const envRepo = process.env.REPO_NAME;
  if (envOwner && envRepo) {
    return { owner: envOwner, repo: envRepo };
  }

  const githubRepo = process.env.GITHUB_REPOSITORY;
  const fromGithubEnv = parseRepoFromUrl(githubRepo);
  if (fromGithubEnv) {
    return fromGithubEnv;
  }

  const envRepoUrl = process.env.REPO_URL || process.env.GITHUB_REPOSITORY_URL;
  const fromEnvUrl = parseRepoFromUrl(envRepoUrl);
  if (fromEnvUrl) {
    return fromEnvUrl;
  }

  const rootDir = path.resolve(__dirname, '..');

  const fromPackage = readPackageJsonRepo(rootDir);
  if (fromPackage) {
    return fromPackage;
  }

  const fromGit = readGitRemoteRepo(rootDir);
  if (fromGit) {
    return fromGit;
  }

  throw new Error(
    'Unable to determine repository owner/name. Set GITHUB_REPOSITORY or REPO_OWNER/REPO_NAME.'
  );
}

module.exports = { getRepoInfo };
