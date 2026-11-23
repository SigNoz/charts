{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgresql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name for SigNoz.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Standard labels for postgres resources
*/}}
{{- define "postgresql.labels" -}}
helm.sh/chart:  {{ include "postgresql.chart" . }}
{{ include "postgresql.selectorLabels" . }}
{{- $version := default "" .Values.postgresql.image.tag | toString | splitList "@" | first | trunc 63 }}
{{- if $version }}
app.kubernetes.io/version: {{ $version | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels (used for StatefulSet selector and Pod template)
*/}}
{{- define "postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Base name for the chart
*/}}
{{- define "postgresql.name" -}}
{{- default "postgres" .Values.postgresql.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
ServiceAccount name
*/}}
{{- define "postgresql.serviceAccountName" -}}
{{- if .Values.postgresql.serviceAccount.create -}}
    {{ default (include "postgresql.fullname" .) .Values.postgresql.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.postgresql.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "postgresql.imagePullSecrets" -}}
{{- if .Values.postgresql.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- range .Values.postgresql.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}  
{{- end }}

{{/*
Return the proper signoz image name
*/}}
{{- define "postgresql.image" -}}
{{- $registryName := .Values.postgresql.image.registry -}}
{{- $repositoryName := .Values.postgresql.image.repository -}}
{{- $tag := default "15.0.0" .Values.postgresql.image.tag | toString -}}
{{- if $registryName -}}
    {{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
persistence.subPath without leading or trailing slashes.
*/}}
{{- define "postgresql.subPath" -}}
{{- trimAll "/" (default "" .Values.postgresql.persistence.subPath | toString) -}}
{{- end -}}

{{/*
"true" when persistence is on and the claim is mounted at /var/lib/postgresql, the parent of the image's data volume.
*/}}
{{- define "postgresql.defaultLayout" -}}
{{- if and .Values.postgresql.persistence.enabled (eq (clean (default "" .Values.postgresql.persistence.mountPath | toString)) "/var/lib/postgresql") -}}
true
{{- end -}}
{{- end -}}

{{/*
"true" when the claim's data folder is also mounted at the image's data volume, /var/lib/postgresql/data.
*/}}
{{- define "postgresql.dataMount" -}}
{{- $userMount := false -}}
{{- range .Values.postgresql.additionalVolumeMounts -}}
{{- if eq (clean (default "" .mountPath | toString)) "/var/lib/postgresql/data" -}}
{{- $userMount = true -}}
{{- end -}}
{{- end -}}
{{- $official := has (toString .Values.postgresql.image.repository) (list "postgres" "docker.io/library/postgres") -}}
{{- $major := regexFind "^(pg)?[0-9]+" (default "15.0.0" .Values.postgresql.image.tag | toString) | trimPrefix "pg" | atoi -}}
{{- if and (include "postgresql.defaultLayout" .) (not $userMount) (not (and $official (ge $major 18))) -}}
true
{{- end -}}
{{- end -}}

{{/*
Path of the dump the loader reads, under the claim as the postgres container mounts it.
*/}}
{{- define "postgresql.restoreFile" -}}
{{- printf "%s/backups/pre-upgrade.sql" (clean (default "" .Values.postgresql.persistence.mountPath | toString) | trimSuffix "/") -}}
{{- end -}}

{{/*
Name of the ConfigMap that holds the loader script.
*/}}
{{- define "postgresql.restoreConfigMapName" -}}
{{- printf "%s-restore" (include "postgresql.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
persistence.existingClaim through tpl, in the context the postgresql 0.0.2 subchart rendered it in, so a value written for that chart names the same claim. Values also carries postgresql for the postgresql.* helpers.
*/}}
{{- define "postgresql.existingClaim" -}}
{{- $values := deepCopy .Values.postgresql -}}
{{- $_ := set $values "global" .Values.global -}}
{{- $_ := set $values "postgresql" .Values.postgresql -}}
{{- $chart := dict "Name" "postgresql" "Version" "0.0.2" "AppVersion" "15.0.0" -}}
{{- tpl .Values.postgresql.persistence.existingClaim (dict "Values" $values "Chart" $chart "Release" .Release "Capabilities" .Capabilities "Template" .Template) -}}
{{- end -}}

{{/*
"true" when the loader script is mounted into /docker-entrypoint-initdb.d.
*/}}
{{- define "postgresql.restoreLoader" -}}
{{- $userMount := false -}}
{{- range .Values.postgresql.additionalVolumeMounts -}}
{{- if eq (clean (default "" .mountPath | toString)) "/docker-entrypoint-initdb.d" -}}
{{- $userMount = true -}}
{{- end -}}
{{- end -}}
{{- if and .Values.postgresql.persistence.enabled (not $userMount) -}}
true
{{- end -}}
{{- end -}}

{{/*
Data directory of the postgres container: an extraEnv PGDATA replaces persistence.dataDir, as in postgresql.env.
*/}}
{{- define "postgresql.pgdata" -}}
{{- $pgdata := .Values.postgresql.persistence.dataDir -}}
{{- range .Values.postgresql.extraEnv -}}
{{- if and (eq (upper (toString .name)) "PGDATA") .value -}}
{{- $pgdata = .value -}}
{{- end -}}
{{- end -}}
{{- clean (default "" $pgdata | toString) -}}
{{- end -}}

{{/*
persistence.mountPath as the upgrade backup Job sees the claim at /claim.
*/}}
{{- define "postgresql.claimRoot" -}}
{{- printf "/claim/%s" (include "postgresql.subPath" .) | trimSuffix "/" -}}
{{- end -}}

{{/*
Data directory as the upgrade backup Job sees the claim at /claim; empty when it is not under persistence.mountPath.
*/}}
{{- define "postgresql.claimDataDir" -}}
{{- $mount := clean (default "" .Values.postgresql.persistence.mountPath | toString) -}}
{{- $pgdata := include "postgresql.pgdata" . -}}
{{- $claim := include "postgresql.claimRoot" . -}}
{{- if eq $pgdata $mount -}}
{{- $claim -}}
{{- else if hasPrefix (printf "%s/" $mount) $pgdata -}}
{{- printf "%s/%s" $claim (trimPrefix (printf "%s/" $mount) $pgdata) -}}
{{- end -}}
{{- end -}}

{{/*
"true" when an additionalVolumeMounts entry is mounted at the data directory or a folder above it.
*/}}
{{- define "postgresql.userDataMount" -}}
{{- $pgdata := include "postgresql.pgdata" . -}}
{{- $userMount := false -}}
{{- range .Values.postgresql.additionalVolumeMounts -}}
{{- $path := clean (default "" .mountPath | toString) -}}
{{- if or (eq $path $pgdata) (hasPrefix (printf "%s/" $path) $pgdata) -}}
{{- $userMount = true -}}
{{- end -}}
{{- end -}}
{{- if $userMount -}}
true
{{- end -}}
{{- end -}}

{{/*
"true" when an upgrade runs the backup Job.
*/}}
{{- define "postgresql.upgradeBackup" -}}
{{- if and .Values.postgresql.upgradeBackupHook.enabled (include "postgresql.defaultLayout" .) (include "postgresql.claimDataDir" .) (not (include "postgresql.userDataMount" .)) (not (has "ReadWriteOncePod" .Values.postgresql.persistence.accessModes)) (ne (int .Values.postgresql.replicaCount) 0) -}}
true
{{- end -}}
{{- end -}}

{{/*
Auth secret name
*/}}
{{- define "postgresql.authSecretName" -}}
{{ printf "%s-auth" (include "postgresql.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Postgres ENV
*/}}
{{- define "postgresql.env" -}}
{{- $env := dict -}}
{{- $_ := set $env "POSTGRESQL_PORT_NUMBER" (.Values.postgresql.service.port | toString) -}}
{{- $_ := set $env "POSTGRESQL_VOLUME_DIR" .Values.postgresql.persistence.mountPath -}}
{{- $_ := set $env "PGDATA" .Values.postgresql.persistence.dataDir -}}

{{- $_ := set $env "POSTGRES_USER" .Values.postgresql.auth.username -}}
{{- if .Values.postgresql.auth.existingSecret }}
  {{- $secretCfg := default dict .Values.postgresql.auth.secretKeys -}}
  {{- $secretKey := default "password" (get $secretCfg "userPasswordKey") -}}
  {{- $_ := set $env "POSTGRES_PASSWORD" (dict "valueFrom" (dict "secretKeyRef" (dict "name" .Values.postgresql.auth.existingSecret "key" $secretKey ))) -}}
{{- else }}
  {{- $_ := set $env "POSTGRES_PASSWORD" (dict "valueFrom" (dict "secretKeyRef" (dict "name" (include "postgresql.authSecretName" .) "key" "password"))) -}}
{{- end }}
{{- if .Values.postgresql.auth.database }}
  {{- $_ := set $env "POSTGRES_DB" .Values.postgresql.auth.database -}}
{{- end }}
{{- if .Values.postgresql.extraEnv }}
  {{- range .Values.postgresql.extraEnv }}
    {{- $_ := set $env .name .value -}}
  {{- end }}
{{- end }}


{{- template "postgresql.renderEnv" $env -}}
{{- end}}

{{/*
Function to render environment variables 
*/}}
{{- define "postgresql.renderEnv" -}}
{{- $dict := . -}}
{{- $processedKeys := dict -}}
{{- range keys . | sortAlpha | reverse }}
{{- $val := pluck . $dict | first -}}
{{- $key := upper . -}}
{{- if not (hasKey $processedKeys $key) }}
{{- $processedKeys = merge $processedKeys (dict $key true) -}}
{{- $valueType := printf "%T" $val -}}
{{- if eq $valueType "map[string]interface {}" }}
- name: {{ $key }}
{{ toYaml $val | indent 2 -}}
{{- else if eq $valueType "string" }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- else }}
- name: {{ $key }}
  value: {{ $val | quote}}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "postgresql.service.ifClusterIP" -}}
{{- if (eq . "ClusterIP") }}
nodePort: null
{{- end }}
{{- end }}
