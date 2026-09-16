{{- /* Generated from "connectors.go" */ -}}

{{- define "redpanda.connectorsChartIntegration" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values -}}
{{- if (or (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.connectors.enabled false)))) "r")) (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.connectors.deployment.create false)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $connectorsDot := (index $dot.Subcharts "connectors") -}}
{{- $loadedValues := $connectorsDot.Values -}}
{{- $connectorsValue := $connectorsDot.Values -}}
{{- $_ := (set $connectorsValue "deployment" (merge (dict) $connectorsValue.deployment (mustMergeOverwrite (dict "create" false "strategy" (dict) "schedulerName" "" "budget" (dict "maxUnavailable" 0) "annotations" (coalesce nil) "extraEnv" (coalesce nil) "extraEnvFrom" (coalesce nil) "progressDeadlineSeconds" 0 "nodeSelector" (coalesce nil) "tolerations" (coalesce nil) "restartPolicy" "") (dict "create" true)))) -}}
{{- if (eq $connectorsValue.connectors.bootstrapServers "") -}}
{{- range $_, $b := (get (fromJson (include "redpanda.BrokerList" (dict "a" (list $dot ($values.statefulset.replicas | int) ($values.listeners.kafka.port | int))))) "r") -}}
{{- if (eq ((get (fromJson (include "_shims.len" (dict "a" (list $connectorsValue.connectors.bootstrapServers)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $connectorsValue.connectors "bootstrapServers" $b) -}}
{{- continue -}}
{{- end -}}
{{- $_ := (set $connectorsValue.connectors "bootstrapServers" (printf "%s,%s" $connectorsValue.connectors.bootstrapServers $b)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- $_ := (set $connectorsValue.connectors "brokerTLS" (mustMergeOverwrite (dict "enabled" false "ca" (dict "secretRef" "" "secretNameOverwrite" "") "cert" (dict "secretRef" "" "secretNameOverwrite" "") "key" (dict "secretRef" "" "secretNameOverwrite" "")) (dict "enabled" false "ca" (mustMergeOverwrite (dict "secretRef" "" "secretNameOverwrite" "") (dict)) "cert" (mustMergeOverwrite (dict "secretRef" "" "secretNameOverwrite" "") (dict)) "key" (mustMergeOverwrite (dict "secretRef" "" "secretNameOverwrite" "") (dict))))) -}}
{{- $_ := (set $connectorsValue.connectors "brokerTLS" (get (fromJson (include "redpanda.KafkaListeners.ConnectorsTLS" (dict "a" (list $values.listeners.kafka $values.tls (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))))) "r")) -}}
{{- if (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r") -}}
{{- $command := (list "bash" "-c" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" "set -e; IFS=':' read -r CONNECT_SASL_USERNAME CONNECT_SASL_PASSWORD CONNECT_SASL_MECHANISM < <(grep \"\" $(find /mnt/users/* -print));" (printf " CONNECT_SASL_MECHANISM=${CONNECT_SASL_MECHANISM:-%s};" (get (fromJson (include "redpanda.SASLMechanism" (dict "a" (list $dot)))) "r"))) " export CONNECT_SASL_USERNAME CONNECT_SASL_PASSWORD CONNECT_SASL_MECHANISM;") " [[ $CONNECT_SASL_MECHANISM == \"SCRAM-SHA-256\" ]] && CONNECT_SASL_MECHANISM=scram-sha-256;") " [[ $CONNECT_SASL_MECHANISM == \"SCRAM-SHA-512\" ]] && CONNECT_SASL_MECHANISM=scram-sha-512;") " export CONNECT_SASL_MECHANISM;") " echo $CONNECT_SASL_PASSWORD > /opt/kafka/connect-password/rc-credentials/password;") " exec /opt/kafka/bin/kafka_connect_run.sh")) -}}
{{- $_ := (set $connectorsValue.deployment "command" $command) -}}
{{- $_ := (set $connectorsValue.auth "sasl" (merge (dict) $connectorsValue.auth.sasl (mustMergeOverwrite (dict "enabled" false "mechanism" "" "secretRef" "" "userName" "") (dict "enabled" true)))) -}}
{{- $_ := (set $connectorsValue.storage "volume" (concat (default (list) $connectorsValue.storage.volume) (default (list) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" $values.auth.sasl.secretRef)))) (dict "name" (get (fromJson (include "redpanda.cleanForK8sWithSuffix" (dict "a" (list (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") "users")))) "r"))) (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "emptyDir" (mustMergeOverwrite (dict) (dict)))) (dict "name" (get (fromJson (include "redpanda.cleanForK8sWithSuffix" (dict "a" (list (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") "user-password")))) "r"))))))) -}}
{{- $_ := (set $connectorsValue.storage "volumeMounts" (concat (default (list) $connectorsValue.storage.volumeMounts) (default (list) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" (get (fromJson (include "redpanda.cleanForK8sWithSuffix" (dict "a" (list (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") "users")))) "r") "mountPath" "/mnt/users" "readOnly" true)) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" (get (fromJson (include "redpanda.cleanForK8sWithSuffix" (dict "a" (list (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") "user-password")))) "r") "mountPath" "/opt/kafka/connect-password/rc-credentials")))))) -}}
{{- $_ := (set $connectorsValue.deployment "extraEnv" (concat (default (list) $connectorsValue.deployment.extraEnv) (default (list) (list (mustMergeOverwrite (dict "name" "") (dict "name" "CONNECT_SASL_PASSWORD_FILE" "value" "rc-credentials/password")))))) -}}
{{- end -}}
{{- $_ := (set $connectorsDot "Values" $connectorsValue) -}}
{{- $manifests := (list (get (fromJson (include "connectors.Deployment" (dict "a" (list $connectorsDot)))) "r")) -}}
{{- $_ := (set $connectorsDot "Values" $loadedValues) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $manifests) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

