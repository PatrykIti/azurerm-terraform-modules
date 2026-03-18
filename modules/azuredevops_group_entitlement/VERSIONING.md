# Module Versioning Guide

This module uses semantic versioning with tag prefix:

```text
ADOGEv{major}.{minor}.{patch}
```

Examples:
- `ADOGEv1.0.0`
- `ADOGEv1.1.0`
- `ADOGEv2.0.0`

Use conventional commits with module scope:

```text
feat(azuredevops-group-entitlement): ...
fix(azuredevops-group-entitlement): ...
```

Breaking changes should include `BREAKING CHANGE:` in the commit footer.
