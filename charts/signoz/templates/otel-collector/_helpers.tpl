{{/*
The collector's name: <signoz fullname>-<otelCollector.name>.
*/}}
{{- define "otelCollector.fullname" -}}
{{- printf "%s-%s" (include "signoz.fullname" .) .Values.otelCollector.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The collector's selector labels.
*/}}
{{- define "otelCollector.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ default "otel-collector" .Values.otelCollector.name }}
{{- end -}}

{{/*
The collector's common labels, as text: the ConfigMap's checksum/config hashes the text they render.
*/}}
{{- define "otelCollector.labels" -}}
{{- include "signoz.lib.labels" (dict "chart" (include "signoz.chart" .) "selectorLabels" (include "otelCollector.selectorLabels" .) "version" .Chart.AppVersion "managedBy" .Release.Service) -}}
{{- end -}}

{{/*
The ServiceAccount the collector runs as.
*/}}
{{- define "otelCollector.serviceAccountName" -}}
{{- include "signoz.lib.serviceAccountName" (dict "serviceAccount" .Values.otelCollector.serviceAccount "fullname" (include "otelCollector.fullname" .)) -}}
{{- end -}}

{{/*
The collector's own environment variables, after the ClickHouse and pod identity lists.
*/}}
{{- define "otelCollector.chartEnv" }}
- name: LOW_CARDINAL_EXCEPTION_GROUPING
  value: {{ default "false" .Values.otelCollector.lowCardinalityExceptionGrouping | quote }}
{{- end }}

{{/*
The collector's ClusterRole name: otelCollector.clusterRole.name, else <fullname>-<release namespace>, unique per namespace.
*/}}
{{- define "otelCollector.clusterRoleName" -}}
{{- default (printf "%s-%s" (include "otelCollector.fullname" .) (include "signoz.namespace" .)) .Values.otelCollector.clusterRole.name -}}
{{- end -}}

{{/*
The collector's ClusterRoleBinding name: otelCollector.clusterRole.clusterRoleBinding.name, else <fullname>-<release namespace>.
*/}}
{{- define "otelCollector.clusterRoleBindingName" -}}
{{- default (printf "%s-%s" (include "otelCollector.fullname" .) (include "signoz.namespace" .)) .Values.otelCollector.clusterRole.clusterRoleBinding.name -}}
{{- end -}}
