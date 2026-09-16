{{- /* Generated from "console.tpl.go" */ -}}

{{- define "redpanda.consoleChartIntegration" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values -}}
{{- if (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.console.enabled true)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $consoleDot := (index $dot.Subcharts "console") -}}
{{- $loadedValues := $consoleDot.Values -}}
{{- $consoleValue := $consoleDot.Values -}}
{{- $license_1 := (get (fromJson (include "redpanda.GetLicenseLiteral" (dict "a" (list $dot)))) "r") -}}
{{- if (and (ne $license_1 "") (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.console.secret.create false)))) "r"))) -}}
{{- $_ := (set $consoleValue.secret "create" true) -}}
{{- $_ := (set $consoleValue.secret "enterprise" (mustMergeOverwrite (dict) (dict "license" $license_1))) -}}
{{- end -}}
{{- if (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.console.configmap.create false)))) "r")) -}}
{{- $_ := (set $consoleValue.configmap "create" true) -}}
{{- $_ := (set $consoleValue.console "config" (get (fromJson (include "redpanda.ConsoleConfig" (dict "a" (list $dot)))) "r")) -}}
{{- end -}}
{{- if (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.console.deployment.create false)))) "r")) -}}
{{- $_ := (set $consoleValue.deployment "create" true) -}}
{{- if (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r") -}}
{{- $command := (list "sh" "-c" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" (printf "%s%s" "set -e; IFS=':' read -r KAFKA_SASL_USERNAME KAFKA_SASL_PASSWORD KAFKA_SASL_MECHANISM < <(grep \"\" $(find /mnt/users/* -print));" (printf " KAFKA_SASL_MECHANISM=${KAFKA_SASL_MECHANISM:-%s};" (get (fromJson (include "redpanda.SASLMechanism" (dict "a" (list $dot)))) "r"))) " export KAFKA_SASL_USERNAME KAFKA_SASL_PASSWORD KAFKA_SASL_MECHANISM;") " export KAFKA_SCHEMAREGISTRY_USERNAME=$KAFKA_SASL_USERNAME;") " export KAFKA_SCHEMAREGISTRY_PASSWORD=$KAFKA_SASL_PASSWORD;") " export REDPANDA_ADMINAPI_USERNAME=$KAFKA_SASL_USERNAME;") " export REDPANDA_ADMINAPI_PASSWORD=$KAFKA_SASL_PASSWORD;") " /app/console $@") " --") -}}
{{- $_ := (set $consoleValue.deployment "command" $command) -}}
{{- end -}}
{{- $secret_2 := (get (fromJson (include "redpanda.GetLicenseSecretReference" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $secret_2) "null") -}}
{{- $_ := (set $consoleValue "enterprise" (mustMergeOverwrite (dict "licenseSecretRef" (dict "name" "" "key" "")) (dict "licenseSecretRef" (mustMergeOverwrite (dict "name" "" "key" "") (dict "name" $secret_2.name "key" $secret_2.key))))) -}}
{{- end -}}
{{- $_ := (set $consoleValue "extraVolumes" (get (fromJson (include "redpanda.consoleTLSVolumes" (dict "a" (list $dot)))) "r")) -}}
{{- $_ := (set $consoleValue "extraVolumeMounts" (get (fromJson (include "redpanda.consoleTLSVolumesMounts" (dict "a" (list $dot)))) "r")) -}}
{{- $_ := (set $consoleDot "Values" $consoleValue) -}}
{{- $cfg := (get (fromJson (include "console.ConfigMap" (dict "a" (list $consoleDot)))) "r") -}}
{{- if (eq (toJson $consoleValue.podAnnotations) "null") -}}
{{- $_ := (set $consoleValue "podAnnotations" (dict)) -}}
{{- end -}}
{{- $_ := (set $consoleValue.podAnnotations "checksum-redpanda-chart/config" (sha256sum (toYaml $cfg))) -}}
{{- end -}}
{{- $_ := (set $consoleDot "Values" $consoleValue) -}}
{{- $manifests := (list (get (fromJson (include "console.Secret" (dict "a" (list $consoleDot)))) "r") (get (fromJson (include "console.ConfigMap" (dict "a" (list $consoleDot)))) "r") (get (fromJson (include "console.Deployment" (dict "a" (list $consoleDot)))) "r")) -}}
{{- $_ := (set $consoleDot "Values" $loadedValues) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $manifests) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.consoleTLSVolumesMounts" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $mounts := (list) -}}
{{- $sasl_3 := $values.auth.sasl -}}
{{- if (and $sasl_3.enabled (ne $sasl_3.secretRef "")) -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" (printf "%s-users" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) "mountPath" "/mnt/users" "readOnly" true)))) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list (get (fromJson (include "redpanda.Listeners.TrustStores" (dict "a" (list $values.listeners $values.tls)))) "r"))))) "r") | int) (0 | int)) -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "truststores" "mountPath" "/etc/truststores" "readOnly" true)))) -}}
{{- end -}}
{{- $visitedCert := (dict) -}}
{{- range $_, $tlsCfg := (list $values.listeners.kafka.tls $values.listeners.schemaRegistry.tls $values.listeners.admin.tls) -}}
{{- $_137___visited := (get (fromJson (include "_shims.dicttest" (dict "a" (list $visitedCert $tlsCfg.cert false)))) "r") -}}
{{- $_ := (index $_137___visited 0) -}}
{{- $visited := (index $_137___visited 1) -}}
{{- if (or (not (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $tlsCfg $values.tls)))) "r")) $visited) -}}
{{- continue -}}
{{- end -}}
{{- $_ := (set $visitedCert $tlsCfg.cert true) -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" (printf "redpanda-%s-cert" $tlsCfg.cert) "mountPath" (printf "%s/%s" "/etc/tls/certs" $tlsCfg.cert))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) $mounts) (default (list) $values.console.extraVolumeMounts))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.consoleTLSVolumes" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $volumes := (list) -}}
{{- $sasl_4 := $values.auth.sasl -}}
{{- if (and $sasl_4.enabled (ne $sasl_4.secretRef "")) -}}
{{- $volumes = (concat (default (list) $volumes) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" $values.auth.sasl.secretRef)))) (dict "name" (printf "%s-users" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")))))) -}}
{{- end -}}
{{- $vol_5 := (get (fromJson (include "redpanda.Listeners.TrustStoreVolume" (dict "a" (list $values.listeners $values.tls)))) "r") -}}
{{- if (ne (toJson $vol_5) "null") -}}
{{- $volumes = (concat (default (list) $volumes) (list $vol_5)) -}}
{{- end -}}
{{- $visitedCert := (dict) -}}
{{- range $_, $tlsCfg := (list $values.listeners.kafka.tls $values.listeners.schemaRegistry.tls $values.listeners.admin.tls) -}}
{{- $_178___visited := (get (fromJson (include "_shims.dicttest" (dict "a" (list $visitedCert $tlsCfg.cert false)))) "r") -}}
{{- $_ := (index $_178___visited 0) -}}
{{- $visited := (index $_178___visited 1) -}}
{{- if (or (not (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $tlsCfg $values.tls)))) "r")) $visited) -}}
{{- continue -}}
{{- end -}}
{{- $_ := (set $visitedCert $tlsCfg.cert true) -}}
{{- $volumes = (concat (default (list) $volumes) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "defaultMode" (0o420 | int) "secretName" (get (fromJson (include "redpanda.CertSecretName" (dict "a" (list $dot $tlsCfg.cert (get (fromJson (include "redpanda.TLSCertMap.MustGet" (dict "a" (list (deepCopy $values.tls.certs) $tlsCfg.cert)))) "r"))))) "r"))))) (dict "name" (printf "redpanda-%s-cert" $tlsCfg.cert))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) $volumes) (default (list) $values.console.extraVolumes))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ConsoleConfig" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $schemaURLs := (coalesce nil) -}}
{{- if $values.listeners.schemaRegistry.enabled -}}
{{- $schema := "http" -}}
{{- if (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $values.listeners.schemaRegistry.tls $values.tls)))) "r") -}}
{{- $schema = "https" -}}
{{- end -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) (($values.statefulset.replicas | int)|int) (1|int) -}}
{{- $schemaURLs = (concat (default (list) $schemaURLs) (list (printf "%s://%s-%d.%s:%d" $schema (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") $i (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r") ($values.listeners.schemaRegistry.port | int)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- $schema := "http" -}}
{{- if (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $values.listeners.admin.tls $values.tls)))) "r") -}}
{{- $schema = "https" -}}
{{- end -}}
{{- $c := (dict "kafka" (dict "brokers" (get (fromJson (include "redpanda.BrokerList" (dict "a" (list $dot ($values.statefulset.replicas | int) ($values.listeners.kafka.port | int))))) "r") "sasl" (dict "enabled" (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r")) "tls" (get (fromJson (include "redpanda.KafkaListeners.ConsoleTLS" (dict "a" (list $values.listeners.kafka $values.tls)))) "r") "schemaRegistry" (dict "enabled" $values.listeners.schemaRegistry.enabled "urls" $schemaURLs "tls" (get (fromJson (include "redpanda.SchemaRegistryListeners.ConsoleTLS" (dict "a" (list $values.listeners.schemaRegistry $values.tls)))) "r"))) "redpanda" (dict "adminApi" (dict "enabled" true "urls" (list (printf "%s://%s:%d" $schema (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r") ($values.listeners.admin.port | int))) "tls" (get (fromJson (include "redpanda.AdminListeners.ConsoleTLS" (dict "a" (list $values.listeners.admin $values.tls)))) "r")))) -}}
{{- if (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.connectors.enabled false)))) "r") -}}
{{- $port := (dig "connectors" "connectors" "restPort" (8083 | int) $dot.Values.AsMap) -}}
{{- $_249_p_ok := (get (fromJson (include "_shims.asintegral" (dict "a" (list $port)))) "r") -}}
{{- $p := ((index $_249_p_ok 0) | int) -}}
{{- $ok := (index $_249_p_ok 1) -}}
{{- if (not $ok) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $c) | toJson -}}
{{- break -}}
{{- end -}}
{{- $connectorsDot := (index $dot.Subcharts "connectors") -}}
{{- $connectorsURL := (printf "http://%s.%s.svc.%s:%d" (get (fromJson (include "connectors.Fullname" (dict "a" (list $connectorsDot)))) "r") $dot.Release.Namespace (trimSuffix "." $values.clusterDomain) $p) -}}
{{- $_ := (set $c "connect" (dict "enabled" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.connectors.enabled false)))) "r") "clusters" (list (dict "name" "connectors" "url" $connectorsURL "tls" (dict "enabled" false "caFilepath" "" "certFilepath" "" "keyFilepath" "" "insecureSkipTlsVerify" false) "username" "" "password" "" "token" "")) "connectTimeout" (0 | int) "readTimeout" (0 | int) "requestTimeout" (0 | int))) -}}
{{- end -}}
{{- if (eq (toJson $values.console.console) "null") -}}
{{- $_ := (set $values.console "console" (mustMergeOverwrite (dict) (dict "config" (dict)))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $values.console.console.config $c)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

