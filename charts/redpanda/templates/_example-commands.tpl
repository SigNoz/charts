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
Any rpk command that's given to the user in NOTES.txt must be defined in this template file
and tested in a test.
*/}}

{{/* tested in tests/test-kafka-sasl-status.yaml */}}
{{- define "rpk-acl-user-create" -}}
{{- $cmd := (get ((include "redpanda.RpkACLUserCreate" (dict "a" (list .))) | fromJson) "r") }}
{{- $cmd }}
{{- end -}}

{{/* tested in tests/test-kafka-sasl-status.yaml */}}
{{- define "rpk-acl-create" -}}
{{- $cmd := (get ((include "redpanda.RpkACLCreate" (dict "a" (list .))) | fromJson) "r") }}
{{- $cmd }}
{{- end -}}

{{/* tested in tests/test-kafka-sasl-status.yaml */}}
{{- define "rpk-cluster-info" -}}
{{- $cmd := (get ((include "redpanda.RpkClusterInfo" (dict "a" (list .))) | fromJson) "r") }}
{{- $cmd }}
{{- end -}}

{{/* tested in tests/test-kafka-sasl-status.yaml */}}
{{- define "rpk-topic-create" -}}
{{- $cmd := (get ((include "redpanda.RpkTopicCreate" (dict "a" (list .))) | fromJson) "r") }}
{{- $cmd }}
{{- end -}}

{{/* tested in tests/test-kafka-sasl-status.yaml */}}
{{- define "rpk-topic-describe" -}}
{{- $cmd := (get ((include "redpanda.RpkTopicDescribe" (dict "a" (list .))) | fromJson) "r") }}
{{- $cmd }}
{{- end -}}

{{/* tested in tests/test-kafka-sasl-status.yaml */}}
{{- define "rpk-topic-delete" -}}
{{- $cmd := (get ((include "redpanda.RpkTopicDelete" (dict "a" (list .))) | fromJson) "r") }}
{{- $cmd }}
{{- end -}}