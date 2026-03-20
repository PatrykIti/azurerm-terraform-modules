# Import

## RoleBinding

```hcl
import {
  to = kubernetes_role_binding_v1.role_binding
  id = "intent-resolver/intent-resolver-read-users"
}
```

The import ID format is `<namespace>/<name>`.
