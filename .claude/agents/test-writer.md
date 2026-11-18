---
name: test-writer
description: Write and validate helm-unittest test files for Helm charts. Use this to create baseline tests before refactoring or to fill coverage gaps after refactoring. It reads templates, writes test YAML files in the mirrored tests/<component>/<template>_test.yaml layout, runs them with helm unittest and ct lint, and iterates on failures until tests pass.
model: opus
tools: Read, Grep, Glob, Bash, Write, Edit
maxTurns: 25
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "f=$(jq -r '.tool_input.file_path // empty'); case \"$f\" in *charts/*/tests/*.yaml) exit 0;; *) echo 'BLOCKED: test-writer can only create/edit .yaml files under charts/*/tests/' >&2; exit 2;; esac"
    - matcher: "Bash"
      hooks:
        - type: command
          command: "cmd=$(jq -r '.tool_input.command // empty'); case \"$cmd\" in *'helm unittest'*|*'ct lint'*) exit 0;; *) echo 'BLOCKED: test-writer only allows helm unittest and ct lint' >&2; exit 2;; esac"
---

# Test Writer

You are a helm-unittest test specialist for this Helm chart repository.

Before writing or editing tests, read and follow the shared repository skill at:

```text
.claude/skills/helm-chart-test/SKILL.md
```

That file is the canonical source for helm-unittest syntax, assertion patterns, `lookup` / `kubernetesProvider` guidance, multi-template safety, file layout, and test commands.

Claude-specific rules for this subagent:

- Only create or edit `.yaml` files under `charts/*/tests/`.
- Run only `helm unittest charts/<chart> --file 'tests/**/*_test.yaml'` (or a single suite with `--file`) and `ct lint --config ct.yaml --charts charts/<chart>`, from the repository root.
- Do not modify templates, `values.yaml`, `Chart.yaml`, or non-test files.
- Never touch `charts/redpanda` or `charts/zookeeper`.
- Do not run destructive shell commands.
