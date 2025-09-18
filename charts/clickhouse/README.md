# Clickhouse

This helmchart is being installed as subchart/dependecy for signoz helmchart with default values.


## Using Kubernetes Secrets for ClickHouse Credentials

You can configure ClickHouse credentials to be sourced from a Kubernetes Secret. This is recommended for improved security and flexibility.

### Option 1: Let the chart create the secret


By default, the chart will create a secret with the username and password you specify in `values.yaml`:

```yaml
clickhouseOperator:
  secret:
    create: true
    username: myuser
    password: mypassword  # The password to set in the generated secret (used as the value for the password key)
```

**Field reference:**

- `username`: The username to store in the generated secret (key: `username` by default).
- `password`: The password to store in the generated secret (key: `password` by default). This field is required if `create: true`.

If you do not set `password` when `create: true`, the chart will fail to install.

### Option 2: Use an existing secret

If you already have a Kubernetes secret containing the credentials, set `create: false` and provide the secret name and key names:

```yaml
clickhouseOperator:
  secret:
    create: false
    name: my-clickhouse-secret
    usernameKey: my-username-key   # defaults to 'username' if not set
    passwordKey: my-password-key   # defaults to 'password' if not set
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

---

### Usage recommendation

In case you are not using a well-know reserved private IP address range that are whitelisted by default for your deployment environment (like for minikube environment), eg:
  - 10.0.0.0/8
  - 100.64.0.0/10
  - 172.16.0.0/12
  - 192.0.0.0/24
  - 198.18.0.0/15
  - 192.168.0.0/16

You must whitelist IP address range used for your enviroment (eg. kubernetes nodes IPs) manually in Signoz values chart.

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