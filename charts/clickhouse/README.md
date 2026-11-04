# ClickHouse

This Helm chart is installed as a subchart/dependency for the SigNoz Helm chart with default values.


## Using Kubernetes Secrets for ClickHouse Credentials

You can configure ClickHouse credentials to be sourced from a Kubernetes Secret. This is recommended for improved security and flexibility.

### Option 1: Let the chart create the secret

By default, the chart will create a secret with the username and password you specify in `values.yaml`:

```yaml
clickhouse:
  user: admin  # The ClickHouse username (used in configs)

clickhouseOperator:
  secret:
    create: true
    username: clickhouse_operator  # Username to store in the secret
    password: "<password>"         # Password to store in the secret (optional)
```

**Field reference:**
- `clickhouse.user`: The ClickHouse username that appears in configuration files
- `clickhouseOperator.secret.username`: The username value to store in the generated secret
- `clickhouseOperator.secret.password`: The password value to store in the generated secret. If empty, a random 24-character password will be automatically generated and preserved across upgrades.
- `clickhouseOperator.secret.usernameKey`: The key name for username in the secret (defaults to `username`)
- `clickhouseOperator.secret.passwordKey`: The key name for password in the secret (defaults to `password`)

**Security Best Practices:**
- **Avoid committing credentials in values.yaml** - This exposes passwords in your Git repository
- **Use auto-generated passwords** - Leave `password` empty to generate a secure random password
- **Use encrypted values** - Consider SOPS, helm-secrets, or sealed-secrets for GitOps workflows
- **Pass credentials at install time** - Use `helm install --set clickhouseOperator.secret.password=...` or `--set-file`
- **Use existing secrets** - For production, prefer creating secrets outside Helm and using `create: false`

### Option 2: Use an existing secret

If you already have a Kubernetes secret containing the credentials, set `create: false` and provide the secret name and key names:

```yaml
clickhouse:
  user: admin  # The ClickHouse username (used in configs)

clickhouseOperator:
  secret:
    create: false
    name: my-clickhouse-secret
    usernameKey: my-username-key   # Key name in secret (defaults to 'username')
    passwordKey: my-password-key   # Key name in secret (defaults to 'password')
```

The secret should look like this:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-clickhouse-secret
type: Opaque
data:
  my-username-key: <base64-encoded-username>
  my-password-key: <base64-encoded-password>
```

**Important**: When using existing secrets, do not set `username`/`password` in values. Credentials must come solely from the referenced Secret. Set `clickhouse.user` to the actual ClickHouse username used in configs.

---

### Usage recommendation

If you are not using a well-known reserved private IP address range that is whitelisted by default for your deployment environment (like minikube), e.g.:
  - 10.0.0.0/8
  - 100.64.0.0/10
  - 172.16.0.0/12
  - 192.0.0.0/24
  - 198.18.0.0/15
  - 192.168.0.0/16

You must whitelist the IP address range used for your environment (e.g., Kubernetes nodes' IPs) manually in the SigNoz values chart.

```yaml
clickhouse:
  allowedNetworkIps:
    - "192.173.0.0/16"
```

Otherwise you'll be getting error message like:

```
Failed to initialize ClickHouse: error connecting to primary db: code: 516,
message: admin: Authentication failed: password is incorrect, or there is no user with such name
```