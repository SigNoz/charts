{{- /* Generated from "configmap.tpl.go" */ -}}

{{- define "redpanda.ConfigMaps" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $cms := (list (get (fromJson (include "redpanda.RedpandaConfigMap" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.RPKProfile" (dict "a" (list $dot)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $cms) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaConfigMap" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil))) (mustMergeOverwrite (dict) (dict "kind" "ConfigMap" "apiVersion" "v1")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r"))) "data" (dict "bootstrap.yaml" (get (fromJson (include "redpanda.BootstrapFile" (dict "a" (list $dot)))) "r") "redpanda.yaml" (get (fromJson (include "redpanda.RedpandaConfigFile" (dict "a" (list $dot true)))) "r"))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.BootstrapFile" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $bootstrap := (dict "kafka_enable_authorization" (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r") "enable_sasl" (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r") "enable_rack_awareness" $values.rackAwareness.enabled "storage_min_free_bytes" ((get (fromJson (include "redpanda.Storage.StorageMinFreeBytes" (dict "a" (list $values.storage)))) "r") | int64)) -}}
{{- $bootstrap = (merge (dict) $bootstrap (get (fromJson (include "redpanda.AuditLogging.Translate" (dict "a" (list $values.auditLogging $dot (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r"))))) "r")) -}}
{{- $bootstrap = (merge (dict) $bootstrap (get (fromJson (include "redpanda.Logging.Translate" (dict "a" (list $values.logging)))) "r")) -}}
{{- $bootstrap = (merge (dict) $bootstrap (get (fromJson (include "redpanda.TunableConfig.Translate" (dict "a" (list $values.config.tunable)))) "r")) -}}
{{- $bootstrap = (merge (dict) $bootstrap (get (fromJson (include "redpanda.ClusterConfig.Translate" (dict "a" (list $values.config.cluster)))) "r")) -}}
{{- $bootstrap = (merge (dict) $bootstrap (get (fromJson (include "redpanda.Auth.Translate" (dict "a" (list $values.auth (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r"))))) "r")) -}}
{{- $bootstrap = (merge (dict) $bootstrap (get (fromJson (include "redpanda.TieredStorageConfig.Translate" (dict "a" (list (deepCopy (get (fromJson (include "redpanda.Storage.GetTieredStorageConfig" (dict "a" (list $values.storage)))) "r")) $values.storage.tiered.credentialsSecretRef)))) "r")) -}}
{{- $_80___ok_1 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $values.config.cluster "default_topic_replications" (coalesce nil))))) "r") -}}
{{- $_ := (index $_80___ok_1 0) -}}
{{- $ok_1 := (index $_80___ok_1 1) -}}
{{- if (and (not $ok_1) (ge ($values.statefulset.replicas | int) (3 | int))) -}}
{{- $_ := (set $bootstrap "default_topic_replications" (3 | int)) -}}
{{- end -}}
{{- $_85___ok_2 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $values.config.cluster "storage_min_free_bytes" (coalesce nil))))) "r") -}}
{{- $_ := (index $_85___ok_2 0) -}}
{{- $ok_2 := (index $_85___ok_2 1) -}}
{{- if (not $ok_2) -}}
{{- $_ := (set $bootstrap "storage_min_free_bytes" ((get (fromJson (include "redpanda.Storage.StorageMinFreeBytes" (dict "a" (list $values.storage)))) "r") | int64)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (toYaml $bootstrap)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaConfigFile" -}}
{{- $dot := (index .a 0) -}}
{{- $includeNonHashableItems := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $redpanda := (dict "empty_seed_starts_cluster" false) -}}
{{- if $includeNonHashableItems -}}
{{- $_ := (set $redpanda "seed_servers" (get (fromJson (include "redpanda.Listeners.CreateSeedServers" (dict "a" (list $values.listeners ($values.statefulset.replicas | int) (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r"))))) "r")) -}}
{{- end -}}
{{- $redpanda = (merge (dict) $redpanda (get (fromJson (include "redpanda.NodeConfig.Translate" (dict "a" (list $values.config.node)))) "r")) -}}
{{- $_ := (get (fromJson (include "redpanda.configureListeners" (dict "a" (list $redpanda $dot)))) "r") -}}
{{- $redpandaYaml := (dict "redpanda" $redpanda "schema_registry" (get (fromJson (include "redpanda.schemaRegistry" (dict "a" (list $dot)))) "r") "pandaproxy" (get (fromJson (include "redpanda.pandaProxyListener" (dict "a" (list $dot)))) "r") "config_file" "/etc/redpanda/redpanda.yaml") -}}
{{- if $includeNonHashableItems -}}
{{- $_ := (set $redpandaYaml "rpk" (get (fromJson (include "redpanda.rpkNodeConfig" (dict "a" (list $dot)))) "r")) -}}
{{- $_ := (set $redpandaYaml "pandaproxy_client" (get (fromJson (include "redpanda.kafkaClient" (dict "a" (list $dot)))) "r")) -}}
{{- $_ := (set $redpandaYaml "schema_registry_client" (get (fromJson (include "redpanda.kafkaClient" (dict "a" (list $dot)))) "r")) -}}
{{- if (and (and (get (fromJson (include "redpanda.RedpandaAtLeast_23_3_0" (dict "a" (list $dot)))) "r") $values.auditLogging.enabled) (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r")) -}}
{{- $_ := (set $redpandaYaml "audit_log_client" (get (fromJson (include "redpanda.kafkaClient" (dict "a" (list $dot)))) "r")) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (toYaml $redpandaYaml)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RPKProfile" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.external.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil))) (mustMergeOverwrite (dict) (dict "kind" "ConfigMap" "apiVersion" "v1")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (printf "%s-rpk" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) "namespace" $dot.Release.Namespace "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r"))) "data" (dict "profile" (toYaml (get (fromJson (include "redpanda.rpkProfile" (dict "a" (list $dot)))) "r")))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpkProfile" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $brokerList := (list) -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) (($values.statefulset.replicas | int)|int) (1|int) -}}
{{- $brokerList = (concat (default (list) $brokerList) (list (printf "%s:%d" (get (fromJson (include "redpanda.advertisedHost" (dict "a" (list $dot $i)))) "r") (((get (fromJson (include "redpanda.advertisedKafkaPort" (dict "a" (list $dot $i)))) "r") | int) | int)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $adminAdvertisedList := (list) -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) (($values.statefulset.replicas | int)|int) (1|int) -}}
{{- $adminAdvertisedList = (concat (default (list) $adminAdvertisedList) (list (printf "%s:%d" (get (fromJson (include "redpanda.advertisedHost" (dict "a" (list $dot $i)))) "r") (((get (fromJson (include "redpanda.advertisedAdminPort" (dict "a" (list $dot $i)))) "r") | int) | int)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $schemaAdvertisedList := (list) -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) (($values.statefulset.replicas | int)|int) (1|int) -}}
{{- $schemaAdvertisedList = (concat (default (list) $schemaAdvertisedList) (list (printf "%s:%d" (get (fromJson (include "redpanda.advertisedHost" (dict "a" (list $dot $i)))) "r") (((get (fromJson (include "redpanda.advertisedSchemaPort" (dict "a" (list $dot $i)))) "r") | int) | int)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $kafkaTLS := (get (fromJson (include "redpanda.rpkKafkaClientTLSConfiguration" (dict "a" (list $dot)))) "r") -}}
{{- $_175___ok_3 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $kafkaTLS "ca_file" (coalesce nil))))) "r") -}}
{{- $_ := (index $_175___ok_3 0) -}}
{{- $ok_3 := (index $_175___ok_3 1) -}}
{{- if $ok_3 -}}
{{- $_ := (set $kafkaTLS "ca_file" "ca.crt") -}}
{{- end -}}
{{- $adminTLS := (get (fromJson (include "redpanda.rpkAdminAPIClientTLSConfiguration" (dict "a" (list $dot)))) "r") -}}
{{- $_181___ok_4 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $adminTLS "ca_file" (coalesce nil))))) "r") -}}
{{- $_ := (index $_181___ok_4 0) -}}
{{- $ok_4 := (index $_181___ok_4 1) -}}
{{- if $ok_4 -}}
{{- $_ := (set $adminTLS "ca_file" "ca.crt") -}}
{{- end -}}
{{- $schemaTLS := (get (fromJson (include "redpanda.rpkSchemaRegistryClientTLSConfiguration" (dict "a" (list $dot)))) "r") -}}
{{- $_187___ok_5 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $schemaTLS "ca_file" (coalesce nil))))) "r") -}}
{{- $_ := (index $_187___ok_5 0) -}}
{{- $ok_5 := (index $_187___ok_5 1) -}}
{{- if $ok_5 -}}
{{- $_ := (set $schemaTLS "ca_file" "ca.crt") -}}
{{- end -}}
{{- $ka := (dict "brokers" $brokerList "tls" (coalesce nil)) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $kafkaTLS)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $ka "tls" $kafkaTLS) -}}
{{- end -}}
{{- $aa := (dict "addresses" $adminAdvertisedList "tls" (coalesce nil)) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $adminTLS)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $aa "tls" $adminTLS) -}}
{{- end -}}
{{- $sa := (dict "addresses" $schemaAdvertisedList "tls" (coalesce nil)) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $schemaTLS)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $sa "tls" $schemaTLS) -}}
{{- end -}}
{{- $result := (dict "name" (get (fromJson (include "redpanda.getFirstExternalKafkaListener" (dict "a" (list $dot)))) "r") "kafka_api" $ka "admin_api" $aa "schema_registry" $sa) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.advertisedKafkaPort" -}}
{{- $dot := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $externalKafkaListenerName := (get (fromJson (include "redpanda.getFirstExternalKafkaListener" (dict "a" (list $dot)))) "r") -}}
{{- $listener := (ternary (index $values.listeners.kafka.external $externalKafkaListenerName) (dict "enabled" (coalesce nil) "advertisedPorts" (coalesce nil) "port" 0 "nodePort" (coalesce nil) "authenticationMethod" (coalesce nil) "prefixTemplate" (coalesce nil) "tls" (coalesce nil)) (hasKey $values.listeners.kafka.external $externalKafkaListenerName)) -}}
{{- $port := (($values.listeners.kafka.port | int) | int) -}}
{{- if (gt (($listener.port | int) | int) ((1 | int) | int)) -}}
{{- $port = (($listener.port | int) | int) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (1 | int)) -}}
{{- $port = ((index $listener.advertisedPorts $i) | int) -}}
{{- else -}}{{- if (eq ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (1 | int)) -}}
{{- $port = ((index $listener.advertisedPorts (0 | int)) | int) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $port) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.advertisedAdminPort" -}}
{{- $dot := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $keys := (keys $values.listeners.admin.external) -}}
{{- $_ := (sortAlpha $keys) -}}
{{- $externalAdminListenerName := (first $keys) -}}
{{- $listener := (ternary (index $values.listeners.admin.external (get (fromJson (include "_shims.typeassertion" (dict "a" (list "string" $externalAdminListenerName)))) "r")) (dict "enabled" (coalesce nil) "advertisedPorts" (coalesce nil) "port" 0 "nodePort" (coalesce nil) "tls" (coalesce nil)) (hasKey $values.listeners.admin.external (get (fromJson (include "_shims.typeassertion" (dict "a" (list "string" $externalAdminListenerName)))) "r"))) -}}
{{- $port := (($values.listeners.admin.port | int) | int) -}}
{{- if (gt (($listener.port | int) | int) (1 | int)) -}}
{{- $port = (($listener.port | int) | int) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (1 | int)) -}}
{{- $port = ((index $listener.advertisedPorts $i) | int) -}}
{{- else -}}{{- if (eq ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (1 | int)) -}}
{{- $port = ((index $listener.advertisedPorts (0 | int)) | int) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $port) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.advertisedSchemaPort" -}}
{{- $dot := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $keys := (keys $values.listeners.schemaRegistry.external) -}}
{{- $_ := (sortAlpha $keys) -}}
{{- $externalSchemaListenerName := (first $keys) -}}
{{- $listener := (ternary (index $values.listeners.schemaRegistry.external (get (fromJson (include "_shims.typeassertion" (dict "a" (list "string" $externalSchemaListenerName)))) "r")) (dict "enabled" (coalesce nil) "advertisedPorts" (coalesce nil) "port" 0 "nodePort" (coalesce nil) "authenticationMethod" (coalesce nil) "tls" (coalesce nil)) (hasKey $values.listeners.schemaRegistry.external (get (fromJson (include "_shims.typeassertion" (dict "a" (list "string" $externalSchemaListenerName)))) "r"))) -}}
{{- $port := (($values.listeners.schemaRegistry.port | int) | int) -}}
{{- if (gt (($listener.port | int) | int) (1 | int)) -}}
{{- $port = (($listener.port | int) | int) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (1 | int)) -}}
{{- $port = ((index $listener.advertisedPorts $i) | int) -}}
{{- else -}}{{- if (eq ((get (fromJson (include "_shims.len" (dict "a" (list $listener.advertisedPorts)))) "r") | int) (1 | int)) -}}
{{- $port = ((index $listener.advertisedPorts (0 | int)) | int) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $port) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.advertisedHost" -}}
{{- $dot := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $address := (printf "%s-%d" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") ($i | int)) -}}
{{- if (ne (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.external.domain "")))) "r") "") -}}
{{- $address = (printf "%s.%s" $address (tpl $values.external.domain $dot)) -}}
{{- end -}}
{{- if (le ((get (fromJson (include "_shims.len" (dict "a" (list $values.external.addresses)))) "r") | int) (0 | int)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $address) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (eq ((get (fromJson (include "_shims.len" (dict "a" (list $values.external.addresses)))) "r") | int) (1 | int)) -}}
{{- $address = (index $values.external.addresses (0 | int)) -}}
{{- else -}}
{{- $address = (index $values.external.addresses $i) -}}
{{- end -}}
{{- if (ne (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.external.domain "")))) "r") "") -}}
{{- $address = (printf "%s.%s" $address (tpl $values.external.domain $dot)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $address) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.getFirstExternalKafkaListener" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $keys := (keys $values.listeners.kafka.external) -}}
{{- $_ := (sortAlpha $keys) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "_shims.typeassertion" (dict "a" (list "string" (first $keys))))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.BrokerList" -}}
{{- $dot := (index .a 0) -}}
{{- $replicas := (index .a 1) -}}
{{- $port := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $bl := (coalesce nil) -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) ($replicas|int) (1|int) -}}
{{- $bl = (concat (default (list) $bl) (list (printf "%s-%d.%s:%d" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") $i (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r") $port))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $bl) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpkNodeConfig" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $brokerList := (get (fromJson (include "redpanda.BrokerList" (dict "a" (list $dot ($values.statefulset.replicas | int) ($values.listeners.kafka.port | int))))) "r") -}}
{{- $adminTLS := (coalesce nil) -}}
{{- $tls_6 := (get (fromJson (include "redpanda.rpkAdminAPIClientTLSConfiguration" (dict "a" (list $dot)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_6)))) "r") | int) (0 | int)) -}}
{{- $adminTLS = $tls_6 -}}
{{- end -}}
{{- $brokerTLS := (coalesce nil) -}}
{{- $tls_7 := (get (fromJson (include "redpanda.rpkKafkaClientTLSConfiguration" (dict "a" (list $dot)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_7)))) "r") | int) (0 | int)) -}}
{{- $brokerTLS = $tls_7 -}}
{{- end -}}
{{- $schemaRegistryTLS := (coalesce nil) -}}
{{- $tls_8 := (get (fromJson (include "redpanda.rpkSchemaRegistryClientTLSConfiguration" (dict "a" (list $dot)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_8)))) "r") | int) (0 | int)) -}}
{{- $schemaRegistryTLS = $tls_8 -}}
{{- end -}}
{{- $_372_lockMemory_overprovisioned_flags := (get (fromJson (include "redpanda.RedpandaAdditionalStartFlags" (dict "a" (list $values)))) "r") -}}
{{- $lockMemory := (index $_372_lockMemory_overprovisioned_flags 0) -}}
{{- $overprovisioned := (index $_372_lockMemory_overprovisioned_flags 1) -}}
{{- $flags := (index $_372_lockMemory_overprovisioned_flags 2) -}}
{{- $result := (dict "additional_start_flags" $flags "enable_memory_locking" $lockMemory "overprovisioned" $overprovisioned "kafka_api" (dict "brokers" $brokerList "tls" $brokerTLS) "admin_api" (dict "addresses" (get (fromJson (include "redpanda.Listeners.AdminList" (dict "a" (list $values.listeners ($values.statefulset.replicas | int) (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r"))))) "r") "tls" $adminTLS) "schema_registry" (dict "addresses" (get (fromJson (include "redpanda.Listeners.SchemaRegistryList" (dict "a" (list $values.listeners ($values.statefulset.replicas | int) (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r"))))) "r") "tls" $schemaRegistryTLS)) -}}
{{- $result = (merge (dict) $result (get (fromJson (include "redpanda.Tuning.Translate" (dict "a" (list $values.tuning)))) "r")) -}}
{{- $result = (merge (dict) $result (get (fromJson (include "redpanda.Config.CreateRPKConfiguration" (dict "a" (list $values.config)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpkKafkaClientTLSConfiguration" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $tls := $values.listeners.kafka.tls -}}
{{- if (not (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $tls $values.tls)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $result := (dict "ca_file" (get (fromJson (include "redpanda.InternalTLS.ServerCAPath" (dict "a" (list $tls $values.tls)))) "r")) -}}
{{- if $tls.requireClientAuth -}}
{{- $_ := (set $result "cert_file" (printf "%s/%s-client/tls.crt" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- $_ := (set $result "key_file" (printf "%s/%s-client/tls.key" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpkAdminAPIClientTLSConfiguration" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $tls := $values.listeners.admin.tls -}}
{{- if (not (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $tls $values.tls)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $result := (dict "ca_file" (get (fromJson (include "redpanda.InternalTLS.ServerCAPath" (dict "a" (list $tls $values.tls)))) "r")) -}}
{{- if $tls.requireClientAuth -}}
{{- $_ := (set $result "cert_file" (printf "%s/%s-client/tls.crt" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- $_ := (set $result "key_file" (printf "%s/%s-client/tls.key" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpkSchemaRegistryClientTLSConfiguration" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $tls := $values.listeners.schemaRegistry.tls -}}
{{- if (not (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $tls $values.tls)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $result := (dict "ca_file" (get (fromJson (include "redpanda.InternalTLS.ServerCAPath" (dict "a" (list $tls $values.tls)))) "r")) -}}
{{- if $tls.requireClientAuth -}}
{{- $_ := (set $result "cert_file" (printf "%s/%s-client/tls.crt" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- $_ := (set $result "key_file" (printf "%s/%s-client/tls.key" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.kafkaClient" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $brokerList := (list) -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) (($values.statefulset.replicas | int)|int) (1|int) -}}
{{- $brokerList = (concat (default (list) $brokerList) (list (dict "address" (printf "%s-%d.%s" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") $i (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r")) "port" ($values.listeners.kafka.port | int)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $kafkaTLS := $values.listeners.kafka.tls -}}
{{- $brokerTLS := (coalesce nil) -}}
{{- if (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $values.listeners.kafka.tls $values.tls)))) "r") -}}
{{- $brokerTLS = (dict "enabled" true "require_client_auth" $kafkaTLS.requireClientAuth "truststore_file" (get (fromJson (include "redpanda.InternalTLS.ServerCAPath" (dict "a" (list $kafkaTLS $values.tls)))) "r")) -}}
{{- if $kafkaTLS.requireClientAuth -}}
{{- $_ := (set $brokerTLS "cert_file" (printf "%s/%s-client/tls.crt" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- $_ := (set $brokerTLS "key_file" (printf "%s/%s-client/tls.key" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) -}}
{{- end -}}
{{- end -}}
{{- $cfg := (dict "brokers" $brokerList) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $brokerTLS)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $cfg "broker_tls" $brokerTLS) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $cfg) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.configureListeners" -}}
{{- $redpanda := (index .a 0) -}}
{{- $dot := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_ := (set $redpanda "admin" (get (fromJson (include "redpanda.AdminListeners.Listeners" (dict "a" (list $values.listeners.admin)))) "r")) -}}
{{- $_ := (set $redpanda "kafka_api" (get (fromJson (include "redpanda.KafkaListeners.Listeners" (dict "a" (list $values.listeners.kafka $values.auth)))) "r")) -}}
{{- $_ := (set $redpanda "rpc_server" (get (fromJson (include "redpanda.rpcListeners" (dict "a" (list $dot)))) "r")) -}}
{{- $_ := (set $redpanda "admin_api_tls" (coalesce nil)) -}}
{{- $tls_9 := (get (fromJson (include "redpanda.AdminListeners.ListenersTLS" (dict "a" (list $values.listeners.admin $values.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_9)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $redpanda "admin_api_tls" $tls_9) -}}
{{- end -}}
{{- $_ := (set $redpanda "kafka_api_tls" (coalesce nil)) -}}
{{- $tls_10 := (get (fromJson (include "redpanda.KafkaListeners.ListenersTLS" (dict "a" (list $values.listeners.kafka $values.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_10)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $redpanda "kafka_api_tls" $tls_10) -}}
{{- end -}}
{{- $tls_11 := (get (fromJson (include "redpanda.rpcListenersTLS" (dict "a" (list $dot)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_11)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $redpanda "rpc_server_tls" $tls_11) -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.pandaProxyListener" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $pandaProxy := (dict) -}}
{{- $_ := (set $pandaProxy "pandaproxy_api" (get (fromJson (include "redpanda.HTTPListeners.Listeners" (dict "a" (list $values.listeners.http (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r"))))) "r")) -}}
{{- $_ := (set $pandaProxy "pandaproxy_api_tls" (coalesce nil)) -}}
{{- $tls_12 := (get (fromJson (include "redpanda.HTTPListeners.ListenersTLS" (dict "a" (list $values.listeners.http $values.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_12)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $pandaProxy "pandaproxy_api_tls" $tls_12) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $pandaProxy) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.schemaRegistry" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $schemaReg := (dict) -}}
{{- $_ := (set $schemaReg "schema_registry_api" (get (fromJson (include "redpanda.SchemaRegistryListeners.Listeners" (dict "a" (list $values.listeners.schemaRegistry (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r"))))) "r")) -}}
{{- $_ := (set $schemaReg "schema_registry_api_tls" (coalesce nil)) -}}
{{- $tls_13 := (get (fromJson (include "redpanda.SchemaRegistryListeners.ListenersTLS" (dict "a" (list $values.listeners.schemaRegistry $values.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $tls_13)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $schemaReg "schema_registry_api_tls" $tls_13) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $schemaReg) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpcListenersTLS" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $r := $values.listeners.rpc -}}
{{- if (and (not ((or (or (get (fromJson (include "redpanda.RedpandaAtLeast_22_2_atleast_22_2_10" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.RedpandaAtLeast_22_3_atleast_22_3_13" (dict "a" (list $dot)))) "r")) (get (fromJson (include "redpanda.RedpandaAtLeast_23_1_2" (dict "a" (list $dot)))) "r")))) ((or (and (eq (toJson $r.tls.enabled) "null") $values.tls.enabled) (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $r.tls.enabled false)))) "r")))) -}}
{{- $_ := (fail (printf "Redpanda version v%s does not support TLS on the RPC port. Please upgrade. See technical service bulletin 2023-01." (trimPrefix "v" (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot)))) "r")))) -}}
{{- end -}}
{{- if (not (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $r.tls $values.tls)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $certName := $r.tls.cert -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict "enabled" true "cert_file" (printf "%s/%s/tls.crt" "/etc/tls/certs" $certName) "key_file" (printf "%s/%s/tls.key" "/etc/tls/certs" $certName) "require_client_auth" $r.tls.requireClientAuth "truststore_file" (get (fromJson (include "redpanda.InternalTLS.TrustStoreFilePath" (dict "a" (list $r.tls $values.tls)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpcListeners" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict "address" "0.0.0.0" "port" ($values.listeners.rpc.port | int))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.createInternalListenerTLSCfg" -}}
{{- $tls := (index .a 0) -}}
{{- $internal := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (not (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $internal $tls)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict "name" "internal" "enabled" true "cert_file" (printf "%s/%s/tls.crt" "/etc/tls/certs" $internal.cert) "key_file" (printf "%s/%s/tls.key" "/etc/tls/certs" $internal.cert) "require_client_auth" $internal.requireClientAuth "truststore_file" (get (fromJson (include "redpanda.InternalTLS.TrustStoreFilePath" (dict "a" (list $internal $tls)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.createInternalListenerCfg" -}}
{{- $port := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict "name" "internal" "address" "0.0.0.0" "port" $port)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAdditionalStartFlags" -}}
{{- $values := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $flags := (get (fromJson (include "redpanda.RedpandaResources.GetRedpandaFlags" (dict "a" (list $values.resources)))) "r") -}}
{{- $_ := (set $flags "--default-log-level" $values.logging.logLevel) -}}
{{- if (eq (index $values.config.node "developer_mode") true) -}}
{{- $_ := (unset $flags "--reserve-memory") -}}
{{- end -}}
{{- range $key, $value := (get (fromJson (include "redpanda.ParseCLIArgs" (dict "a" (list $values.statefulset.additionalRedpandaCmdFlags)))) "r") -}}
{{- $_ := (set $flags $key $value) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $enabledOptions := (dict "true" true "1" true "" true) -}}
{{- $lockMemory := false -}}
{{- $_657_value_14_ok_15 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $flags "--lock-memory" "")))) "r") -}}
{{- $value_14 := (index $_657_value_14_ok_15 0) -}}
{{- $ok_15 := (index $_657_value_14_ok_15 1) -}}
{{- if $ok_15 -}}
{{- $lockMemory = (ternary (index $enabledOptions $value_14) false (hasKey $enabledOptions $value_14)) -}}
{{- $_ := (unset $flags "--lock-memory") -}}
{{- end -}}
{{- $overprovisioned := false -}}
{{- $_664_value_16_ok_17 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $flags "--overprovisioned" "")))) "r") -}}
{{- $value_16 := (index $_664_value_16_ok_17 0) -}}
{{- $ok_17 := (index $_664_value_16_ok_17 1) -}}
{{- if $ok_17 -}}
{{- $overprovisioned = (ternary (index $enabledOptions $value_16) false (hasKey $enabledOptions $value_16)) -}}
{{- $_ := (unset $flags "--overprovisioned") -}}
{{- end -}}
{{- $keys := (keys $flags) -}}
{{- $keys = (sortAlpha $keys) -}}
{{- $rendered := (coalesce nil) -}}
{{- range $_, $key := $keys -}}
{{- $value := (ternary (index $flags $key) "" (hasKey $flags $key)) -}}
{{- if (eq $value "") -}}
{{- $rendered = (concat (default (list) $rendered) (list $key)) -}}
{{- else -}}
{{- $rendered = (concat (default (list) $rendered) (list (printf "%s=%s" $key $value))) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (list $lockMemory $overprovisioned $rendered)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

