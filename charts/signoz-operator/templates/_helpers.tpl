{{/*
Expand the name of the chart.
*/}}
{{- define "signoz-operator.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec). If the release name contains the chart name it is
used as the full name.
*/}}
{{- define "signoz-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Resource name with a suffix, truncated to stay within the 63-character limit.
Takes a dict with:
  - .suffix: the suffix to append (e.g. "leader-election")
  - .context: the root context
*/}}
{{- define "signoz-operator.resourceName" -}}
{{- $fullname := include "signoz-operator.fullname" .context }}
{{- $maxLen := sub 62 (len .suffix) | int }}
{{- if gt (len $fullname) $maxLen }}
{{- printf "%s-%s" (trunc $maxLen $fullname | trimSuffix "-") .suffix | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" $fullname .suffix | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
ServiceAccount name to use. When serviceAccount.enabled is false, the operator
binds to the pre-existing ServiceAccount named in serviceAccount.name.
*/}}
{{- define "signoz-operator.serviceAccountName" -}}
{{- if and (not .Values.serviceAccount.enabled) .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- include "signoz-operator.fullname" . }}
{{- end }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "signoz-operator.labels" -}}
app.kubernetes.io/name: {{ include "signoz-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
Selector labels. These must never change for an existing release: the
Deployment selector is immutable.
*/}}
{{- define "signoz-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "signoz-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Annotations for every CRD the chart installs.

CRDs live in templates/crds/ rather than the chart's crds/ directory so that
"helm upgrade" keeps them current. crds.keep restores the delete protection the
crds/ directory would otherwise have given for free.

Each CRD in templates/crds/ opens with the block below, keeping controller-gen's
own annotations, and closes with an "end" action:

  metadata:
    name: <plural>.resources.signoz.io
    annotations:
      controller-gen.kubebuilder.io/version: <version>
      [[- include "signoz-operator.crdAnnotations" . | nindent 4 ]]
    labels:
      [[- include "signoz-operator.crdLabels" . | nindent 4 ]]
*/}}
{{- define "signoz-operator.crdAnnotations" -}}
{{- $annotations := deepCopy (.Values.crds.annotations | default dict) -}}
{{- if .Values.crds.keep -}}
{{- $_ := set $annotations "helm.sh/resource-policy" "keep" -}}
{{- end -}}
{{- with $annotations }}
{{- toYaml . }}
{{- end -}}
{{- end }}

{{/*
Labels for every CRD the chart installs.
*/}}
{{- define "signoz-operator.crdLabels" -}}
{{- include "signoz-operator.labels" . }}
{{- with .Values.crds.labels }}
{{ toYaml . }}
{{- end -}}
{{- end }}
