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
{{- define "connectors.name" -}}
{{- get ((include "connectors.Name" (dict "a" (list .))) | fromJson) "r" }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "connectors.fullname" }}
{{- get ((include "connectors.Fullname" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
full helm labels + common labels
*/}}
{{- define "full.labels" -}}
{{- (get ((include "connectors.FullLabels" (dict "a" (list .))) | fromJson) "r") | toYaml }}
{{- end -}}

{{/*
pod labels merged with common labels
*/}}
{{- define "connectors-pod-labels" -}}
{{- (get ((include "connectors.PodLabels" (dict "a" (list .))) | fromJson) "r") | toYaml }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "connectors.chart" -}}
{{- get ((include "connectors.Chart" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Get the version of redpanda being used as an image
*/}}
{{- define "connectors.semver" -}}
{{- get ((include "connectors.Tag" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "connectors.serviceAccountName" -}}
{{- get ((include "connectors.ServiceAccountName" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Create the name of the service to use
*/}}
{{- define "connectors.serviceName" -}}
{{- get ((include "connectors.ServiceName" (dict "a" (list .))) | fromJson) "r" }}
{{- end }}

{{/*
Use AppVersion if image.tag is not set
*/}}
{{- define "connectors.tag" -}}
{{- get ((include "connectors.Tag" (dict "a" (list .))) | fromJson) "r" }}
{{- end -}}
