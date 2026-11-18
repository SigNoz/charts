#!/bin/sh
# Pipes sample hook input through fence.sh for every mode and checks each
# verdict: exit 0 allows, exit 2 blocks.
#
# Usage: CLAUDE_PROJECT_DIR=<checkout> .claude/hooks/test-fences.sh
# shellcheck disable=SC2016  # the commands under test are literal strings
set -u

here=$(cd "$(dirname "$0")" && pwd)
fence="$here/fence.sh"
: "${CLAUDE_PROJECT_DIR:=$(cd "$here/../.." && pwd)}"
export CLAUDE_PROJECT_DIR
proj=$CLAUDE_PROJECT_DIR

passed=0
failed=0

# verdict <expected exit> <mode> <label> <hook json>
verdict() {
  printf '%s' "$4" | "$fence" "$2" >/dev/null 2>&1
  got=$?
  if [ "$got" -eq "$1" ]; then
    passed=$((passed + 1))
  else
    failed=$((failed + 1))
    printf 'FAIL %s: %s exited %s, expected %s\n' "$2" "$3" "$got" "$1"
  fi
}

bash_json() {
  jq -cn --arg c "$1" '{tool_name: "Bash", tool_input: {command: $c}}'
}

edit_json() {
  jq -cn --arg t "$1" --arg p "$2" '{tool_name: $t, tool_input: {file_path: $p}}'
}

allow() { verdict 0 "$1" "$2" "$(bash_json "$2")"; }
deny() { verdict 2 "$1" "$2" "$(bash_json "$2")"; }
allow_edit() { verdict 0 writer-edit "$1" "$(edit_json Write "$1")"; }
deny_edit() { verdict 2 writer-edit "$1" "$(edit_json Write "$1")"; }

# explorer-bash: allowed
allow explorer-bash 'git log -3'
allow explorer-bash 'git diff main -- charts/signoz/'
allow explorer-bash 'git log --oneline -S "signoz.fullname" -- charts/signoz/templates'
allow explorer-bash 'git blame -L 10,20 charts/signoz/templates/_helpers.tpl'
allow explorer-bash 'git show HEAD~1 --stat'
allow explorer-bash 'gh pr view 12 --comments'
allow explorer-bash 'gh issue list --state all --search clickhouse'
allow explorer-bash 'gh api repos/SigNoz/charts/pulls/963/comments'
allow explorer-bash 'gh api repos/{owner}/{repo}/pulls/963 --jq .title'
allow explorer-bash 'helm template release-name charts/signoz'
allow explorer-bash 'helm template release-name charts/signoz --set otelCollector.autoscaling.enabled=true'
allow explorer-bash 'wc -l charts/signoz/values.yaml'
allow explorer-bash 'ls charts/signoz/templates'
allow explorer-bash '.claude/hooks/render-compare.sh main signoz'
allow explorer-bash "$proj/.claude/hooks/render-compare.sh main signoz"

# explorer-bash: blocked
deny explorer-bash 'gh pr merge 963 --squash'
deny explorer-bash 'gh pr close 963'
deny explorer-bash 'gh issue edit 1 --add-label bug'
deny explorer-bash 'git diff > charts/signoz/values.yaml'
deny explorer-bash 'git log; rm -rf charts'
deny explorer-bash 'git log && git push origin main'
deny explorer-bash 'git log || git push origin main'
deny explorer-bash 'git log & rm -rf charts'
deny explorer-bash 'git log | tee charts/signoz/values.yaml'
deny explorer-bash 'git log
rm -rf charts'
deny explorer-bash 'git log $(rm -rf charts)'
deny explorer-bash 'git log `rm -rf charts`'
deny explorer-bash 'git log ${HOME}'
deny explorer-bash 'git log -p $IFS--output=charts/signoz/values.yaml'
deny explorer-bash 'git log -p {--output=charts/signoz/values.yaml,}'
deny explorer-bash 'git diff --output=charts/signoz/values.yaml'
deny explorer-bash 'git diff --outp=charts/signoz/values.yaml'
deny explorer-bash "git diff --'output'=charts/signoz/values.yaml"
deny explorer-bash 'git push origin main'
deny explorer-bash 'git checkout -- charts'
deny explorer-bash 'git -c core.pager=rm log'
deny explorer-bash 'helm template x charts/signoz --output-dir /tmp/x'
deny explorer-bash 'helm template x charts/signoz --output-dir=/tmp/x'
deny explorer-bash 'helm template x charts/signoz --post-renderer sh'
deny explorer-bash 'helm template x charts/signoz --dependency-update'
deny explorer-bash 'helm install x charts/signoz'
deny explorer-bash 'gh api -X DELETE repos/x/y'
deny explorer-bash 'gh api -XDELETE repos/x/y'
deny explorer-bash 'gh api -iX DELETE repos/x/y'
deny explorer-bash 'gh api --method=PATCH repos/x/y'
deny explorer-bash 'gh api repos/x/y/issues -f title=x'
deny explorer-bash 'gh api repos/x/y/issues -F title=x'
deny explorer-bash 'gh api repos/x/y/issues --raw-field title=x'
deny explorer-bash 'gh api repos/x/y/issues --input body.json'
deny explorer-bash 'ls *(e:rm:)'
deny explorer-bash 'env git log'
deny explorer-bash 'bash -c "git log"'
deny explorer-bash 'xargs rm'
deny explorer-bash 'sudo git log'
deny explorer-bash 'rm -rf charts'
deny explorer-bash '.claude/hooks/render-compare.sh main signoz --post-renderer sh'
deny explorer-bash '.claude/hooks/render-compare.sh --output=/tmp/x signoz'
deny explorer-bash '.claude/hooks/render-compare.sh main ../signoz'
deny explorer-bash ''
deny explorer-bash '   '

# guard-bash
allow guard-bash 'git diff --name-only'
allow guard-bash 'git diff main -- charts/signoz/'
allow guard-bash 'git log -3'
allow guard-bash 'git show HEAD:charts/signoz/templates/_helpers.tpl'
allow guard-bash 'helm template release-name charts/signoz'
allow guard-bash 'wc -l charts/signoz/templates/_helpers.tpl'
allow guard-bash 'ls charts/signoz/tests'
allow guard-bash '.claude/hooks/render-compare.sh main signoz'
allow guard-bash '.claude/hooks/render-compare.sh main signoz --set postgresql.enabled=true'
deny guard-bash 'git blame charts/signoz/values.yaml'
deny guard-bash 'gh pr view 12'
deny guard-bash 'gh api repos/SigNoz/charts/pulls/963/comments'
deny guard-bash 'git diff > charts/signoz/values.yaml'
deny guard-bash 'git stash'
deny guard-bash 'helm template x charts/signoz --output-dir /tmp/x'
deny guard-bash 'helm unittest charts/signoz'

# writer-bash
allow writer-bash "helm unittest charts/signoz --file 'tests/**/*_test.yaml'"
allow writer-bash "helm unittest charts/signoz -f 'tests/signoz/statefulset_test.yaml'"
allow writer-bash "helm unittest charts/signoz --file 'tests/**/*_test.yaml' --update-snapshot"
allow writer-bash "helm unittest charts/signoz -u --file 'tests/**/*_test.yaml'"
allow writer-bash 'ct lint --config ct.yaml --charts charts/signoz'
allow writer-bash 'ct lint --config=ct.yaml --charts=charts/signoz'
deny writer-bash 'helm unittest charts/signoz --output-file charts/signoz/values.yaml'
deny writer-bash 'helm unittest charts/signoz -o charts/signoz/values.yaml'
deny writer-bash 'helm unittest charts/signoz -uo charts/signoz/values.yaml'
deny writer-bash 'helm unittest charts/signoz --output-type JUnit'
deny writer-bash 'helm unittest charts/signoz -t JUnit'
deny writer-bash 'ct lint --config ct.yaml --additional-commands rm'
deny writer-bash 'ct lint --config charts/signoz/tests/ct.yaml --charts charts/signoz'
deny writer-bash 'ct install --config ct.yaml'
deny writer-bash 'helm template release-name charts/signoz'
deny writer-bash 'git log -3'
deny writer-bash 'ls charts'
deny writer-bash '.claude/hooks/render-compare.sh main signoz'
deny writer-bash "helm unittest charts/signoz --file 'tests/**/*_test.yaml'; git push origin main"

# writer-edit
allow_edit 'charts/signoz/tests/clickhouse/secret_test.yaml'
allow_edit "$proj/charts/signoz/tests/clickhouse/secret_test.yaml"
allow_edit 'charts/signoz/tests/values/postgres.yaml'
verdict 0 writer-edit 'Edit charts/k8s-infra/tests/otel-agent_debug_exporter_test.yaml' \
  "$(edit_json Edit charts/k8s-infra/tests/otel-agent_debug_exporter_test.yaml)"
deny_edit 'charts/signoz/tests/../values.yaml'
deny_edit 'charts/signoz/tests/x/../../templates/_helpers.tpl'
deny_edit '/elsewhere/charts/signoz/tests/a.yaml'
deny_edit "$proj/../elsewhere/charts/signoz/tests/a.yaml"
deny_edit 'charts/redpanda/tests/a.yaml'
deny_edit 'charts/zookeeper/tests/a.yaml'
deny_edit 'charts/REDPANDA/tests/a.yaml'
deny_edit 'charts/signoz/values.yaml'
deny_edit 'charts/signoz/templates/tests/a.yaml'
deny_edit 'charts/signoz/tests/a.yml'
deny_edit 'charts/signoz/tests/.yaml'
deny_edit 'charts/not-a-chart/tests/a.yaml'
deny_edit 'charts/signoz/charts/tests/a.yaml'
deny_edit 'tests/a.yaml'
deny_edit ''

# malformed or mismatched input
verdict 2 explorer-bash 'not json' 'not json'
verdict 2 explorer-bash 'no command' '{"tool_name":"Bash","tool_input":{}}'
verdict 2 explorer-bash 'non-string command' '{"tool_name":"Bash","tool_input":{"command":["git","log"]}}'
verdict 2 explorer-bash 'no tool name' '{"tool_input":{"command":"git log"}}'
verdict 2 explorer-bash 'Write in a Bash mode' "$(edit_json Write charts/signoz/tests/a_test.yaml)"
verdict 2 writer-edit 'Bash in the edit mode' "$(bash_json 'git log')"
verdict 2 writer-edit 'no file path' '{"tool_name":"Write","tool_input":{}}'
verdict 2 writer-edit 'NotebookEdit path' \
  '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"charts/signoz/tests/a.yaml"}}'
verdict 2 unknown-mode 'unknown mode' "$(bash_json 'git log')"
unset_rc=$(edit_json Write charts/signoz/tests/a_test.yaml |
  env -u CLAUDE_PROJECT_DIR "$fence" writer-edit >/dev/null 2>&1
  echo $?)
if [ "$unset_rc" -eq 2 ]; then
  passed=$((passed + 1))
else
  failed=$((failed + 1))
  printf 'FAIL writer-edit: unset CLAUDE_PROJECT_DIR exited %s, expected 2\n' "$unset_rc"
fi

printf 'fence tests: %s passed, %s failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
