{{/*
telemetryStoreMigrator.validate: the telemetry store migrator values rules.
Emits: one line per rule the values break, holding that rule's message; nothing when every rule
holds. validate.yaml gathers these lines with every other component's and fails once.
*/}}
{{- define "telemetryStoreMigrator.validate" -}}
{{- /*
Values keys that no longer do anything at these paths (removed, or moved to a new path).
Fail the render instead of ignoring them, so an old values file is caught at `helm upgrade` time rather than silently misapplied.
*/ -}}
{{- if dig "upgradeHelmHooks" false (.Values.telemetryStoreMigrator | default dict) }}
{{ "`telemetryStoreMigrator.upgradeHelmHooks` has been removed: delete it, since the migrator now runs as a Job named with the release revision on every install and upgrade; set `telemetryStoreMigrator.enabled: false` to skip it." }}
{{- end }}
{{- /*
The migrator Job is named `telemetryStoreMigrator.name` plus `-<release revision>`, and its pods carry that name in their `job-name` label, which must stay within 63 characters.
The budget reserves six characters for the suffix (up to five digits) instead of reading `.Release.Revision`, so a name that renders today does not start failing on a later upgrade.
*/ -}}
{{- if .Values.telemetryStoreMigrator.enabled }}
{{- $migratorName := include "telemetryStoreMigrator.fullname" . }}
{{- if gt (len $migratorName) 57 }}
{{ printf "`telemetryStoreMigrator.name` %q is %d characters; the migrator Job name appends `-<release revision>` and must stay within 63 characters, so the name can have at most 57: shorten it." $migratorName (len $migratorName) }}
{{- end }}
{{- end }}
{{- end -}}
