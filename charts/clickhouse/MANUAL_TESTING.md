# Manual Testing Guide for Volume Permissions Fix (Issue #623)

## The Problem (Issue #623)

ClickHouse fails to start with persistent volumes due to permission denied errors:
```
filesystem error: in create_directories: Permission denied ["/var/lib/clickhouse/preprocessed_configs"]
```

**Root Cause**: Persistent volumes mount as `root:root` (0:0), but ClickHouse runs as user `101:101`. The container cannot create directories in the mounted volume.

## Solution Implemented

Added volume permissions init container that runs as root and fixes ownership before ClickHouse starts:
```yaml
initContainers:
- name: volume-permissions
  image: docker.io/bitnami/bitnami-shell:11-debian-11-r118
  command: ["/bin/bash", "-ec"]
  args:
    - |
      mkdir -p /var/lib/clickhouse
      chown -R 101:101 /var/lib/clickhouse
      find /var/lib/clickhouse -mindepth 1 -maxdepth 1 -not -name ".snapshot" -not -name "lost+found" | xargs -r chown -R 101:101
  securityContext:
    runAsUser: 0  # Root needed to change ownership
  volumeMounts:
    - name: data-volumeclaim-template
      mountPath: /var/lib/clickhouse
```

## Manual Testing Instructions

### Prerequisites
- Kubernetes cluster (minikube, kind, or cloud cluster)
- Helm 3.x installed
- kubectl configured

### Test 1: Reproduce the Issue (Failure Case)

```bash
# Install WITHOUT volume permissions (reproduces issue #623)
helm install test-fail . \
  --set volumePermissions.enabled=false \
  --set persistence.enabled=true

# Watch the failure
kubectl get pods -w
kubectl logs chi-test-fail-clickhouse-cluster-0-0-0 -f
```

**Expected Result**: ClickHouse pod fails with permission denied errors.

### Test 2: Verify the Fix (Success Case)

```bash
# Install WITH volume permissions (the fix)
helm install test-success . \
  --set volumePermissions.enabled=true \
  --set persistence.enabled=true

# Watch success
kubectl get pods -w
kubectl logs chi-test-success-clickhouse-cluster-0-0-0 -f
```

**Expected Result**: ClickHouse starts successfully!

### Test 3: Verify Init Container Runs

```bash
# Check init container is present in pod spec
kubectl describe pod chi-test-success-clickhouse-cluster-0-0-0

# Check init container logs
kubectl logs chi-test-success-clickhouse-cluster-0-0-0 -c volume-permissions
```

**Expected Output**:
```
+ mkdir -p /var/lib/clickhouse
+ chown -R 101:101 /var/lib/clickhouse
+ find /var/lib/clickhouse -mindepth 1 -maxdepth 1 -not -name .snapshot -not -name lost+found
+ xargs -r chown -R 101:101
```

### Test 4: Existing Claims (Real Issue #623 Scenario)

This reproduces the exact scenario from the GitHub issue:

```bash
# Create existing PVCs first
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: signoz-clickhouse
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 5Gi
EOF

# Install with existing claim (issue #623 exact scenario)
helm install test-existing . \
  --set volumePermissions.enabled=true \
  --set persistence.enabled=true \
  --set persistence.existingClaim=signoz-clickhouse
```

## Verification Commands

### Check ClickHouse is working
```bash
# Port forward to ClickHouse
kubectl port-forward svc/test-success-clickhouse 8123:8123

# Test ClickHouse HTTP interface
curl http://localhost:8123/ping
# Should return "Ok."
```

### Check file permissions inside pod
```bash
# Exec into ClickHouse pod
kubectl exec -it chi-test-success-clickhouse-cluster-0-0-0 -- /bin/bash

# Check ownership of directories
ls -la /var/lib/clickhouse/
# Should show: drwxr-xr-x 101 101 ... (ClickHouse user owns the directory)

# Verify ClickHouse can create files
touch /var/lib/clickhouse/test-file
# Should work without permission errors
```

## Expected Results Summary

| Test Case | Settings | Expected Result |
|-----------|----------|-----------------|
| **Test 1** | `volumePermissions.enabled=false` | ❌ ClickHouse fails with permission denied |
| **Test 2** | `volumePermissions.enabled=true` | ✅ ClickHouse starts successfully |
| **Test 3** | Check init containers | ✅ volume-permissions init container runs and fixes ownership |
| **Test 4** | With existing PVCs | ✅ Works with existing claims (resolves issue #623) |

## Key Points for Testing

1. **CRITICAL**: Use `--set volumePermissions.enabled=true` (NOT `--set clickhouse.volumePermissions.enabled=true`)

2. **Template Validation**: You can verify the fix renders correctly:
   ```bash
   helm template test . \
     --set volumePermissions.enabled=true \
     --set persistence.enabled=true | grep -A 20 "volume-permissions"
   ```

3. **Init Container Order**: The volume-permissions init container runs BEFORE the ClickHouse container starts.

4. **Security Context**: The init container runs as `runAsUser: 0` (root) to change ownership, while ClickHouse runs as user `101:101`.

## Troubleshooting

### Common Issues:
- **Init container fails**: Check if security policies (PSP/PSA) allow `runAsUser: 0`
- **Image pull fails**: Ensure `bitnami/bitnami-shell:11-debian-11-r118` is accessible
- **Still permission errors**: Check that `volumePermissions.enabled=true` is correctly set

### Debug Commands:
```bash
# Check pod events
kubectl describe pod <clickhouse-pod-name>

# Check all init container statuses
kubectl get pod <clickhouse-pod-name> -o jsonpath='{.status.initContainerStatuses}'

# Check volume mounts
kubectl get pod <clickhouse-pod-name> -o yaml | grep -A 10 volumeMounts
```

## Success Criteria

✅ **Issue #623 is RESOLVED when**:
1. `volumePermissions.enabled=true` allows ClickHouse to start successfully
2. No more "Permission denied" errors for `/var/lib/clickhouse/preprocessed_configs`
3. Init container successfully runs `chown -R 101:101 /var/lib/clickhouse`
4. ClickHouse can create directories and files in persistent volumes
5. Solution works with both new PVCs and existing claims