# Model auth triage

Use:

```powershell
cd C:\Users\Administrator\.openclaw
openclaw models status --probe --probe-timeout 20000
```

Interpretation:

- `HTTP 401` => credentials missing/expired (rotate API key or remove from fallbacks)
- `HTTP 403 access_denied` => account/token lacks permission for that model/provider
- `timeout` => network/proxy/DNS/TLS issue (verify proxy service and retry with higher timeout)

Stability tip:

- Keep `agents.defaults.model.fallbacks` limited to models that currently probe `ok`.

