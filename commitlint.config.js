module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'scope-enum': [
      2,
      'always',
      [
        'storage-account',
        'virtual-network', 
        'key-vault',
        'app-service',
        'sql-database',
        'core',
        'deps',
        'ci',
        'docs',
        'release'
      ]
    ],
    'subject-case': [
      2,
      'never',
      ['sentence-case', 'start-case', 'pascal-case', 'upper-case']
    ],
    'header-max-length': [2, 'always', 100],
    'body-max-line-length': [2, 'always', 100]
  }
};