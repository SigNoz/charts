{{- /* Generated from "post_upgrade_job.go" */ -}}

{{- define "redpanda.PostUpgrade" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.post_upgrade_job.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $labels := (default (dict ) $values.post_upgrade_job.labels) -}}
{{- $annotations := (default (dict ) $values.post_upgrade_job.annotations) -}}
{{- $annotations = (merge (dict ) (dict "helm.sh/hook" "post-upgrade" "helm.sh/hook-delete-policy" "before-hook-creation" "helm.sh/hook-weight" "-10" ) $annotations) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) ) "status" (dict ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "batch/v1" "kind" "Job" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (printf "%s-post-upgrade" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot) ))) "r")) "namespace" $dot.Release.Namespace "labels" (merge (dict ) (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot) ))) "r") $labels) "annotations" $annotations )) "spec" (mustMergeOverwrite (dict "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) ) (dict "backoffLimit" $values.post_upgrade_job.backoffLimit "template" (get (fromJson (include "redpanda.StrategicMergePatch" (dict "a" (list $values.post_upgrade_job.podTemplate (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" $dot.Release.Name "labels" (merge (dict ) (dict "app.kubernetes.io/name" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot) ))) "r") "app.kubernetes.io/instance" $dot.Release.Name "app.kubernetes.io/component" (printf "%s-post-upgrade" (trunc (50 | int) (get (fromJson (include "redpanda.Name" (dict "a" (list $dot) ))) "r"))) ) $values.commonLabels) )) "spec" (mustMergeOverwrite (dict "containers" (coalesce nil) ) (dict "nodeSelector" $values.nodeSelector "affinity" (merge (dict ) $values.post_upgrade_job.affinity $values.affinity) "tolerations" $values.tolerations "restartPolicy" "Never" "securityContext" (get (fromJson (include "redpanda.PodSecurityContext" (dict "a" (list $dot) ))) "r") "serviceAccountName" (get (fromJson (include "redpanda.ServiceAccountName" (dict "a" (list $dot) ))) "r") "imagePullSecrets" (default (coalesce nil) $values.imagePullSecrets) "containers" (list (mustMergeOverwrite (dict "name" "" "resources" (dict ) ) (dict "name" "post-upgrade" "image" (printf "%s:%s" $values.image.repository (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot) ))) "r")) "command" (list "/bin/bash" "-c") "args" (list (get (fromJson (include "redpanda.PostUpgradeJobScript" (dict "a" (list $dot) ))) "r")) "env" (get (fromJson (include "redpanda.rpkEnvVars" (dict "a" (list $dot $values.post_upgrade_job.extraEnv) ))) "r") "envFrom" $values.post_upgrade_job.extraEnvFrom "securityContext" (merge (dict ) (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.post_upgrade_job.securityContext (mustMergeOverwrite (dict ) (dict ))) ))) "r") (get (fromJson (include "redpanda.ContainerSecurityContext" (dict "a" (list $dot) ))) "r")) "resources" $values.post_upgrade_job.resources "volumeMounts" (get (fromJson (include "redpanda.DefaultMounts" (dict "a" (list $dot) ))) "r") ))) "volumes" (get (fromJson (include "redpanda.DefaultVolumes" (dict "a" (list $dot) ))) "r") )) ))) ))) "r") )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.PostUpgradeJobScript" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $script := (list `set -e` ``) -}}
{{- range $key, $value := $values.config.cluster -}}
{{- $tmp_tuple_1 := (get (fromJson (include "_shims.compact" (dict "a" (list (get (fromJson (include "_shims.asintegral" (dict "a" (list $value) ))) "r")) ))) "r") -}}
{{- $isInt64 := $tmp_tuple_1.T2 -}}
{{- $asInt64 := ($tmp_tuple_1.T1 | int64) -}}
{{- $tmp_tuple_2 := (get (fromJson (include "_shims.compact" (dict "a" (list (get (fromJson (include "_shims.typetest" (dict "a" (list "bool" $value false) ))) "r")) ))) "r") -}}
{{- $ok_2 := $tmp_tuple_2.T2 -}}
{{- $asBool_1 := $tmp_tuple_2.T1 -}}
{{- $tmp_tuple_3 := (get (fromJson (include "_shims.compact" (dict "a" (list (get (fromJson (include "_shims.typetest" (dict "a" (list "string" $value "") ))) "r")) ))) "r") -}}
{{- $ok_4 := $tmp_tuple_3.T2 -}}
{{- $asStr_3 := $tmp_tuple_3.T1 -}}
{{- $tmp_tuple_4 := (get (fromJson (include "_shims.compact" (dict "a" (list (get (fromJson (include "_shims.typetest" (dict "a" (list (printf "[]%s" "interface {}") $value (coalesce nil)) ))) "r")) ))) "r") -}}
{{- $ok_6 := $tmp_tuple_4.T2 -}}
{{- $asSlice_5 := $tmp_tuple_4.T1 -}}
{{- if (and $ok_2 $asBool_1) -}}
{{- $script = (concat (default (list ) $script) (list (printf "rpk cluster config set %s %t" $key $asBool_1))) -}}
{{- else -}}{{- if (and $ok_4 (ne $asStr_3 "")) -}}
{{- $script = (concat (default (list ) $script) (list (printf "rpk cluster config set %s %s" $key $asStr_3))) -}}
{{- else -}}{{- if (and $isInt64 (gt $asInt64 (0 | int64))) -}}
{{- $script = (concat (default (list ) $script) (list (printf "rpk cluster config set %s %d" $key $asInt64))) -}}
{{- else -}}{{- if (and $ok_6 (gt ((get (fromJson (include "_shims.len" (dict "a" (list $asSlice_5) ))) "r") | int) (0 | int))) -}}
{{- $script = (concat (default (list ) $script) (list (printf `rpk cluster config set %s "[ %s ]"` $key (join "," $asSlice_5)))) -}}
{{- else -}}{{- if (not (empty $value)) -}}
{{- $script = (concat (default (list ) $script) (list (printf "rpk cluster config set %s %v" $key $value))) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $tmp_tuple_5 := (get (fromJson (include "_shims.compact" (dict "a" (list (get (fromJson (include "_shims.dicttest" (dict "a" (list $values.config.cluster "default_topic_replications" (coalesce nil)) ))) "r")) ))) "r") -}}
{{- $ok_7 := $tmp_tuple_5.T2 -}}
{{- if (and (not $ok_7) (ge ($values.statefulset.replicas | int) (3 | int))) -}}
{{- $script = (concat (default (list ) $script) (list "rpk cluster config set default_topic_replications 3")) -}}
{{- end -}}
{{- $tmp_tuple_6 := (get (fromJson (include "_shims.compact" (dict "a" (list (get (fromJson (include "_shims.dicttest" (dict "a" (list $values.config.cluster "storage_min_free_bytes" (coalesce nil)) ))) "r")) ))) "r") -}}
{{- $ok_8 := $tmp_tuple_6.T2 -}}
{{- if (not $ok_8) -}}
{{- $script = (concat (default (list ) $script) (list (printf "rpk cluster config set storage_min_free_bytes %d" ((get (fromJson (include "redpanda.Storage.StorageMinFreeBytes" (dict "a" (list $values.storage) ))) "r") | int64)))) -}}
{{- end -}}
{{- if (get (fromJson (include "redpanda.RedpandaAtLeast_23_2_1" (dict "a" (list $dot) ))) "r") -}}
{{- $service := $values.listeners.admin -}}
{{- $caCert := "" -}}
{{- $scheme := "http" -}}
{{- if (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $service.tls $values.tls) ))) "r") -}}
{{- $scheme = "https" -}}
{{- $caCert = (printf "--cacert %q" (get (fromJson (include "redpanda.InternalTLS.ServerCAPath" (dict "a" (list $service.tls $values.tls) ))) "r")) -}}
{{- end -}}
{{- $url := (printf "%s://%s:%d/v1/debug/restart_service?service=schema-registry" $scheme (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot) ))) "r") (($service.port | int) | int64)) -}}
{{- $script = (concat (default (list ) $script) (list `if [ -d "/etc/secrets/users/" ]; then` `    IFS=":" read -r USER_NAME PASSWORD MECHANISM < <(grep "" $(find /etc/secrets/users/* -print))` `    curl -svm3 --fail --retry "120" --retry-max-time "120" --retry-all-errors --ssl-reqd \` (printf `    %s \` $caCert) `    -X PUT -u ${USER_NAME}:${PASSWORD} \` (printf `    %s || true` $url) `fi`)) -}}
{{- end -}}
{{- $script = (concat (default (list ) $script) (list "")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (join "\n" $script)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

