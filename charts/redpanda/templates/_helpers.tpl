{{/*
Licensed to the Apache Software Foundation (ASF) under one or more
contributor license agreements.  See the NOTICE file distributed with
this work for additional information regarding copyright ownership.
The ASF licenses this file to You under the Apache License, Version 2.0
(the "License"); you may not use this file except in compliance with
the License.  You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}
{{/*
Expand the name of the chart.
*/}}
{{- define "redpanda.name" -}}
{{- get ((include "redpanda.Name" (dict "a" (list .))) | fromJson) "r" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "redpanda.fullname" -}}
{{- get ((include "redpanda.Fullname" (dict "a" (list .))) | fromJson) "r" }}
{{- end -}}

{{/*
Create a default service name
*/}}
{{- define "redpanda.servicename" -}}
{{- get ((include "redpanda.ServiceName" (dict "a" (list .))) | fromJson) "r" }}
{{- end -}}

{{/*
full helm labels + common labels
*/}}
{{- define "full.labels" -}}
{{- (get ((include "redpanda.FullLabels" (dict "a" (list .))) | fromJson) "r") | toYaml }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "redpanda.chart" -}}
{{- get ((include "redpanda.Chart" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "redpanda.serviceAccountName" -}}
{{- get ((include "redpanda.ServiceAccountName" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Use AppVersion if image.tag is not set
*/}}
{{- define "redpanda.tag" -}}
{{- get ((include "redpanda.Tag" (dict "a" (list .))) | fromJson) "r" }}
{{- end -}}

{{/* Generate internal fqdn */}}
{{- define "redpanda.internal.domain" -}}
{{- get ((include "redpanda.InternalDomain" (dict "a" (list .))) | fromJson) "r" }}
{{- end -}}

{{/* ConfigMap variables */}}
{{- define "admin-internal-tls-enabled" -}}
{{- toJson (dict "bool" (get ((include "redpanda.InternalTLS.IsEnabled" (dict "a" (list .Values.listeners.admin.tls .Values.tls))) | fromJson) "r")) -}}
{{- end -}}

{{- define "kafka-internal-tls-enabled" -}}
{{- $listener := .Values.listeners.kafka -}}
{{- toJson (dict "bool" (and (dig "tls" "enabled" .Values.tls.enabled $listener) (not (empty (dig "tls" "cert" "" $listener))))) -}}
{{- end -}}

{{- define "kafka-external-tls-cert" -}}
{{- dig "tls" "cert" .Values.listeners.kafka.tls.cert .listener -}}
{{- end -}}

{{- define "http-internal-tls-enabled" -}}
{{- $listener := .Values.listeners.http -}}
{{- toJson (dict "bool" (and (dig "tls" "enabled" .Values.tls.enabled $listener) (not (empty (dig "tls" "cert" "" $listener))))) -}}
{{- end -}}

{{- define "schemaRegistry-internal-tls-enabled" -}}
{{- $listener := .Values.listeners.schemaRegistry -}}
{{- toJson (dict "bool" (and (dig "tls" "enabled" .Values.tls.enabled $listener) (not (empty (dig "tls" "cert" "" $listener))))) -}}
{{- end -}}

{{- define "tls-enabled" -}}
{{- $tlsenabled := get ((include "redpanda.TLSEnabled" (dict "a" (list .))) | fromJson) "r" }}
{{- toJson (dict "bool" $tlsenabled) -}}
{{- end -}}

{{- define "sasl-enabled" -}}
{{- toJson (dict "bool" (dig "enabled" false .Values.auth.sasl)) -}}
{{- end -}}

{{- define "admin-api-urls" -}}
{{ printf "${SERVICE_NAME}.%s" (include "redpanda.internal.domain" .) }}:{{.Values.listeners.admin.port }}
{{- end -}}

{{- define "admin-api-service-url" -}}
{{ include "redpanda.internal.domain" .}}:{{.Values.listeners.admin.port }}
{{- end -}}

{{- define "sasl-mechanism" -}}
{{- dig "sasl" "mechanism" "SCRAM-SHA-512" .Values.auth -}}
{{- end -}}

{{- define "fail-on-insecure-sasl-logging" -}}
{{- if (include "sasl-enabled" .|fromJson).bool -}}
  {{- $check := list
      (include "redpanda-atleast-23-1-1" .|fromJson).bool
      (include "redpanda-22-3-atleast-22-3-13" .|fromJson).bool
      (include "redpanda-22-2-atleast-22-2-10" .|fromJson).bool
  -}}
  {{- if not (mustHas true $check) -}}
    {{- fail "SASL is enabled and the redpanda version specified leaks secrets to the logs. Please choose a newer version of redpanda." -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "fail-on-unsupported-helm-version" -}}
  {{- $helmVer := (fromYaml (toYaml .Capabilities.HelmVersion)).version -}}
  {{- if semverCompare "<3.8.0-0" $helmVer -}}
    {{- fail (printf "helm version %s is not supported. Please use helm version v3.8.0 or newer." $helmVer) -}}
  {{- end -}}
{{- end -}}

{{- define "redpanda-atleast-22-2-0" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_22_2_0" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}
{{- define "redpanda-atleast-22-3-0" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_22_3_0" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}
{{- define "redpanda-atleast-23-1-1" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_23_1_1" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}
{{- define "redpanda-atleast-23-1-2" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_23_1_2" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}
{{- define "redpanda-22-3-atleast-22-3-13" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_22_3_atleast_22_3_13" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}
{{- define "redpanda-22-2-atleast-22-2-10" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_22_2_atleast_22_2_10" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}
{{- define "redpanda-atleast-23-2-1" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_23_2_1" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}
{{- define "redpanda-atleast-23-3-0" -}}
{{- toJson (dict "bool" (get ((include "redpanda.RedpandaAtLeast_23_3_0" (dict "a" (list .))) | fromJson) "r")) }}
{{- end -}}

{{- define "redpanda-22-2-x-without-sasl" -}}
{{- $result :=  (include "redpanda-atleast-22-3-0" . | fromJson).bool -}}
{{- if or (include "sasl-enabled" . | fromJson).bool .Values.listeners.kafka.authenticationMethod -}}
{{-   $result := false -}}
{{- end -}}
{{- toJson (dict "bool" $result) -}}
{{- end -}}

{{- define "pod-security-context" -}}
{{- get ((include "redpanda.PodSecurityContext" (dict "a" (list .))) | fromJson) "r" | toYaml }}
{{- end -}}

{{- define "container-security-context" -}}
{{- get ((include "redpanda.ContainerSecurityContext" (dict "a" (list .))) | fromJson) "r" | toYaml }}
{{- end -}}

{{- define "admin-tls-curl-flags" -}}
  {{- $result := "" -}}
  {{- if (include "admin-internal-tls-enabled" . | fromJson).bool -}}
    {{- $path := (printf "/etc/tls/certs/%s" .Values.listeners.admin.tls.cert) -}}
    {{- $result = (printf "--cacert %s/tls.crt" $path) -}}
    {{- if .Values.listeners.admin.tls.requireClientAuth -}}
      {{- $result = (printf "--cacert %s/ca.crt --cert %s/tls.crt --key %s/tls.key" $path $path $path) -}}
    {{- end -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}

{{- define "admin-http-protocol" -}}
  {{- $result := "http" -}}
  {{- if (include "admin-internal-tls-enabled" . | fromJson).bool -}}
    {{- $result = "https" -}}
  {{- end -}}
  {{- $result -}}
{{- end -}}

{{- /*
advertised-port returns either the only advertised port if only one is specified,
or the port specified for this pod ordinal when there is a full list provided.

This will return a string int or panic if there is more than one port provided,
but not enough ports for the number of replicas requested.
*/ -}}
{{- define "advertised-port" -}}
  {{- $port := dig "port" .listenerVals.port .externalVals -}}
  {{- if .externalVals.advertisedPorts -}}
    {{- if eq (len .externalVals.advertisedPorts) 1 -}}
      {{- $port = mustFirst .externalVals.advertisedPorts -}}
    {{- else -}}
      {{- $port = index .externalVals.advertisedPorts .replicaIndex -}}
    {{- end -}}
  {{- end -}}
  {{ $port }}
{{- end -}}

{{- /*
advertised-host returns a json string with the data needed for configuring the advertised listener
*/ -}}
{{- define "advertised-host" -}}
  {{- $host := dict "name" .externalName "address" .externalAdvertiseAddress "port" .port -}}
  {{- if .values.external.addresses -}}
    {{- $address := "" -}}
    {{- if gt (len .values.external.addresses) 1 -}}
      {{- $address = (index .values.external.addresses .replicaIndex) -}}
    {{- else -}}
      {{- $address = (index .values.external.addresses 0) -}}
    {{- end -}}
    {{- if ( .values.external.domain | default "" ) }}
      {{- $host = dict "name" .externalName "address" (printf "%s.%s" $address .values.external.domain) "port" .port -}}
    {{- else -}}
      {{- $host = dict "name" .externalName  "address" $address "port" .port -}}
    {{- end -}}
  {{- end -}}
  {{- toJson $host -}}
{{- end -}}

{{- define "is-licensed" -}}
{{- toJson (dict "bool" (or (not (empty (include "enterprise-license" . ))) (not (empty (include "enterprise-secret" . ))))) -}}
{{- end -}}

{{- define "seed-server-list" -}}
  {{- $brokers := list -}}
  {{- range $ordinal := until (.Values.statefulset.replicas | int) -}}
    {{- $brokers = append $brokers (printf "%s-%d.%s"
        (include "redpanda.fullname" $)
        $ordinal
        (include "redpanda.internal.domain" $))
    -}}
  {{- end -}}
  {{- toJson $brokers -}}
{{- end -}}

{{/*
return license checks deprecated values if current values is empty
*/}}
{{- define "enterprise-license" -}}
{{- if dig "license" dict .Values.enterprise -}}
  {{- .Values.enterprise.license -}}
{{- else -}}
  {{- .Values.license_key -}}
{{- end -}}
{{- end -}}

{{/*
return licenseSecretRef checks deprecated values entry if current values empty
*/}}
{{- define "enterprise-secret" -}}
{{- if ( dig "licenseSecretRef" dict .Values.enterprise ) -}}
  {{- .Values.enterprise.licenseSecretRef -}}
{{- else if not (empty .Values.license_secret_ref ) -}}
  {{- .Values.license_secret_ref -}}
{{- end -}}
{{- end -}}

{{/*
return licenseSecretRef.name checks deprecated values entry if current values empty
*/}}
{{- define "enterprise-secret-name" -}}
{{- if ( dig "licenseSecretRef" dict .Values.enterprise ) -}}
  {{- dig "name" "" .Values.enterprise.licenseSecretRef -}}
{{- else if not (empty .Values.license_secret_ref ) -}}
  {{- dig "secret_name" "" .Values.license_secret_ref -}}
{{- end -}}
{{- end -}}

{{/*
return licenseSecretRef.key checks deprecated values entry if current values empty
*/}}
{{- define "enterprise-secret-key" -}}
{{- if ( dig "licenseSecretRef" dict .Values.enterprise ) -}}
  {{- dig "key" "" .Values.enterprise.licenseSecretRef -}}
{{- else if not (empty .Values.license_secret_ref ) -}}
  {{- dig "secret_key" "" .Values.license_secret_ref -}}
{{- end -}}
{{- end -}}

{{/* mounts that are common to all containers */}}
{{- define "common-mounts" -}}
{{- $mounts := get ((include "redpanda.CommonMounts" (dict "a" (list .))) | fromJson) "r" }}
{{- if $mounts -}}
{{- toYaml $mounts -}}
{{- end -}}
{{- end -}}

{{/* mounts that are common to most containers */}}
{{- define "default-mounts" -}}
{{- $mounts := get ((include "redpanda.DefaultMounts" (dict "a" (list .))) | fromJson) "r" }}
{{- if $mounts -}}
{{- toYaml $mounts -}}
{{- end -}}
{{- end -}}

{{/* volumes that are common to all pods */}}
{{- define "common-volumes" -}}
{{- $volumes := get ((include "redpanda.CommonVolumes" (dict "a" (list .))) | fromJson) "r" }}
{{- if $volumes -}}
{{- toYaml $volumes -}}
{{- end -}}
{{- end -}}

{{/* the default set of volumes for most pods, except the sts pod */}}
{{- define "default-volumes" -}}
{{- $volumes := get ((include "redpanda.DefaultVolumes" (dict "a" (list .))) | fromJson) "r" }}
{{- if $volumes -}}
{{- toYaml $volumes -}}
{{- end -}}
{{- end -}}

{{/* support legacy storage.tieredConfig */}}
{{- define "storage-tiered-config" -}}
{{- $cfg := get ((include "redpanda.StorageTieredConfig" (dict "a" (list .))) | fromJson) "r" }}
{{- if $cfg -}}
{{- toYaml $cfg -}}
{{- end -}}
{{- end -}}

{{/*
  rpk sasl environment variables

  this will return a string with the correct environment variables to use for SASL based on the
  version of the redpada container being used
*/}}
{{- define "rpk-sasl-environment-variables" -}}
{{- if (include "redpanda-atleast-23-2-1" . | fromJson).bool -}}
RPK_USER RPK_PASS RPK_SASL_MECHANISM
{{- else -}}
REDPANDA_SASL_USERNAME REDPANDA_SASL_PASSWORD REDPANDA_SASL_MECHANISM
{{- end -}}
{{- end -}}

{{- define "curl-options" -}}
{{- print " -svm3 --fail --retry \"120\" --retry-max-time \"120\" --retry-all-errors -o - -w \"\\nstatus=%{http_code} %{redirect_url} size=%{size_download} time=%{time_total} content-type=\\\"%{content_type}\\\"\\n\" "}}
{{- end -}}

{{- define "advertised-address-template" -}}
  {{- $prefixTemplate := dig "prefixTemplate" "" .externalListener -}}
  {{- if empty $prefixTemplate -}}
    {{- $prefixTemplate = dig "prefixTemplate" "" .externalVals -}}
  {{- end -}}
  {{ quote $prefixTemplate }}
{{- end -}}

{{/* check if client auth is enabled for any of the listeners */}}
{{- define "client-auth-required" -}}
{{- $requireClientAuth := get ((include "redpanda.ClientAuthRequired" (dict "a" (list .))) | fromJson) "r" }}
{{- toJson (dict "bool" $requireClientAuth) -}}
{{- end -}}
