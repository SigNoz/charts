{{- /* Generated from "values.go" */ -}}

{{- define "redpanda.AuditLogging.Translate" -}}
{{- $a := (index .a 0) -}}
{{- $dot := (index .a 1) -}}
{{- $isSASLEnabled := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (dict) -}}
{{- if (not (get (fromJson (include "redpanda.RedpandaAtLeast_23_3_0" (dict "a" (list $dot)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- $enabled := (and $a.enabled $isSASLEnabled) -}}
{{- $_ := (set $result "audit_enabled" $enabled) -}}
{{- if (not $enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (ne (($a.clientMaxBufferSize | int) | int) (16777216 | int)) -}}
{{- $_ := (set $result "audit_client_max_buffer_size" ($a.clientMaxBufferSize | int)) -}}
{{- end -}}
{{- if (ne (($a.queueDrainIntervalMs | int) | int) (500 | int)) -}}
{{- $_ := (set $result "audit_queue_drain_interval_ms" ($a.queueDrainIntervalMs | int)) -}}
{{- end -}}
{{- if (ne (($a.queueMaxBufferSizePerShard | int) | int) (1048576 | int)) -}}
{{- $_ := (set $result "audit_queue_max_buffer_size_per_shard" ($a.queueMaxBufferSizePerShard | int)) -}}
{{- end -}}
{{- if (ne (($a.partitions | int) | int) (12 | int)) -}}
{{- $_ := (set $result "audit_log_num_partitions" ($a.partitions | int)) -}}
{{- end -}}
{{- if (ne ($a.replicationFactor | int) (0 | int)) -}}
{{- $_ := (set $result "audit_log_replication_factor" ($a.replicationFactor | int)) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $a.enabledEventTypes)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $result "audit_enabled_event_types" $a.enabledEventTypes) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $a.excludedTopics)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $result "audit_excluded_topics" $a.excludedTopics) -}}
{{- end -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $a.excludedPrincipals)))) "r") | int) (0 | int)) -}}
{{- $_ := (set $result "audit_excluded_principals" $a.excludedPrincipals) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Auth.IsSASLEnabled" -}}
{{- $a := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (eq (toJson $a.sasl) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" false) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $a.sasl.enabled) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Auth.Translate" -}}
{{- $a := (index .a 0) -}}
{{- $isSASLEnabled := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (not $isSASLEnabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $users := (list (get (fromJson (include "redpanda.BootstrapUser.Username" (dict "a" (list $a.sasl.bootstrapUser)))) "r")) -}}
{{- range $_, $u := $a.sasl.users -}}
{{- $users = (concat (default (list) $users) (list $u.name)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict "superusers" $users)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Logging.Translate" -}}
{{- $l := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (dict) -}}
{{- $clusterID_1 := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.usageStats.clusterId "")))) "r") -}}
{{- if (ne $clusterID_1 "") -}}
{{- $_ := (set $result "cluster_id" $clusterID_1) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaResources.GetResourceRequirements" -}}
{{- $rr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (and (ne (toJson $rr.limits) "null") (ne (toJson $rr.requests) "null")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict) (dict "limits" $rr.limits "requests" $rr.requests))) | toJson -}}
{{- break -}}
{{- end -}}
{{- $reqs := (mustMergeOverwrite (dict) (dict "limits" (dict "cpu" $rr.cpu.cores "memory" $rr.memory.container.max))) -}}
{{- if (ne (toJson $rr.memory.container.min) "null") -}}
{{- $_ := (set $reqs "requests" (dict "cpu" $rr.cpu.cores "memory" $rr.memory.container.min)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $reqs) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaResources.GetRedpandaFlags" -}}
{{- $rr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $flags := (dict "--reserve-memory" (printf "%dM" ((get (fromJson (include "redpanda.RedpandaResources.reserveMemory" (dict "a" (list $rr)))) "r") | int64))) -}}
{{- $smp_2 := (get (fromJson (include "redpanda.RedpandaResources.smp" (dict "a" (list $rr)))) "r") -}}
{{- if (ne (toJson $smp_2) "null") -}}
{{- $_ := (set $flags "--smp" (printf "%d" ($smp_2 | int64))) -}}
{{- end -}}
{{- $memory_3 := (get (fromJson (include "redpanda.RedpandaResources.memory" (dict "a" (list $rr)))) "r") -}}
{{- if (ne (toJson $memory_3) "null") -}}
{{- $_ := (set $flags "--memory" (printf "%dM" ($memory_3 | int64))) -}}
{{- end -}}
{{- if (and (eq (toJson $rr.limits) "null") (eq (toJson $rr.requests) "null")) -}}
{{- $_ := (set $flags "--lock-memory" (printf "%v" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $rr.memory.enable_memory_locking false)))) "r"))) -}}
{{- end -}}
{{- if (get (fromJson (include "redpanda.RedpandaResources.GetOverProvisionValue" (dict "a" (list $rr)))) "r") -}}
{{- $_ := (set $flags "--overprovisioned" "") -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $flags) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaResources.GetOverProvisionValue" -}}
{{- $rr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (and (ne (toJson $rr.limits) "null") (ne (toJson $rr.requests) "null")) -}}
{{- $_449_cpuReq_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list ($rr.requests) "cpu" "0")))) "r") -}}
{{- $cpuReq := (index $_449_cpuReq_ok 0) -}}
{{- $ok := (index $_449_cpuReq_ok 1) -}}
{{- if (not $ok) -}}
{{- $_451_cpuReq_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list ($rr.limits) "cpu" "0")))) "r") -}}
{{- $cpuReq = (index $_451_cpuReq_ok 0) -}}
{{- $ok = (index $_451_cpuReq_ok 1) -}}
{{- end -}}
{{- if (and $ok (lt ((get (fromJson (include "_shims.resource_MilliValue" (dict "a" (list $cpuReq)))) "r") | int64) (1000 | int64))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" true) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" false) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (lt ((get (fromJson (include "_shims.resource_MilliValue" (dict "a" (list $rr.cpu.cores)))) "r") | int64) (1000 | int64)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" true) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $rr.cpu.overprovisioned false)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaResources.smp" -}}
{{- $rr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (and (ne (toJson $rr.limits) "null") (ne (toJson $rr.requests) "null")) -}}
{{- $_475_cpuReq_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list ($rr.requests) "cpu" "0")))) "r") -}}
{{- $cpuReq := (index $_475_cpuReq_ok 0) -}}
{{- $ok := (index $_475_cpuReq_ok 1) -}}
{{- if (not $ok) -}}
{{- $_477_cpuReq_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list ($rr.limits) "cpu" "0")))) "r") -}}
{{- $cpuReq = (index $_477_cpuReq_ok 0) -}}
{{- $ok = (index $_477_cpuReq_ok 1) -}}
{{- end -}}
{{- if (not $ok) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $smp := ((div ((get (fromJson (include "_shims.resource_MilliValue" (dict "a" (list $cpuReq)))) "r") | int64) (1000 | int64)) | int64) -}}
{{- if (lt $smp (1 | int64)) -}}
{{- $smp = (1 | int64) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $smp) | toJson -}}
{{- break -}}
{{- end -}}
{{- $coresInMillies_4 := ((get (fromJson (include "_shims.resource_MilliValue" (dict "a" (list $rr.cpu.cores)))) "r") | int64) -}}
{{- if (lt $coresInMillies_4 (1000 | int64)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" ((1 | int64) | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (((get (fromJson (include "_shims.resource_Value" (dict "a" (list $rr.cpu.cores)))) "r") | int64) | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaResources.memory" -}}
{{- $rr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (and (ne (toJson $rr.limits) "null") (ne (toJson $rr.requests) "null")) -}}
{{- $_534_memReq_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list ($rr.requests) "memory" "0")))) "r") -}}
{{- $memReq := (index $_534_memReq_ok 0) -}}
{{- $ok := (index $_534_memReq_ok 1) -}}
{{- if (not $ok) -}}
{{- $_536_memReq_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list ($rr.limits) "memory" "0")))) "r") -}}
{{- $memReq = (index $_536_memReq_ok 0) -}}
{{- $ok = (index $_536_memReq_ok 1) -}}
{{- end -}}
{{- if (not $ok) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $memory := (((mulf (((get (fromJson (include "_shims.resource_Value" (dict "a" (list $memReq)))) "r") | int64) | float64) 0.90) | float64) | int64) -}}
{{- $_is_returning = true -}}
{{- (dict "r" ((div $memory ((mul (1024 | int) (1024 | int)))) | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $memory := ((0 | int64) | int64) -}}
{{- $containerMemory := ((get (fromJson (include "redpanda.RedpandaResources.containerMemory" (dict "a" (list $rr)))) "r") | int64) -}}
{{- $rpMem_5 := $rr.memory.redpanda -}}
{{- if (and (ne (toJson $rpMem_5) "null") (ne (toJson $rpMem_5.memory) "null")) -}}
{{- $memory = ((div ((get (fromJson (include "_shims.resource_Value" (dict "a" (list $rpMem_5.memory)))) "r") | int64) ((mul (1024 | int) (1024 | int)))) | int64) -}}
{{- else -}}
{{- $memory = (((mulf ($containerMemory | float64) 0.8) | float64) | int64) -}}
{{- end -}}
{{- if (eq $memory (0 | int64)) -}}
{{- $_ := (fail "unable to get memory value redpanda-memory") -}}
{{- end -}}
{{- if (lt $memory (256 | int64)) -}}
{{- $_ := (fail (printf "%d is below the minimum value for Redpanda" $memory)) -}}
{{- end -}}
{{- if (gt ((add $memory (((get (fromJson (include "redpanda.RedpandaResources.reserveMemory" (dict "a" (list $rr)))) "r") | int64) | int64)) | int64) $containerMemory) -}}
{{- $_ := (fail (printf "Not enough container memory for Redpanda memory values where Redpanda: %d, reserve: %d, container: %d" $memory ((get (fromJson (include "redpanda.RedpandaResources.reserveMemory" (dict "a" (list $rr)))) "r") | int64) $containerMemory)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $memory) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaResources.reserveMemory" -}}
{{- $rr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (and (ne (toJson $rr.limits) "null") (ne (toJson $rr.requests) "null")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (0 | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $rpMem_6 := $rr.memory.redpanda -}}
{{- if (and (ne (toJson $rpMem_6) "null") (ne (toJson $rpMem_6.reserveMemory) "null")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" ((div ((get (fromJson (include "_shims.resource_Value" (dict "a" (list $rpMem_6.reserveMemory)))) "r") | int64) ((mul (1024 | int) (1024 | int)))) | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" ((add (((mulf (((get (fromJson (include "redpanda.RedpandaResources.containerMemory" (dict "a" (list $rr)))) "r") | int64) | float64) 0.002) | float64) | int64) (200 | int64)) | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaResources.containerMemory" -}}
{{- $rr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $rr.memory.container.min) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" ((div ((get (fromJson (include "_shims.resource_Value" (dict "a" (list $rr.memory.container.min)))) "r") | int64) ((mul (1024 | int) (1024 | int)))) | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" ((div ((get (fromJson (include "_shims.resource_Value" (dict "a" (list $rr.memory.container.max)))) "r") | int64) ((mul (1024 | int) (1024 | int)))) | int64)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.IsTieredStorageEnabled" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $conf := (get (fromJson (include "redpanda.Storage.GetTieredStorageConfig" (dict "a" (list $s)))) "r") -}}
{{- $_654_b_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list $conf "cloud_storage_enabled" (coalesce nil))))) "r") -}}
{{- $b := (index $_654_b_ok 0) -}}
{{- $ok := (index $_654_b_ok 1) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and $ok (get (fromJson (include "_shims.typeassertion" (dict "a" (list "bool" $b)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.GetTieredStorageConfig" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $s.tieredConfig)))) "r") | int) (0 | int)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tieredConfig) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tiered.config) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.GetTieredStorageHostPath" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $hp := $s.tieredStorageHostPath -}}
{{- if (empty $hp) -}}
{{- $hp = $s.tiered.hostPath -}}
{{- end -}}
{{- if (empty $hp) -}}
{{- $_ := (fail (printf `storage.tiered.mountType is "%s" but storage.tiered.hostPath is empty` $s.tiered.mountType)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $hp) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.TieredCacheDirectory" -}}
{{- $s := (index .a 0) -}}
{{- $dot := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_683_dir_7_ok_8 := (get (fromJson (include "_shims.typetest" (dict "a" (list "string" (index $values.config.node "cloud_storage_cache_directory") "")))) "r") -}}
{{- $dir_7 := (index $_683_dir_7_ok_8 0) -}}
{{- $ok_8 := (index $_683_dir_7_ok_8 1) -}}
{{- if $ok_8 -}}
{{- $_is_returning = true -}}
{{- (dict "r" $dir_7) | toJson -}}
{{- break -}}
{{- end -}}
{{- $tieredConfig := (get (fromJson (include "redpanda.Storage.GetTieredStorageConfig" (dict "a" (list $values.storage)))) "r") -}}
{{- $_692_dir_9_ok_10 := (get (fromJson (include "_shims.typetest" (dict "a" (list "string" (index $tieredConfig "cloud_storage_cache_directory") "")))) "r") -}}
{{- $dir_9 := (index $_692_dir_9_ok_10 0) -}}
{{- $ok_10 := (index $_692_dir_9_ok_10 1) -}}
{{- if $ok_10 -}}
{{- $_is_returning = true -}}
{{- (dict "r" $dir_9) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" "/var/lib/redpanda/data/cloud_storage_cache") | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.TieredMountType" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (and (ne (toJson $s.tieredStoragePersistentVolume) "null") $s.tieredStoragePersistentVolume.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" "persistentVolume") | toJson -}}
{{- break -}}
{{- end -}}
{{- if (not (empty $s.tieredStorageHostPath)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" "hostPath") | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tiered.mountType) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.TieredPersistentVolumeLabels" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $s.tieredStoragePersistentVolume) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tieredStoragePersistentVolume.labels) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tiered.persistentVolume.labels) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.TieredPersistentVolumeAnnotations" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $s.tieredStoragePersistentVolume) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tieredStoragePersistentVolume.annotations) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tiered.persistentVolume.annotations) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.TieredPersistentVolumeStorageClass" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $s.tieredStoragePersistentVolume) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tieredStoragePersistentVolume.storageClass) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $s.tiered.persistentVolume.storageClass) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Storage.StorageMinFreeBytes" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (and (ne (toJson $s.persistentVolume) "null") (not $s.persistentVolume.enabled)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (5368709120 | int)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $minimumFreeBytes := ((mulf (((get (fromJson (include "_shims.resource_Value" (dict "a" (list $s.persistentVolume.size)))) "r") | int64) | float64) 0.05) | float64) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (min (5368709120 | int) ($minimumFreeBytes | int64))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Tuning.Translate" -}}
{{- $t := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (dict) -}}
{{- $s := (toJson $t) -}}
{{- $tune := (fromJson $s) -}}
{{- $_902_m_ok := (get (fromJson (include "_shims.typetest" (dict "a" (list (printf "map[%s]%s" "string" "interface {}") $tune (coalesce nil))))) "r") -}}
{{- $m := (index $_902_m_ok 0) -}}
{{- $ok := (index $_902_m_ok 1) -}}
{{- if (not $ok) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (dict)) | toJson -}}
{{- break -}}
{{- end -}}
{{- range $k, $v := $m -}}
{{- $_ := (set $result $k $v) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Sidecars.ShouldCreateRBAC" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (or ((and $s.controllers.enabled $s.controllers.createRBAC)) (get (fromJson (include "redpanda.Sidecars.AdditionalSidecarControllersEnabled" (dict "a" (list $s)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Sidecars.AdditionalSidecarControllersEnabled" -}}
{{- $s := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (or $s.pvcUnbinder.enabled $s.brokerDecommissioner.enabled)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Listeners.CreateSeedServers" -}}
{{- $l := (index .a 0) -}}
{{- $replicas := (index .a 1) -}}
{{- $fullname := (index .a 2) -}}
{{- $internalDomain := (index .a 3) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (coalesce nil) -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) ($replicas|int) (1|int) -}}
{{- $result = (concat (default (list) $result) (list (dict "host" (dict "address" (printf "%s-%d.%s" $fullname $i $internalDomain) "port" ($l.rpc.port | int))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Listeners.AdminList" -}}
{{- $l := (index .a 0) -}}
{{- $replicas := (index .a 1) -}}
{{- $fullname := (index .a 2) -}}
{{- $internalDomain := (index .a 3) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.ServerList" (dict "a" (list $replicas "" $fullname $internalDomain ($l.admin.port | int))))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Listeners.SchemaRegistryList" -}}
{{- $l := (index .a 0) -}}
{{- $replicas := (index .a 1) -}}
{{- $fullname := (index .a 2) -}}
{{- $internalDomain := (index .a 3) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.ServerList" (dict "a" (list $replicas "" $fullname $internalDomain ($l.schemaRegistry.port | int))))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ServerList" -}}
{{- $replicas := (index .a 0) -}}
{{- $prefix := (index .a 1) -}}
{{- $fullname := (index .a 2) -}}
{{- $internalDomain := (index .a 3) -}}
{{- $port := (index .a 4) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (coalesce nil) -}}
{{- range $_, $i := untilStep (((0 | int) | int)|int) ($replicas|int) (1|int) -}}
{{- $result = (concat (default (list) $result) (list (printf "%s%s-%d.%s:%d" $prefix $fullname $i $internalDomain ($port | int)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Listeners.TrustStoreVolume" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $cmSources := (dict) -}}
{{- $secretSources := (dict) -}}
{{- range $_, $ts := (get (fromJson (include "redpanda.Listeners.TrustStores" (dict "a" (list $l $tls)))) "r") -}}
{{- $projection := (get (fromJson (include "redpanda.TrustStore.VolumeProjection" (dict "a" (list $ts)))) "r") -}}
{{- if (ne (toJson $projection.secret) "null") -}}
{{- $_ := (set $secretSources $projection.secret.name (concat (default (list) (index $secretSources $projection.secret.name)) (default (list) $projection.secret.items))) -}}
{{- else -}}
{{- $_ := (set $cmSources $projection.configMap.name (concat (default (list) (index $cmSources $projection.configMap.name)) (default (list) $projection.configMap.items))) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $sources := (coalesce nil) -}}
{{- range $_, $name := (sortAlpha (keys $cmSources)) -}}
{{- $keys := (index $cmSources $name) -}}
{{- $sources = (concat (default (list) $sources) (list (mustMergeOverwrite (dict) (dict "configMap" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" $name)) (dict "items" (get (fromJson (include "redpanda.dedupKeyToPaths" (dict "a" (list $keys)))) "r"))))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- range $_, $name := (sortAlpha (keys $secretSources)) -}}
{{- $keys := (index $secretSources $name) -}}
{{- $sources = (concat (default (list) $sources) (list (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" $name)) (dict "items" (get (fromJson (include "redpanda.dedupKeyToPaths" (dict "a" (list $keys)))) "r"))))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- if (lt ((get (fromJson (include "_shims.len" (dict "a" (list $sources)))) "r") | int) (1 | int)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "projected" (mustMergeOverwrite (dict "sources" (coalesce nil)) (dict "sources" $sources)))) (dict "name" "truststores"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.dedupKeyToPaths" -}}
{{- $items := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $seen := (dict) -}}
{{- $deduped := (coalesce nil) -}}
{{- range $_, $item := $items -}}
{{- $_1060___ok_11 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $seen $item.key false)))) "r") -}}
{{- $_ := (index $_1060___ok_11 0) -}}
{{- $ok_11 := (index $_1060___ok_11 1) -}}
{{- if $ok_11 -}}
{{- continue -}}
{{- end -}}
{{- $deduped = (concat (default (list) $deduped) (list $item)) -}}
{{- $_ := (set $seen $item.key true) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $deduped) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Listeners.TrustStores" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $tss := (get (fromJson (include "redpanda.KafkaListeners.TrustStores" (dict "a" (list $l.kafka $tls)))) "r") -}}
{{- $tss = (concat (default (list) $tss) (default (list) (get (fromJson (include "redpanda.AdminListeners.TrustStores" (dict "a" (list $l.admin $tls)))) "r"))) -}}
{{- $tss = (concat (default (list) $tss) (default (list) (get (fromJson (include "redpanda.HTTPListeners.TrustStores" (dict "a" (list $l.http $tls)))) "r"))) -}}
{{- $tss = (concat (default (list) $tss) (default (list) (get (fromJson (include "redpanda.SchemaRegistryListeners.TrustStores" (dict "a" (list $l.schemaRegistry $tls)))) "r"))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $tss) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Config.CreateRPKConfiguration" -}}
{{- $c := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (dict) -}}
{{- range $k, $v := $c.rpk -}}
{{- $_ := (set $result $k $v) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TLSCertMap.MustGet" -}}
{{- $m := (index .a 0) -}}
{{- $name := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_1151_cert_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list $m $name (dict "enabled" (coalesce nil) "caEnabled" false "applyInternalDNSNames" (coalesce nil) "duration" "" "issuerRef" (coalesce nil) "secretRef" (coalesce nil) "clientSecretRef" (coalesce nil)))))) "r") -}}
{{- $cert := (index $_1151_cert_ok 0) -}}
{{- $ok := (index $_1151_cert_ok 1) -}}
{{- if (not $ok) -}}
{{- $_ := (fail (printf "Certificate %q referenced, but not found in the tls.certs map" $name)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $cert) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.BootstrapUser.BootstrapEnvironment" -}}
{{- $b := (index .a 0) -}}
{{- $fullname := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) (get (fromJson (include "redpanda.BootstrapUser.RpkEnvironment" (dict "a" (list $b $fullname)))) "r")) (list (mustMergeOverwrite (dict "name" "") (dict "name" "RP_BOOTSTRAP_USER" "value" "$(RPK_USER):$(RPK_PASS):$(RPK_SASL_MECHANISM)"))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.BootstrapUser.Username" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $b.name) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $b.name) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" "kubernetes-controller") | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.BootstrapUser.RpkEnvironment" -}}
{{- $b := (index .a 0) -}}
{{- $fullname := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (list (mustMergeOverwrite (dict "name" "") (dict "name" "RPK_PASS" "valueFrom" (mustMergeOverwrite (dict) (dict "secretKeyRef" (get (fromJson (include "redpanda.BootstrapUser.SecretKeySelector" (dict "a" (list $b $fullname)))) "r"))))) (mustMergeOverwrite (dict "name" "") (dict "name" "RPK_USER" "value" (get (fromJson (include "redpanda.BootstrapUser.Username" (dict "a" (list $b)))) "r"))) (mustMergeOverwrite (dict "name" "") (dict "name" "RPK_SASL_MECHANISM" "value" (get (fromJson (include "redpanda.BootstrapUser.GetMechanism" (dict "a" (list $b)))) "r"))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.BootstrapUser.GetMechanism" -}}
{{- $b := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (eq $b.mechanism "") -}}
{{- $_is_returning = true -}}
{{- (dict "r" "SCRAM-SHA-256") | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $b.mechanism) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.BootstrapUser.SecretKeySelector" -}}
{{- $b := (index .a 0) -}}
{{- $fullname := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $b.secretKeyRef) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $b.secretKeyRef) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "key" "") (mustMergeOverwrite (dict) (dict "name" (printf "%s-bootstrap-user" $fullname))) (dict "key" "password"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TrustStore.TrustStoreFilePath" -}}
{{- $t := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s/%s" "/etc/truststores" (get (fromJson (include "redpanda.TrustStore.RelativePath" (dict "a" (list $t)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TrustStore.RelativePath" -}}
{{- $t := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $t.configMapKeyRef) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "configmaps/%s-%s" $t.configMapKeyRef.name $t.configMapKeyRef.key)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "secrets/%s-%s" $t.secretKeyRef.name $t.secretKeyRef.key)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TrustStore.VolumeProjection" -}}
{{- $t := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $t.configMapKeyRef) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict) (dict "configMap" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" $t.configMapKeyRef.name)) (dict "items" (list (mustMergeOverwrite (dict "key" "" "path" "") (dict "key" $t.configMapKeyRef.key "path" (get (fromJson (include "redpanda.TrustStore.RelativePath" (dict "a" (list $t)))) "r"))))))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" $t.secretKeyRef.name)) (dict "items" (list (mustMergeOverwrite (dict "key" "" "path" "") (dict "key" $t.secretKeyRef.key "path" (get (fromJson (include "redpanda.TrustStore.RelativePath" (dict "a" (list $t)))) "r"))))))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.InternalTLS.IsEnabled" -}}
{{- $t := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $t.enabled $tls.enabled)))) "r") (ne $t.cert ""))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.InternalTLS.TrustStoreFilePath" -}}
{{- $t := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $t.trustStore) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.TrustStore.TrustStoreFilePath" (dict "a" (list $t.trustStore)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (get (fromJson (include "redpanda.TLSCertMap.MustGet" (dict "a" (list (deepCopy $tls.certs) $t.cert)))) "r").caEnabled -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s/%s/ca.crt" "/etc/tls/certs" $t.cert)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" "/etc/ssl/certs/ca-certificates.crt") | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.InternalTLS.ServerCAPath" -}}
{{- $t := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $t.trustStore) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.TrustStore.TrustStoreFilePath" (dict "a" (list $t.trustStore)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (get (fromJson (include "redpanda.TLSCertMap.MustGet" (dict "a" (list (deepCopy $tls.certs) $t.cert)))) "r").caEnabled -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s/%s/ca.crt" "/etc/tls/certs" $t.cert)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s/%s/tls.crt" "/etc/tls/certs" $t.cert)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ExternalTLS.GetCert" -}}
{{- $t := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- $tls := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.TLSCertMap.MustGet" (dict "a" (list (deepCopy $tls.certs) (get (fromJson (include "redpanda.ExternalTLS.GetCertName" (dict "a" (list $t $i)))) "r"))))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ExternalTLS.GetCertName" -}}
{{- $t := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $t.cert $i.cert)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ExternalTLS.TrustStoreFilePath" -}}
{{- $t := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- $tls := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $t.trustStore) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.TrustStore.TrustStoreFilePath" (dict "a" (list $t.trustStore)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (get (fromJson (include "redpanda.ExternalTLS.GetCert" (dict "a" (list $t $i $tls)))) "r").caEnabled -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s/%s/ca.crt" "/etc/tls/certs" (get (fromJson (include "redpanda.ExternalTLS.GetCertName" (dict "a" (list $t $i)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" "/etc/ssl/certs/ca-certificates.crt") | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ExternalTLS.IsEnabled" -}}
{{- $t := (index .a 0) -}}
{{- $i := (index .a 1) -}}
{{- $tls := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (eq (toJson $t) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" false) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and (ne (get (fromJson (include "redpanda.ExternalTLS.GetCertName" (dict "a" (list $t $i)))) "r") "") (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $t.enabled (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $i $tls)))) "r"))))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.AdminListeners.ConsoleTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $t := (mustMergeOverwrite (dict "enabled" false "caFilepath" "" "certFilepath" "" "keyFilepath" "" "insecureSkipTlsVerify" false) (dict "enabled" (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r"))) -}}
{{- if (not $t.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- $adminAPIPrefix := (printf "%s/%s" "/etc/tls/certs" $l.tls.cert) -}}
{{- if (get (fromJson (include "redpanda.TLSCertMap.MustGet" (dict "a" (list (deepCopy $tls.certs) $l.tls.cert)))) "r").caEnabled -}}
{{- $_ := (set $t "caFilepath" (printf "%s/ca.crt" $adminAPIPrefix)) -}}
{{- else -}}
{{- $_ := (set $t "caFilepath" (printf "%s/tls.crt" $adminAPIPrefix)) -}}
{{- end -}}
{{- if (not $l.tls.requireClientAuth) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_ := (set $t "certFilepath" (printf "%s/tls.crt" $adminAPIPrefix)) -}}
{{- $_ := (set $t "keyFilepath" (printf "%s/tls.key" $adminAPIPrefix)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.AdminListeners.Listeners" -}}
{{- $l := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $admin := (list (get (fromJson (include "redpanda.createInternalListenerCfg" (dict "a" (list ($l.port | int))))) "r")) -}}
{{- range $k, $lis := $l.external -}}
{{- if (not (get (fromJson (include "redpanda.AdminExternal.IsEnabled" (dict "a" (list $lis)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $admin = (concat (default (list) $admin) (list (dict "name" $k "port" ($lis.port | int) "address" "0.0.0.0"))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $admin) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.AdminListeners.ListenersTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $admin := (list) -}}
{{- $internal := (get (fromJson (include "redpanda.createInternalListenerTLSCfg" (dict "a" (list $tls $l.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $internal)))) "r") | int) (0 | int)) -}}
{{- $admin = (concat (default (list) $admin) (list $internal)) -}}
{{- end -}}
{{- range $k, $lis := $l.external -}}
{{- if (or (not (get (fromJson (include "redpanda.AdminExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) -}}
{{- continue -}}
{{- end -}}
{{- $certName := (get (fromJson (include "redpanda.ExternalTLS.GetCertName" (dict "a" (list $lis.tls $l.tls)))) "r") -}}
{{- $admin = (concat (default (list) $admin) (list (dict "name" $k "enabled" true "cert_file" (printf "%s/%s/tls.crt" "/etc/tls/certs" $certName) "key_file" (printf "%s/%s/tls.key" "/etc/tls/certs" $certName) "require_client_auth" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $lis.tls.requireClientAuth false)))) "r") "truststore_file" (get (fromJson (include "redpanda.ExternalTLS.TrustStoreFilePath" (dict "a" (list $lis.tls $l.tls $tls)))) "r")))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $admin) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.AdminListeners.TrustStores" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $tss := (list) -}}
{{- if (and (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r") (ne (toJson $l.tls.trustStore) "null")) -}}
{{- $tss = (concat (default (list) $tss) (list $l.tls.trustStore)) -}}
{{- end -}}
{{- range $_, $key := (sortAlpha (keys $l.external)) -}}
{{- $lis := (ternary (index $l.external $key) (dict "enabled" (coalesce nil) "advertisedPorts" (coalesce nil) "port" 0 "nodePort" (coalesce nil) "tls" (coalesce nil)) (hasKey $l.external $key)) -}}
{{- if (or (or (not (get (fromJson (include "redpanda.AdminExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) (eq (toJson $lis.tls.trustStore) "null")) -}}
{{- continue -}}
{{- end -}}
{{- $tss = (concat (default (list) $tss) (list $lis.tls.trustStore)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $tss) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.AdminExternal.IsEnabled" -}}
{{- $l := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.enabled true)))) "r") (gt ($l.port | int) (0 | int)))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.HTTPListeners.Listeners" -}}
{{- $l := (index .a 0) -}}
{{- $saslEnabled := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $internal := (get (fromJson (include "redpanda.createInternalListenerCfg" (dict "a" (list ($l.port | int))))) "r") -}}
{{- if $saslEnabled -}}
{{- $_ := (set $internal "authentication_method" "http_basic") -}}
{{- end -}}
{{- $am_12 := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.authenticationMethod "")))) "r") -}}
{{- if (ne $am_12 "") -}}
{{- $_ := (set $internal "authentication_method" $am_12) -}}
{{- end -}}
{{- $result := (list $internal) -}}
{{- range $k, $l := $l.external -}}
{{- if (not (get (fromJson (include "redpanda.HTTPExternal.IsEnabled" (dict "a" (list $l)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $listener := (dict "name" $k "port" ($l.port | int) "address" "0.0.0.0") -}}
{{- if $saslEnabled -}}
{{- $_ := (set $listener "authentication_method" "http_basic") -}}
{{- end -}}
{{- $am_13 := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.authenticationMethod "")))) "r") -}}
{{- if (ne $am_13 "") -}}
{{- $_ := (set $listener "authentication_method" $am_13) -}}
{{- end -}}
{{- $result = (concat (default (list) $result) (list $listener)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.HTTPListeners.ListenersTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $pp := (list) -}}
{{- $internal := (get (fromJson (include "redpanda.createInternalListenerTLSCfg" (dict "a" (list $tls $l.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $internal)))) "r") | int) (0 | int)) -}}
{{- $pp = (concat (default (list) $pp) (list $internal)) -}}
{{- end -}}
{{- range $k, $lis := $l.external -}}
{{- if (or (not (get (fromJson (include "redpanda.HTTPExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) -}}
{{- continue -}}
{{- end -}}
{{- $certName := (get (fromJson (include "redpanda.ExternalTLS.GetCertName" (dict "a" (list $lis.tls $l.tls)))) "r") -}}
{{- $pp = (concat (default (list) $pp) (list (dict "name" $k "enabled" true "cert_file" (printf "%s/%s/tls.crt" "/etc/tls/certs" $certName) "key_file" (printf "%s/%s/tls.key" "/etc/tls/certs" $certName) "require_client_auth" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $lis.tls.requireClientAuth false)))) "r") "truststore_file" (get (fromJson (include "redpanda.ExternalTLS.TrustStoreFilePath" (dict "a" (list $lis.tls $l.tls $tls)))) "r")))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $pp) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.HTTPListeners.TrustStores" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $tss := (coalesce nil) -}}
{{- if (and (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r") (ne (toJson $l.tls.trustStore) "null")) -}}
{{- $tss = (concat (default (list) $tss) (list $l.tls.trustStore)) -}}
{{- end -}}
{{- range $_, $lis := $l.external -}}
{{- if (or (or (not (get (fromJson (include "redpanda.HTTPExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) (eq (toJson $lis.tls.trustStore) "null")) -}}
{{- continue -}}
{{- end -}}
{{- $tss = (concat (default (list) $tss) (list $lis.tls.trustStore)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $tss) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.HTTPExternal.IsEnabled" -}}
{{- $l := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.enabled true)))) "r") (gt ($l.port | int) (0 | int)))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.KafkaListeners.Listeners" -}}
{{- $l := (index .a 0) -}}
{{- $auth := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $internal := (get (fromJson (include "redpanda.createInternalListenerCfg" (dict "a" (list ($l.port | int))))) "r") -}}
{{- if (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $auth)))) "r") -}}
{{- $_ := (set $internal "authentication_method" "sasl") -}}
{{- end -}}
{{- $am_14 := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.authenticationMethod "")))) "r") -}}
{{- if (ne $am_14 "") -}}
{{- $_ := (set $internal "authentication_method" $am_14) -}}
{{- end -}}
{{- $kafka := (list $internal) -}}
{{- range $k, $l := $l.external -}}
{{- if (not (get (fromJson (include "redpanda.KafkaExternal.IsEnabled" (dict "a" (list $l)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $listener := (dict "name" $k "port" ($l.port | int) "address" "0.0.0.0") -}}
{{- if (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $auth)))) "r") -}}
{{- $_ := (set $listener "authentication_method" "sasl") -}}
{{- end -}}
{{- $am_15 := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.authenticationMethod "")))) "r") -}}
{{- if (ne $am_15 "") -}}
{{- $_ := (set $listener "authentication_method" $am_15) -}}
{{- end -}}
{{- $kafka = (concat (default (list) $kafka) (list $listener)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $kafka) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.KafkaListeners.ListenersTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $kafka := (list) -}}
{{- $internal := (get (fromJson (include "redpanda.createInternalListenerTLSCfg" (dict "a" (list $tls $l.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $internal)))) "r") | int) (0 | int)) -}}
{{- $kafka = (concat (default (list) $kafka) (list $internal)) -}}
{{- end -}}
{{- range $k, $lis := $l.external -}}
{{- if (or (not (get (fromJson (include "redpanda.KafkaExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) -}}
{{- continue -}}
{{- end -}}
{{- $certName := (get (fromJson (include "redpanda.ExternalTLS.GetCertName" (dict "a" (list $lis.tls $l.tls)))) "r") -}}
{{- $kafka = (concat (default (list) $kafka) (list (dict "name" $k "enabled" true "cert_file" (printf "%s/%s/tls.crt" "/etc/tls/certs" $certName) "key_file" (printf "%s/%s/tls.key" "/etc/tls/certs" $certName) "require_client_auth" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $lis.tls.requireClientAuth false)))) "r") "truststore_file" (get (fromJson (include "redpanda.ExternalTLS.TrustStoreFilePath" (dict "a" (list $lis.tls $l.tls $tls)))) "r")))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $kafka) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.KafkaListeners.TrustStores" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $tss := (coalesce nil) -}}
{{- if (and (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r") (ne (toJson $l.tls.trustStore) "null")) -}}
{{- $tss = (concat (default (list) $tss) (list $l.tls.trustStore)) -}}
{{- end -}}
{{- range $_, $key := (sortAlpha (keys $l.external)) -}}
{{- $lis := (ternary (index $l.external $key) (dict "enabled" (coalesce nil) "advertisedPorts" (coalesce nil) "port" 0 "nodePort" (coalesce nil) "authenticationMethod" (coalesce nil) "prefixTemplate" (coalesce nil) "tls" (coalesce nil)) (hasKey $l.external $key)) -}}
{{- if (or (or (not (get (fromJson (include "redpanda.KafkaExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) (eq (toJson $lis.tls.trustStore) "null")) -}}
{{- continue -}}
{{- end -}}
{{- $tss = (concat (default (list) $tss) (list $lis.tls.trustStore)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $tss) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.KafkaListeners.ConsoleTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $t := (mustMergeOverwrite (dict "enabled" false "caFilepath" "" "certFilepath" "" "keyFilepath" "" "insecureSkipTlsVerify" false) (dict "enabled" (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r"))) -}}
{{- if (not $t.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- $kafkaPathPrefix := (printf "%s/%s" "/etc/tls/certs" $l.tls.cert) -}}
{{- if (get (fromJson (include "redpanda.TLSCertMap.MustGet" (dict "a" (list (deepCopy $tls.certs) $l.tls.cert)))) "r").caEnabled -}}
{{- $_ := (set $t "caFilepath" (printf "%s/ca.crt" $kafkaPathPrefix)) -}}
{{- else -}}
{{- $_ := (set $t "caFilepath" (printf "%s/tls.crt" $kafkaPathPrefix)) -}}
{{- end -}}
{{- if (not $l.tls.requireClientAuth) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_ := (set $t "certFilepath" (printf "%s/tls.crt" $kafkaPathPrefix)) -}}
{{- $_ := (set $t "keyFilepath" (printf "%s/tls.key" $kafkaPathPrefix)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.KafkaListeners.ConnectorsTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- $fullName := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $t := (mustMergeOverwrite (dict "enabled" false "ca" (dict "secretRef" "" "secretNameOverwrite" "") "cert" (dict "secretRef" "" "secretNameOverwrite" "") "key" (dict "secretRef" "" "secretNameOverwrite" "")) (dict "enabled" (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r"))) -}}
{{- if (not $t.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_ := (set $t "ca" (mustMergeOverwrite (dict "secretRef" "" "secretNameOverwrite" "") (dict "secretRef" (printf "%s-default-cert" $fullName)))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.KafkaExternal.IsEnabled" -}}
{{- $l := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.enabled true)))) "r") (gt ($l.port | int) (0 | int)))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SchemaRegistryListeners.Listeners" -}}
{{- $l := (index .a 0) -}}
{{- $saslEnabled := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $internal := (get (fromJson (include "redpanda.createInternalListenerCfg" (dict "a" (list ($l.port | int))))) "r") -}}
{{- if $saslEnabled -}}
{{- $_ := (set $internal "authentication_method" "http_basic") -}}
{{- end -}}
{{- $am_16 := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.authenticationMethod "")))) "r") -}}
{{- if (ne $am_16 "") -}}
{{- $_ := (set $internal "authentication_method" $am_16) -}}
{{- end -}}
{{- $result := (list $internal) -}}
{{- range $k, $l := $l.external -}}
{{- if (not (get (fromJson (include "redpanda.SchemaRegistryExternal.IsEnabled" (dict "a" (list $l)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $listener := (dict "name" $k "port" ($l.port | int) "address" "0.0.0.0") -}}
{{- if $saslEnabled -}}
{{- $_ := (set $listener "authentication_method" "http_basic") -}}
{{- end -}}
{{- $am_17 := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.authenticationMethod "")))) "r") -}}
{{- if (ne $am_17 "") -}}
{{- $_ := (set $listener "authentication_method" $am_17) -}}
{{- end -}}
{{- $result = (concat (default (list) $result) (list $listener)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SchemaRegistryListeners.ListenersTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $listeners := (list) -}}
{{- $internal := (get (fromJson (include "redpanda.createInternalListenerTLSCfg" (dict "a" (list $tls $l.tls)))) "r") -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $internal)))) "r") | int) (0 | int)) -}}
{{- $listeners = (concat (default (list) $listeners) (list $internal)) -}}
{{- end -}}
{{- range $k, $lis := $l.external -}}
{{- if (or (not (get (fromJson (include "redpanda.SchemaRegistryExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) -}}
{{- continue -}}
{{- end -}}
{{- $certName := (get (fromJson (include "redpanda.ExternalTLS.GetCertName" (dict "a" (list $lis.tls $l.tls)))) "r") -}}
{{- $listeners = (concat (default (list) $listeners) (list (dict "name" $k "enabled" true "cert_file" (printf "%s/%s/tls.crt" "/etc/tls/certs" $certName) "key_file" (printf "%s/%s/tls.key" "/etc/tls/certs" $certName) "require_client_auth" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $lis.tls.requireClientAuth false)))) "r") "truststore_file" (get (fromJson (include "redpanda.ExternalTLS.TrustStoreFilePath" (dict "a" (list $lis.tls $l.tls $tls)))) "r")))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $listeners) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SchemaRegistryListeners.TrustStores" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $tss := (coalesce nil) -}}
{{- if (and (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r") (ne (toJson $l.tls.trustStore) "null")) -}}
{{- $tss = (concat (default (list) $tss) (list $l.tls.trustStore)) -}}
{{- end -}}
{{- range $_, $lis := $l.external -}}
{{- if (or (or (not (get (fromJson (include "redpanda.SchemaRegistryExternal.IsEnabled" (dict "a" (list $lis)))) "r")) (not (get (fromJson (include "redpanda.ExternalTLS.IsEnabled" (dict "a" (list $lis.tls $l.tls $tls)))) "r"))) (eq (toJson $lis.tls.trustStore) "null")) -}}
{{- continue -}}
{{- end -}}
{{- $tss = (concat (default (list) $tss) (list $lis.tls.trustStore)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $tss) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SchemaRegistryListeners.ConsoleTLS" -}}
{{- $l := (index .a 0) -}}
{{- $tls := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $t := (mustMergeOverwrite (dict "enabled" false "caFilepath" "" "certFilepath" "" "keyFilepath" "" "insecureSkipTlsVerify" false) (dict "enabled" (get (fromJson (include "redpanda.InternalTLS.IsEnabled" (dict "a" (list $l.tls $tls)))) "r"))) -}}
{{- if (not $t.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- $schemaRegistryPrefix := (printf "%s/%s" "/etc/tls/certs" $l.tls.cert) -}}
{{- if (get (fromJson (include "redpanda.TLSCertMap.MustGet" (dict "a" (list (deepCopy $tls.certs) $l.tls.cert)))) "r").caEnabled -}}
{{- $_ := (set $t "caFilepath" (printf "%s/ca.crt" $schemaRegistryPrefix)) -}}
{{- else -}}
{{- $_ := (set $t "caFilepath" (printf "%s/tls.crt" $schemaRegistryPrefix)) -}}
{{- end -}}
{{- if (not $l.tls.requireClientAuth) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_ := (set $t "certFilepath" (printf "%s/tls.crt" $schemaRegistryPrefix)) -}}
{{- $_ := (set $t "keyFilepath" (printf "%s/tls.key" $schemaRegistryPrefix)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $t) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SchemaRegistryExternal.IsEnabled" -}}
{{- $l := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $l.enabled true)))) "r") (gt ($l.port | int) (0 | int)))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TunableConfig.Translate" -}}
{{- $c := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (eq (toJson $c) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $result := (dict) -}}
{{- range $k, $v := $c -}}
{{- if (not (empty $v)) -}}
{{- $_ := (set $result $k $v) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.NodeConfig.Translate" -}}
{{- $c := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (dict) -}}
{{- range $k, $v := $c -}}
{{- if (not (empty $v)) -}}
{{- $_1987___ok_18 := (get (fromJson (include "_shims.asnumeric" (dict "a" (list $v)))) "r") -}}
{{- $_ := ((index $_1987___ok_18 0) | float64) -}}
{{- $ok_18 := (index $_1987___ok_18 1) -}}
{{- if $ok_18 -}}
{{- $_ := (set $result $k $v) -}}
{{- else -}}{{- if (kindIs "bool" $v) -}}
{{- $_ := (set $result $k $v) -}}
{{- else -}}
{{- $_ := (set $result $k (toYaml $v)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ClusterConfig.Translate" -}}
{{- $c := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (dict) -}}
{{- range $k, $v := $c -}}
{{- $_2007_b_19_ok_20 := (get (fromJson (include "_shims.typetest" (dict "a" (list "bool" $v false)))) "r") -}}
{{- $b_19 := (index $_2007_b_19_ok_20 0) -}}
{{- $ok_20 := (index $_2007_b_19_ok_20 1) -}}
{{- if $ok_20 -}}
{{- $_ := (set $result $k $b_19) -}}
{{- continue -}}
{{- end -}}
{{- if (not (empty $v)) -}}
{{- $_ := (set $result $k $v) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SecretRef.AsSource" -}}
{{- $sr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "") (mustMergeOverwrite (dict) (dict "name" $sr.name)) (dict "key" $sr.key))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SecretRef.IsValid" -}}
{{- $sr := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and (and (ne (toJson $sr) "null") (not (empty $sr.key))) (not (empty $sr.name)))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TieredStorageCredentials.AsEnvVars" -}}
{{- $tsc := (index .a 0) -}}
{{- $config := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_2052___hasAccessKey := (get (fromJson (include "_shims.dicttest" (dict "a" (list $config "cloud_storage_access_key" (coalesce nil))))) "r") -}}
{{- $_ := (index $_2052___hasAccessKey 0) -}}
{{- $hasAccessKey := (index $_2052___hasAccessKey 1) -}}
{{- $_2053___hasSecretKey := (get (fromJson (include "_shims.dicttest" (dict "a" (list $config "cloud_storage_secret_key" (coalesce nil))))) "r") -}}
{{- $_ := (index $_2053___hasSecretKey 0) -}}
{{- $hasSecretKey := (index $_2053___hasSecretKey 1) -}}
{{- $_2054___hasSharedKey := (get (fromJson (include "_shims.dicttest" (dict "a" (list $config "cloud_storage_azure_shared_key" (coalesce nil))))) "r") -}}
{{- $_ := (index $_2054___hasSharedKey 0) -}}
{{- $hasSharedKey := (index $_2054___hasSharedKey 1) -}}
{{- $envvars := (coalesce nil) -}}
{{- if (and (not $hasAccessKey) (get (fromJson (include "redpanda.SecretRef.IsValid" (dict "a" (list $tsc.accessKey)))) "r")) -}}
{{- $envvars = (concat (default (list) $envvars) (list (mustMergeOverwrite (dict "name" "") (dict "name" "REDPANDA_CLOUD_STORAGE_ACCESS_KEY" "valueFrom" (get (fromJson (include "redpanda.SecretRef.AsSource" (dict "a" (list $tsc.accessKey)))) "r"))))) -}}
{{- end -}}
{{- if (get (fromJson (include "redpanda.SecretRef.IsValid" (dict "a" (list $tsc.secretKey)))) "r") -}}
{{- if (and (not $hasSecretKey) (not (get (fromJson (include "redpanda.TieredStorageConfig.HasAzureCanaries" (dict "a" (list (deepCopy $config))))) "r"))) -}}
{{- $envvars = (concat (default (list) $envvars) (list (mustMergeOverwrite (dict "name" "") (dict "name" "REDPANDA_CLOUD_STORAGE_SECRET_KEY" "valueFrom" (get (fromJson (include "redpanda.SecretRef.AsSource" (dict "a" (list $tsc.secretKey)))) "r"))))) -}}
{{- else -}}{{- if (and (not $hasSharedKey) (get (fromJson (include "redpanda.TieredStorageConfig.HasAzureCanaries" (dict "a" (list (deepCopy $config))))) "r")) -}}
{{- $envvars = (concat (default (list) $envvars) (list (mustMergeOverwrite (dict "name" "") (dict "name" "REDPANDA_CLOUD_STORAGE_AZURE_SHARED_KEY" "valueFrom" (get (fromJson (include "redpanda.SecretRef.AsSource" (dict "a" (list $tsc.secretKey)))) "r"))))) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $envvars) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TieredStorageConfig.HasAzureCanaries" -}}
{{- $c := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_2090___containerExists := (get (fromJson (include "_shims.dicttest" (dict "a" (list $c "cloud_storage_azure_container" (coalesce nil))))) "r") -}}
{{- $_ := (index $_2090___containerExists 0) -}}
{{- $containerExists := (index $_2090___containerExists 1) -}}
{{- $_2091___accountExists := (get (fromJson (include "_shims.dicttest" (dict "a" (list $c "cloud_storage_azure_storage_account" (coalesce nil))))) "r") -}}
{{- $_ := (index $_2091___accountExists 0) -}}
{{- $accountExists := (index $_2091___accountExists 1) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (and $containerExists $accountExists)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TieredStorageConfig.CloudStorageCacheSize" -}}
{{- $c := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_2096_value_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list $c `cloud_storage_cache_size` (coalesce nil))))) "r") -}}
{{- $value := (index $_2096_value_ok 0) -}}
{{- $ok := (index $_2096_value_ok 1) -}}
{{- if (not $ok) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $value) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TieredStorageConfig.Translate" -}}
{{- $c := (index .a 0) -}}
{{- $creds := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $config := (merge (dict) (dict) $c) -}}
{{- range $_, $envvar := (get (fromJson (include "redpanda.TieredStorageCredentials.AsEnvVars" (dict "a" (list $creds $c)))) "r") -}}
{{- $key := (lower (substr ((get (fromJson (include "_shims.len" (dict "a" (list "REDPANDA_")))) "r") | int) -1 $envvar.name)) -}}
{{- $_ := (set $config $key (printf "$%s" $envvar.name)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $size_21 := (get (fromJson (include "redpanda.TieredStorageConfig.CloudStorageCacheSize" (dict "a" (list (deepCopy $c))))) "r") -}}
{{- if (ne (toJson $size_21) "null") -}}
{{- $_ := (set $config "cloud_storage_cache_size" ((get (fromJson (include "_shims.resource_Value" (dict "a" (list $size_21)))) "r") | int64)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $config) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

