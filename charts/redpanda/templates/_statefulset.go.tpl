{{- /* Generated from "statefulset.go" */ -}}

{{- define "redpanda.statefulSetRedpandaEnv" -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (list (mustMergeOverwrite (dict "name" "") (dict "name" "SERVICE_NAME" "valueFrom" (mustMergeOverwrite (dict) (dict "fieldRef" (mustMergeOverwrite (dict "fieldPath" "") (dict "fieldPath" "metadata.name")))))) (mustMergeOverwrite (dict "name" "") (dict "name" "POD_IP" "valueFrom" (mustMergeOverwrite (dict) (dict "fieldRef" (mustMergeOverwrite (dict "fieldPath" "") (dict "fieldPath" "status.podIP")))))) (mustMergeOverwrite (dict "name" "") (dict "name" "HOST_IP" "valueFrom" (mustMergeOverwrite (dict) (dict "fieldRef" (mustMergeOverwrite (dict "fieldPath" "") (dict "fieldPath" "status.hostIP")))))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSetPodLabelsSelector" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if $dot.Release.IsUpgrade -}}
{{- $_87_existing_1_ok_2 := (get (fromJson (include "_shims.lookup" (dict "a" (list "apps/v1" "StatefulSet" $dot.Release.Namespace (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))))) "r") -}}
{{- $existing_1 := (index $_87_existing_1_ok_2 0) -}}
{{- $ok_2 := (index $_87_existing_1_ok_2 1) -}}
{{- if (and $ok_2 (gt ((get (fromJson (include "_shims.len" (dict "a" (list $existing_1.spec.selector.matchLabels)))) "r") | int) (0 | int))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $existing_1.spec.selector.matchLabels) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- $values := $dot.Values.AsMap -}}
{{- $additionalSelectorLabels := (dict) -}}
{{- if (ne (toJson $values.statefulset.additionalSelectorLabels) "null") -}}
{{- $additionalSelectorLabels = $values.statefulset.additionalSelectorLabels -}}
{{- end -}}
{{- $component := (printf "%s-statefulset" (trimSuffix "-" (trunc (51 | int) (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r")))) -}}
{{- $defaults := (dict "app.kubernetes.io/component" $component "app.kubernetes.io/instance" $dot.Release.Name "app.kubernetes.io/name" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $additionalSelectorLabels $defaults)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSetPodLabels" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if $dot.Release.IsUpgrade -}}
{{- $_118_existing_3_ok_4 := (get (fromJson (include "_shims.lookup" (dict "a" (list "apps/v1" "StatefulSet" $dot.Release.Namespace (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))))) "r") -}}
{{- $existing_3 := (index $_118_existing_3_ok_4 0) -}}
{{- $ok_4 := (index $_118_existing_3_ok_4 1) -}}
{{- if (and $ok_4 (gt ((get (fromJson (include "_shims.len" (dict "a" (list $existing_3.spec.template.metadata.labels)))) "r") | int) (0 | int))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $existing_3.spec.template.metadata.labels) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- $values := $dot.Values.AsMap -}}
{{- $statefulSetLabels := (dict) -}}
{{- if (ne (toJson $values.statefulset.podTemplate.labels) "null") -}}
{{- $statefulSetLabels = $values.statefulset.podTemplate.labels -}}
{{- end -}}
{{- $defaults := (dict "redpanda.com/poddisruptionbudget" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $statefulSetLabels (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r") $defaults (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSetPodAnnotations" -}}
{{- $dot := (index .a 0) -}}
{{- $configMapChecksum := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $configMapChecksumAnnotation := (dict "config.redpanda.com/checksum" $configMapChecksum) -}}
{{- if (ne (toJson $values.statefulset.podTemplate.annotations) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $values.statefulset.podTemplate.annotations $configMapChecksumAnnotation)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $values.statefulset.annotations $configMapChecksumAnnotation)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSetVolumes" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $fullname := (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") -}}
{{- $volumes := (get (fromJson (include "redpanda.CommonVolumes" (dict "a" (list $dot)))) "r") -}}
{{- $values := $dot.Values.AsMap -}}
{{- $volumes = (concat (default (list) $volumes) (default (list) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" (printf "%.50s-sts-lifecycle" $fullname) "defaultMode" (0o775 | int))))) (dict "name" "lifecycle-scripts")) (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "configMap" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" $fullname)) (dict)))) (dict "name" "base-config")) (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "emptyDir" (mustMergeOverwrite (dict) (dict)))) (dict "name" "config")) (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" (printf "%.51s-configurator" $fullname) "defaultMode" (0o775 | int))))) (dict "name" (printf "%.51s-configurator" $fullname)))))) -}}
{{- if $values.statefulset.initContainers.fsValidator.enabled -}}
{{- $volumes = (concat (default (list) $volumes) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" (printf "%.49s-fs-validator" $fullname) "defaultMode" (0o775 | int))))) (dict "name" (printf "%.49s-fs-validator" $fullname))))) -}}
{{- end -}}
{{- $vol_5 := (get (fromJson (include "redpanda.Listeners.TrustStoreVolume" (dict "a" (list $values.listeners $values.tls)))) "r") -}}
{{- if (ne (toJson $vol_5) "null") -}}
{{- $volumes = (concat (default (list) $volumes) (list $vol_5)) -}}
{{- end -}}
{{- $volumes = (concat (default (list) $volumes) (default (list) (get (fromJson (include "redpanda.templateToVolumes" (dict "a" (list $dot $values.statefulset.extraVolumes)))) "r"))) -}}
{{- $volumes = (concat (default (list) $volumes) (list (get (fromJson (include "redpanda.statefulSetVolumeDataDir" (dict "a" (list $dot)))) "r"))) -}}
{{- $v_6 := (get (fromJson (include "redpanda.statefulSetVolumeTieredStorageDir" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $v_6) "null") -}}
{{- $volumes = (concat (default (list) $volumes) (list $v_6)) -}}
{{- end -}}
{{- $volumes = (concat (default (list) $volumes) (list (get (fromJson (include "redpanda.kubeTokenAPIVolume" (dict "a" (list "kube-api-access")))) "r"))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $volumes) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.kubeTokenAPIVolume" -}}
{{- $name := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "projected" (mustMergeOverwrite (dict "sources" (coalesce nil)) (dict "defaultMode" (420 | int) "sources" (list (mustMergeOverwrite (dict) (dict "serviceAccountToken" (mustMergeOverwrite (dict "path" "") (dict "path" "token" "expirationSeconds" ((3607 | int) | int64))))) (mustMergeOverwrite (dict) (dict "configMap" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" "kube-root-ca.crt")) (dict "items" (list (mustMergeOverwrite (dict "key" "" "path" "") (dict "key" "ca.crt" "path" "ca.crt"))))))) (mustMergeOverwrite (dict) (dict "downwardAPI" (mustMergeOverwrite (dict) (dict "items" (list (mustMergeOverwrite (dict "path" "") (dict "path" "namespace" "fieldRef" (mustMergeOverwrite (dict "fieldPath" "") (dict "apiVersion" "v1" "fieldPath" "metadata.namespace")))))))))))))) (dict "name" $name))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetVolumeDataDir" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $datadirSource := (mustMergeOverwrite (dict) (dict "emptyDir" (mustMergeOverwrite (dict) (dict)))) -}}
{{- if $values.storage.persistentVolume.enabled -}}
{{- $datadirSource = (mustMergeOverwrite (dict) (dict "persistentVolumeClaim" (mustMergeOverwrite (dict "claimName" "") (dict "claimName" "datadir")))) -}}
{{- else -}}{{- if (ne $values.storage.hostPath "") -}}
{{- $datadirSource = (mustMergeOverwrite (dict) (dict "hostPath" (mustMergeOverwrite (dict "path" "") (dict "path" $values.storage.hostPath)))) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "") $datadirSource (dict "name" "datadir"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetVolumeTieredStorageDir" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not (get (fromJson (include "redpanda.Storage.IsTieredStorageEnabled" (dict "a" (list $values.storage)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $tieredType := (get (fromJson (include "redpanda.Storage.TieredMountType" (dict "a" (list $values.storage)))) "r") -}}
{{- if (or (eq $tieredType "none") (eq $tieredType "persistentVolume")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- if (eq $tieredType "hostPath") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "hostPath" (mustMergeOverwrite (dict "path" "") (dict "path" (get (fromJson (include "redpanda.Storage.GetTieredStorageHostPath" (dict "a" (list $values.storage)))) "r"))))) (dict "name" "tiered-storage-dir"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "emptyDir" (mustMergeOverwrite (dict) (dict "sizeLimit" (get (fromJson (include "redpanda.TieredStorageConfig.CloudStorageCacheSize" (dict "a" (list (deepCopy (get (fromJson (include "redpanda.Storage.GetTieredStorageConfig" (dict "a" (list $values.storage)))) "r")))))) "r"))))) (dict "name" "tiered-storage-dir"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSetVolumeMounts" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $mounts := (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r") -}}
{{- $values := $dot.Values.AsMap -}}
{{- $mounts = (concat (default (list) $mounts) (default (list) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "config" "mountPath" "/etc/redpanda")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "base-config" "mountPath" "/tmp/base-config")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "lifecycle-scripts" "mountPath" "/var/lifecycle")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "datadir" "mountPath" "/var/lib/redpanda/data")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "kube-api-access" "mountPath" "/var/run/secrets/kubernetes.io/serviceaccount" "readOnly" true))))) -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list (get (fromJson (include "redpanda.Listeners.TrustStores" (dict "a" (list $values.listeners $values.tls)))) "r"))))) "r") | int) (0 | int)) -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "truststores" "mountPath" "/etc/truststores" "readOnly" true)))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $mounts) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSetInitContainers" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $containers := (coalesce nil) -}}
{{- $c_7 := (get (fromJson (include "redpanda.statefulSetInitContainerTuning" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $c_7) "null") -}}
{{- $containers = (concat (default (list) $containers) (list $c_7)) -}}
{{- end -}}
{{- $c_8 := (get (fromJson (include "redpanda.statefulSetInitContainerSetDataDirOwnership" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $c_8) "null") -}}
{{- $containers = (concat (default (list) $containers) (list $c_8)) -}}
{{- end -}}
{{- $c_9 := (get (fromJson (include "redpanda.statefulSetInitContainerFSValidator" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $c_9) "null") -}}
{{- $containers = (concat (default (list) $containers) (list $c_9)) -}}
{{- end -}}
{{- $c_10 := (get (fromJson (include "redpanda.statefulSetInitContainerSetTieredStorageCacheDirOwnership" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $c_10) "null") -}}
{{- $containers = (concat (default (list) $containers) (list $c_10)) -}}
{{- end -}}
{{- $containers = (concat (default (list) $containers) (list (get (fromJson (include "redpanda.statefulSetInitContainerConfigurator" (dict "a" (list $dot)))) "r"))) -}}
{{- $containers = (concat (default (list) $containers) (list (get (fromJson (include "redpanda.bootstrapYamlTemplater" (dict "a" (list $dot)))) "r"))) -}}
{{- $containers = (concat (default (list) $containers) (default (list) (get (fromJson (include "redpanda.templateToContainers" (dict "a" (list $dot $values.statefulset.initContainers.extraInitContainers)))) "r"))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $containers) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetInitContainerTuning" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.tuning.tune_aio_events) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" "tuning" "image" (printf "%s:%s" $values.image.repository (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot)))) "r")) "command" (list `/bin/bash` `-c` `rpk redpanda tune all`) "securityContext" (mustMergeOverwrite (dict) (dict "capabilities" (mustMergeOverwrite (dict) (dict "add" (list `SYS_RESOURCE`))) "privileged" true "runAsUser" ((0 | int64) | int64) "runAsGroup" ((0 | int64) | int64))) "volumeMounts" (concat (default (list) (concat (default (list) (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r")) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.initContainers.tuning.extraVolumeMounts)))) "r")))) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "base-config" "mountPath" "/etc/redpanda")))) "resources" $values.statefulset.initContainers.tuning.resources))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetInitContainerSetDataDirOwnership" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.statefulset.initContainers.setDataDirOwnership.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_426_uid_gid := (get (fromJson (include "redpanda.securityContextUidGid" (dict "a" (list $dot "set-datadir-ownership")))) "r") -}}
{{- $uid := ((index $_426_uid_gid 0) | int64) -}}
{{- $gid := ((index $_426_uid_gid 1) | int64) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" "set-datadir-ownership" "image" (printf "%s:%s" $values.statefulset.initContainerImage.repository $values.statefulset.initContainerImage.tag) "command" (list `/bin/sh` `-c` (printf `chown %d:%d -R /var/lib/redpanda/data` $uid $gid)) "volumeMounts" (concat (default (list) (concat (default (list) (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r")) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.initContainers.setDataDirOwnership.extraVolumeMounts)))) "r")))) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" `datadir` "mountPath" `/var/lib/redpanda/data`)))) "resources" $values.statefulset.initContainers.setDataDirOwnership.resources))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.securityContextUidGid" -}}
{{- $dot := (index .a 0) -}}
{{- $containerName := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $uid := $values.statefulset.securityContext.runAsUser -}}
{{- if (and (ne (toJson $values.statefulset.podSecurityContext) "null") (ne (toJson $values.statefulset.podSecurityContext.runAsUser) "null")) -}}
{{- $uid = $values.statefulset.podSecurityContext.runAsUser -}}
{{- end -}}
{{- if (eq (toJson $uid) "null") -}}
{{- $_ := (fail (printf `%s container requires runAsUser to be specified` $containerName)) -}}
{{- end -}}
{{- $gid := $values.statefulset.securityContext.fsGroup -}}
{{- if (and (ne (toJson $values.statefulset.podSecurityContext) "null") (ne (toJson $values.statefulset.podSecurityContext.fsGroup) "null")) -}}
{{- $gid = $values.statefulset.podSecurityContext.fsGroup -}}
{{- end -}}
{{- if (eq (toJson $gid) "null") -}}
{{- $_ := (fail (printf `%s container requires fsGroup to be specified` $containerName)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (list $uid $gid)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetInitContainerFSValidator" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.statefulset.initContainers.fsValidator.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" "fs-validator" "image" (printf "%s:%s" $values.image.repository (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot)))) "r")) "command" (list `/bin/sh`) "args" (list `-c` (printf `trap "exit 0" TERM; exec /etc/secrets/fs-validator/scripts/fsValidator.sh %s & wait $!` $values.statefulset.initContainers.fsValidator.expectedFS)) "securityContext" (get (fromJson (include "redpanda.ContainerSecurityContext" (dict "a" (list $dot)))) "r") "volumeMounts" (concat (default (list) (concat (default (list) (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r")) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.initContainers.fsValidator.extraVolumeMounts)))) "r")))) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" (printf `%.49s-fs-validator` (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) "mountPath" `/etc/secrets/fs-validator/scripts/`)) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" `datadir` "mountPath" `/var/lib/redpanda/data`)))) "resources" $values.statefulset.initContainers.fsValidator.resources))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetInitContainerSetTieredStorageCacheDirOwnership" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not (get (fromJson (include "redpanda.Storage.IsTieredStorageEnabled" (dict "a" (list $values.storage)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_508_uid_gid := (get (fromJson (include "redpanda.securityContextUidGid" (dict "a" (list $dot "set-tiered-storage-cache-dir-ownership")))) "r") -}}
{{- $uid := ((index $_508_uid_gid 0) | int64) -}}
{{- $gid := ((index $_508_uid_gid 1) | int64) -}}
{{- $cacheDir := (get (fromJson (include "redpanda.Storage.TieredCacheDirectory" (dict "a" (list $values.storage $dot)))) "r") -}}
{{- $mounts := (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r") -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "datadir" "mountPath" "/var/lib/redpanda/data")))) -}}
{{- if (ne (get (fromJson (include "redpanda.Storage.TieredMountType" (dict "a" (list $values.storage)))) "r") "none") -}}
{{- $name := "tiered-storage-dir" -}}
{{- if (and (ne (toJson $values.storage.persistentVolume) "null") (ne $values.storage.persistentVolume.nameOverwrite "")) -}}
{{- $name = $values.storage.persistentVolume.nameOverwrite -}}
{{- end -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" $name "mountPath" $cacheDir)))) -}}
{{- end -}}
{{- $mounts = (concat (default (list) $mounts) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.initContainers.setTieredStorageCacheDirOwnership.extraVolumeMounts)))) "r"))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" `set-tiered-storage-cache-dir-ownership` "image" (printf `%s:%s` $values.statefulset.initContainerImage.repository $values.statefulset.initContainerImage.tag) "command" (list `/bin/sh` `-c` (printf `mkdir -p %s; chown %d:%d -R %s` $cacheDir $uid $gid $cacheDir)) "volumeMounts" $mounts "resources" $values.statefulset.initContainers.setTieredStorageCacheDirOwnership.resources))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetInitContainerConfigurator" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $volMounts := (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r") -}}
{{- $volMounts = (concat (default (list) $volMounts) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.initContainers.configurator.extraVolumeMounts)))) "r"))) -}}
{{- $volMounts = (concat (default (list) $volMounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "config" "mountPath" "/etc/redpanda")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "base-config" "mountPath" "/tmp/base-config")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" (printf `%.51s-configurator` (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) "mountPath" "/etc/secrets/configurator/scripts/")))) -}}
{{- if $values.rackAwareness.enabled -}}
{{- $volMounts = (concat (default (list) $volMounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "kube-api-access" "mountPath" "/var/run/secrets/kubernetes.io/serviceaccount" "readOnly" true)))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" (printf `%.51s-configurator` (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r")) "image" (printf `%s:%s` $values.image.repository (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot)))) "r")) "command" (list `/bin/bash` `-c` `trap "exit 0" TERM; exec $CONFIGURATOR_SCRIPT "${SERVICE_NAME}" "${KUBERNETES_NODE_NAME}" & wait $!`) "env" (get (fromJson (include "redpanda.rpkEnvVars" (dict "a" (list $dot (list (mustMergeOverwrite (dict "name" "") (dict "name" "CONFIGURATOR_SCRIPT" "value" "/etc/secrets/configurator/scripts/configurator.sh")) (mustMergeOverwrite (dict "name" "") (dict "name" "SERVICE_NAME" "valueFrom" (mustMergeOverwrite (dict) (dict "fieldRef" (mustMergeOverwrite (dict "fieldPath" "") (dict "fieldPath" "metadata.name")) "resourceFieldRef" (coalesce nil) "configMapKeyRef" (coalesce nil) "secretKeyRef" (coalesce nil))))) (mustMergeOverwrite (dict "name" "") (dict "name" "KUBERNETES_NODE_NAME" "valueFrom" (mustMergeOverwrite (dict) (dict "fieldRef" (mustMergeOverwrite (dict "fieldPath" "") (dict "fieldPath" "spec.nodeName")))))) (mustMergeOverwrite (dict "name" "") (dict "name" "HOST_IP_ADDRESS" "valueFrom" (mustMergeOverwrite (dict) (dict "fieldRef" (mustMergeOverwrite (dict "fieldPath" "") (dict "apiVersion" "v1" "fieldPath" "status.hostIP"))))))))))) "r") "securityContext" (get (fromJson (include "redpanda.ContainerSecurityContext" (dict "a" (list $dot)))) "r") "volumeMounts" $volMounts "resources" $values.statefulset.initContainers.configurator.resources))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSetContainers" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $containers := (coalesce nil) -}}
{{- $containers = (concat (default (list) $containers) (list (get (fromJson (include "redpanda.statefulSetContainerRedpanda" (dict "a" (list $dot)))) "r"))) -}}
{{- $c_11 := (get (fromJson (include "redpanda.statefulSetContainerSidecar" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $c_11) "null") -}}
{{- $containers = (concat (default (list) $containers) (list $c_11)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $containers) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.wrapLifecycleHook" -}}
{{- $hook := (index .a 0) -}}
{{- $timeoutSeconds := (index .a 1) -}}
{{- $cmd := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $wrapped := (join " " $cmd) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (list "bash" "-c" (printf "timeout -v %d %s 2>&1 | sed \"s/^/lifecycle-hook %s $(date): /\" | tee /proc/1/fd/1; true" $timeoutSeconds $wrapped $hook))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetContainerRedpanda" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $internalAdvertiseAddress := (printf "%s.%s" "$(SERVICE_NAME)" (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r")) -}}
{{- $container := (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r") "image" (printf `%s:%s` $values.image.repository (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot)))) "r")) "env" (get (fromJson (include "redpanda.bootstrapEnvVars" (dict "a" (list $dot (get (fromJson (include "redpanda.statefulSetRedpandaEnv" (dict "a" (list)))) "r"))))) "r") "lifecycle" (mustMergeOverwrite (dict) (dict "postStart" (mustMergeOverwrite (dict) (dict "exec" (mustMergeOverwrite (dict) (dict "command" (get (fromJson (include "redpanda.wrapLifecycleHook" (dict "a" (list "post-start" ((div ($values.statefulset.terminationGracePeriodSeconds | int64) (2 | int64)) | int64) (list "bash" "-x" "/var/lifecycle/postStart.sh"))))) "r"))))) "preStop" (mustMergeOverwrite (dict) (dict "exec" (mustMergeOverwrite (dict) (dict "command" (get (fromJson (include "redpanda.wrapLifecycleHook" (dict "a" (list "pre-stop" ((div ($values.statefulset.terminationGracePeriodSeconds | int64) (2 | int64)) | int64) (list "bash" "-x" "/var/lifecycle/preStop.sh"))))) "r"))))))) "startupProbe" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "exec" (mustMergeOverwrite (dict) (dict "command" (list `/bin/sh` `-c` (join "\n" (list `set -e` (printf `RESULT=$(curl --silent --fail -k -m 5 %s "%s://%s/v1/status/ready")` (get (fromJson (include "redpanda.adminTLSCurlFlags" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.adminInternalHTTPProtocol" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.adminApiURLs" (dict "a" (list $dot)))) "r")) `echo $RESULT` `echo $RESULT | grep ready` ``))))))) (dict "initialDelaySeconds" ($values.statefulset.startupProbe.initialDelaySeconds | int) "periodSeconds" ($values.statefulset.startupProbe.periodSeconds | int) "failureThreshold" ($values.statefulset.startupProbe.failureThreshold | int))) "livenessProbe" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "exec" (mustMergeOverwrite (dict) (dict "command" (list `/bin/sh` `-c` (printf `curl --silent --fail -k -m 5 %s "%s://%s/v1/status/ready"` (get (fromJson (include "redpanda.adminTLSCurlFlags" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.adminInternalHTTPProtocol" (dict "a" (list $dot)))) "r") (get (fromJson (include "redpanda.adminApiURLs" (dict "a" (list $dot)))) "r"))))))) (dict "initialDelaySeconds" ($values.statefulset.livenessProbe.initialDelaySeconds | int) "periodSeconds" ($values.statefulset.livenessProbe.periodSeconds | int) "failureThreshold" ($values.statefulset.livenessProbe.failureThreshold | int))) "command" (list `rpk` `redpanda` `start` (printf `--advertise-rpc-addr=%s:%d` $internalAdvertiseAddress ($values.listeners.rpc.port | int))) "volumeMounts" (concat (default (list) (get (fromJson (include "redpanda.StatefulSetVolumeMounts" (dict "a" (list $dot)))) "r")) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.extraVolumeMounts)))) "r"))) "securityContext" (get (fromJson (include "redpanda.ContainerSecurityContext" (dict "a" (list $dot)))) "r") "resources" (get (fromJson (include "redpanda.RedpandaResources.GetResourceRequirements" (dict "a" (list $values.resources)))) "r"))) -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" "admin" "containerPort" ($values.listeners.admin.port | int)))))) -}}
{{- range $externalName, $external := $values.listeners.admin.external -}}
{{- if (get (fromJson (include "redpanda.AdminExternal.IsEnabled" (dict "a" (list $external)))) "r") -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" (printf "admin-%.8s" (lower $externalName)) "containerPort" ($external.port | int)))))) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" "http" "containerPort" ($values.listeners.http.port | int)))))) -}}
{{- range $externalName, $external := $values.listeners.http.external -}}
{{- if (get (fromJson (include "redpanda.HTTPExternal.IsEnabled" (dict "a" (list $external)))) "r") -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" (printf "http-%.8s" (lower $externalName)) "containerPort" ($external.port | int)))))) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" "kafka" "containerPort" ($values.listeners.kafka.port | int)))))) -}}
{{- range $externalName, $external := $values.listeners.kafka.external -}}
{{- if (get (fromJson (include "redpanda.KafkaExternal.IsEnabled" (dict "a" (list $external)))) "r") -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" (printf "kafka-%.8s" (lower $externalName)) "containerPort" ($external.port | int)))))) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" "rpc" "containerPort" ($values.listeners.rpc.port | int)))))) -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" "schemaregistry" "containerPort" ($values.listeners.schemaRegistry.port | int)))))) -}}
{{- range $externalName, $external := $values.listeners.schemaRegistry.external -}}
{{- if (get (fromJson (include "redpanda.SchemaRegistryExternal.IsEnabled" (dict "a" (list $external)))) "r") -}}
{{- $_ := (set $container "ports" (concat (default (list) $container.ports) (list (mustMergeOverwrite (dict "containerPort" 0) (dict "name" (printf "schema-%.8s" (lower $externalName)) "containerPort" ($external.port | int)))))) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- if (and (get (fromJson (include "redpanda.Storage.IsTieredStorageEnabled" (dict "a" (list $values.storage)))) "r") (ne (get (fromJson (include "redpanda.Storage.TieredMountType" (dict "a" (list $values.storage)))) "r") "none")) -}}
{{- $name := "tiered-storage-dir" -}}
{{- if (and (ne (toJson $values.storage.persistentVolume) "null") (ne $values.storage.persistentVolume.nameOverwrite "")) -}}
{{- $name = $values.storage.persistentVolume.nameOverwrite -}}
{{- end -}}
{{- $_ := (set $container "volumeMounts" (concat (default (list) $container.volumeMounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" $name "mountPath" (get (fromJson (include "redpanda.Storage.TieredCacheDirectory" (dict "a" (list $values.storage $dot)))) "r")))))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $container) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.adminApiURLs" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf `${SERVICE_NAME}.%s:%d` (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r") ($values.listeners.admin.port | int))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.adminURLsCLI" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf `$(SERVICE_NAME).%s:%d` (get (fromJson (include "redpanda.InternalDomain" (dict "a" (list $dot)))) "r") ($values.listeners.admin.port | int))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetContainerSidecar" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $args := (list `sidecar` `--redpanda-yaml` `/etc/redpanda/redpanda.yaml` `--redpanda-cluster-namespace` $dot.Release.Namespace `--redpanda-cluster-name` (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") `--run-broker-probe` `--broker-probe-broker-url` (get (fromJson (include "redpanda.adminURLsCLI" (dict "a" (list $dot)))) "r")) -}}
{{- if $values.statefulset.sideCars.brokerDecommissioner.enabled -}}
{{- $args = (concat (default (list) $args) (default (list) (list `--run-decommissioner` (printf "--decommission-vote-interval=%s" $values.statefulset.sideCars.brokerDecommissioner.decommissionAfter) (printf "--decommission-requeue-timeout=%s" $values.statefulset.sideCars.brokerDecommissioner.decommissionRequeueTimeout) `--decommission-vote-count=2`))) -}}
{{- end -}}
{{- $sasl_12 := $values.auth.sasl -}}
{{- if (and (and $sasl_12.enabled (ne $sasl_12.secretRef "")) $values.statefulset.sideCars.configWatcher.enabled) -}}
{{- $args = (concat (default (list) $args) (default (list) (list `--watch-users` `--users-directory=/etc/secrets/users/`))) -}}
{{- end -}}
{{- if $values.statefulset.sideCars.pvcUnbinder.enabled -}}
{{- $args = (concat (default (list) $args) (default (list) (list `--run-pvc-unbinder` (printf "--pvc-unbinder-timeout=%s" $values.statefulset.sideCars.pvcUnbinder.unbindAfter)))) -}}
{{- end -}}
{{- $volumeMounts := (concat (default (list) (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r")) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "config" "mountPath" "/etc/redpanda")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "kube-api-access" "mountPath" "/var/run/secrets/kubernetes.io/serviceaccount" "readOnly" true)))) -}}
{{- $volumeMounts = (concat (default (list) $volumeMounts) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.sideCars.extraVolumeMounts)))) "r"))) -}}
{{- $volumeMounts = (concat (default (list) $volumeMounts) (default (list) (get (fromJson (include "redpanda.templateToVolumeMounts" (dict "a" (list $dot $values.statefulset.sideCars.configWatcher.extraVolumeMounts)))) "r"))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" "sidecar" "image" (printf `%s:%s` $values.statefulset.sideCars.image.repository $values.statefulset.sideCars.image.tag) "command" (list `/redpanda-operator`) "args" $args "env" (concat (default (list) (get (fromJson (include "redpanda.rpkEnvVars" (dict "a" (list $dot (coalesce nil))))) "r")) (default (list) (get (fromJson (include "redpanda.statefulSetRedpandaEnv" (dict "a" (list)))) "r"))) "resources" $values.statefulset.sideCars.resources "securityContext" $values.statefulset.sideCars.securityContext "volumeMounts" $volumeMounts "readinessProbe" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "httpGet" (mustMergeOverwrite (dict "port" 0) (dict "path" "/healthz" "port" (8093 | int))))) (dict "initialDelaySeconds" ($values.statefulset.readinessProbe.initialDelaySeconds | int) "timeoutSeconds" ($values.statefulset.readinessProbe.timeoutSeconds | int) "periodSeconds" ($values.statefulset.readinessProbe.periodSeconds | int) "successThreshold" ($values.statefulset.readinessProbe.successThreshold | int) "failureThreshold" ($values.statefulset.readinessProbe.failureThreshold | int)))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.rpkEnvVars" -}}
{{- $dot := (index .a 0) -}}
{{- $envVars := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (and (ne (toJson $values.auth.sasl) "null") $values.auth.sasl.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) $envVars) (default (list) (get (fromJson (include "redpanda.BootstrapUser.RpkEnvironment" (dict "a" (list $values.auth.sasl.bootstrapUser (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))))) "r")))) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $envVars) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.bootstrapEnvVars" -}}
{{- $dot := (index .a 0) -}}
{{- $envVars := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (and (ne (toJson $values.auth.sasl) "null") $values.auth.sasl.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) $envVars) (default (list) (get (fromJson (include "redpanda.BootstrapUser.BootstrapEnvironment" (dict "a" (list $values.auth.sasl.bootstrapUser (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))))) "r")))) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $envVars) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.templateToVolumeMounts" -}}
{{- $dot := (index .a 0) -}}
{{- $template := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (tpl $template $dot) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (fromYamlArray $result)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.templateToVolumes" -}}
{{- $dot := (index .a 0) -}}
{{- $template := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (tpl $template $dot) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (fromYamlArray $result)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.templateToContainers" -}}
{{- $dot := (index .a 0) -}}
{{- $template := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $result := (tpl $template $dot) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (fromYamlArray $result)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StatefulSet" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (and (not (get (fromJson (include "redpanda.RedpandaAtLeast_22_2_0" (dict "a" (list $dot)))) "r")) (not $values.force)) -}}
{{- $sv := (get (fromJson (include "redpanda.semver" (dict "a" (list $dot)))) "r") -}}
{{- $_ := (fail (printf "Error: The Redpanda version (%s) is no longer supported \nTo accept this risk, run the upgrade again adding `--force=true`\n" $sv)) -}}
{{- end -}}
{{- $ss := (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "selector" (coalesce nil) "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "containers" (coalesce nil))) "serviceName" "" "updateStrategy" (dict)) "status" (dict "replicas" 0 "availableReplicas" 0)) (mustMergeOverwrite (dict) (dict "apiVersion" "apps/v1" "kind" "StatefulSet")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r"))) "spec" (mustMergeOverwrite (dict "selector" (coalesce nil) "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "containers" (coalesce nil))) "serviceName" "" "updateStrategy" (dict)) (dict "selector" (mustMergeOverwrite (dict) (dict "matchLabels" (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r"))) "serviceName" (get (fromJson (include "redpanda.ServiceName" (dict "a" (list $dot)))) "r") "replicas" ($values.statefulset.replicas | int) "updateStrategy" $values.statefulset.updateStrategy "podManagementPolicy" "Parallel" "template" (get (fromJson (include "redpanda.StrategicMergePatch" (dict "a" (list $values.statefulset.podTemplate (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "containers" (coalesce nil))) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "labels" (get (fromJson (include "redpanda.StatefulSetPodLabels" (dict "a" (list $dot)))) "r") "annotations" (get (fromJson (include "redpanda.StatefulSetPodAnnotations" (dict "a" (list $dot (get (fromJson (include "redpanda.statefulSetChecksumAnnotation" (dict "a" (list $dot)))) "r"))))) "r"))) "spec" (mustMergeOverwrite (dict "containers" (coalesce nil)) (dict "automountServiceAccountToken" false "terminationGracePeriodSeconds" ($values.statefulset.terminationGracePeriodSeconds | int64) "securityContext" (get (fromJson (include "redpanda.PodSecurityContext" (dict "a" (list $dot)))) "r") "serviceAccountName" (get (fromJson (include "redpanda.ServiceAccountName" (dict "a" (list $dot)))) "r") "imagePullSecrets" (default (coalesce nil) $values.imagePullSecrets) "initContainers" (get (fromJson (include "redpanda.StatefulSetInitContainers" (dict "a" (list $dot)))) "r") "containers" (get (fromJson (include "redpanda.StatefulSetContainers" (dict "a" (list $dot)))) "r") "volumes" (get (fromJson (include "redpanda.StatefulSetVolumes" (dict "a" (list $dot)))) "r") "topologySpreadConstraints" (get (fromJson (include "redpanda.statefulSetTopologySpreadConstraints" (dict "a" (list $dot)))) "r") "nodeSelector" (get (fromJson (include "redpanda.statefulSetNodeSelectors" (dict "a" (list $dot)))) "r") "affinity" (get (fromJson (include "redpanda.statefulSetAffinity" (dict "a" (list $dot)))) "r") "priorityClassName" $values.statefulset.priorityClassName "tolerations" (get (fromJson (include "redpanda.statefulSetTolerations" (dict "a" (list $dot)))) "r"))))))))) "r") "volumeClaimTemplates" (coalesce nil))))) -}}
{{- if (or $values.storage.persistentVolume.enabled ((and (get (fromJson (include "redpanda.Storage.IsTieredStorageEnabled" (dict "a" (list $values.storage)))) "r") (eq (get (fromJson (include "redpanda.Storage.TieredMountType" (dict "a" (list $values.storage)))) "r") "persistentVolume")))) -}}
{{- $t_13 := (get (fromJson (include "redpanda.volumeClaimTemplateDatadir" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $t_13) "null") -}}
{{- $_ := (set $ss.spec "volumeClaimTemplates" (concat (default (list) $ss.spec.volumeClaimTemplates) (list $t_13))) -}}
{{- end -}}
{{- $t_14 := (get (fromJson (include "redpanda.volumeClaimTemplateTieredStorageDir" (dict "a" (list $dot)))) "r") -}}
{{- if (ne (toJson $t_14) "null") -}}
{{- $_ := (set $ss.spec "volumeClaimTemplates" (concat (default (list) $ss.spec.volumeClaimTemplates) (list $t_14))) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $ss) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.semver" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (trimPrefix "v" (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetChecksumAnnotation" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $dependencies := (coalesce nil) -}}
{{- $dependencies = (concat (default (list) $dependencies) (list (get (fromJson (include "redpanda.RedpandaConfigFile" (dict "a" (list $dot false)))) "r"))) -}}
{{- if $values.external.enabled -}}
{{- $dependencies = (concat (default (list) $dependencies) (list (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.external.domain "")))) "r"))) -}}
{{- if (empty $values.external.addresses) -}}
{{- $dependencies = (concat (default (list) $dependencies) (list "")) -}}
{{- else -}}
{{- $dependencies = (concat (default (list) $dependencies) (list $values.external.addresses)) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (sha256sum (toJson $dependencies))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetTolerations" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (default $values.tolerations $values.statefulset.tolerations)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetNodeSelectors" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (default $values.statefulset.nodeSelector $values.nodeSelector)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetAffinity" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $affinity := (mustMergeOverwrite (dict) (dict)) -}}
{{- if (not (empty $values.statefulset.nodeAffinity)) -}}
{{- $_ := (set $affinity "nodeAffinity" $values.statefulset.nodeAffinity) -}}
{{- else -}}{{- if (not (empty $values.affinity.nodeAffinity)) -}}
{{- $_ := (set $affinity "nodeAffinity" $values.affinity.nodeAffinity) -}}
{{- end -}}
{{- end -}}
{{- if (not (empty $values.statefulset.podAffinity)) -}}
{{- $_ := (set $affinity "podAffinity" $values.statefulset.podAffinity) -}}
{{- else -}}{{- if (not (empty $values.affinity.podAffinity)) -}}
{{- $_ := (set $affinity "podAffinity" $values.affinity.podAffinity) -}}
{{- end -}}
{{- end -}}
{{- if (not (empty $values.statefulset.podAntiAffinity)) -}}
{{- $_ := (set $affinity "podAntiAffinity" (mustMergeOverwrite (dict) (dict))) -}}
{{- if (eq $values.statefulset.podAntiAffinity.type "hard") -}}
{{- $_ := (set $affinity.podAntiAffinity "requiredDuringSchedulingIgnoredDuringExecution" (list (mustMergeOverwrite (dict "topologyKey" "") (dict "topologyKey" $values.statefulset.podAntiAffinity.topologyKey "labelSelector" (mustMergeOverwrite (dict) (dict "matchLabels" (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r"))))))) -}}
{{- else -}}{{- if (eq $values.statefulset.podAntiAffinity.type "soft") -}}
{{- $_ := (set $affinity.podAntiAffinity "preferredDuringSchedulingIgnoredDuringExecution" (list (mustMergeOverwrite (dict "weight" 0 "podAffinityTerm" (dict "topologyKey" "")) (dict "weight" ($values.statefulset.podAntiAffinity.weight | int) "podAffinityTerm" (mustMergeOverwrite (dict "topologyKey" "") (dict "topologyKey" $values.statefulset.podAntiAffinity.topologyKey "labelSelector" (mustMergeOverwrite (dict) (dict "matchLabels" (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r"))))))))) -}}
{{- else -}}{{- if (eq $values.statefulset.podAntiAffinity.type "custom") -}}
{{- $_ := (set $affinity "podAntiAffinity" $values.statefulset.podAntiAffinity.custom) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- else -}}{{- if (not (empty $values.affinity.podAntiAffinity)) -}}
{{- $_ := (set $affinity "podAntiAffinity" $values.affinity.podAntiAffinity) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $affinity) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.volumeClaimTemplateDatadir" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.storage.persistentVolume.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $pvc := (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "resources" (dict)) "status" (dict)) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" "datadir" "labels" (merge (dict) (dict `app.kubernetes.io/name` (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r") `app.kubernetes.io/instance` $dot.Release.Name `app.kubernetes.io/component` (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r")) $values.storage.persistentVolume.labels $values.commonLabels) "annotations" (default (coalesce nil) $values.storage.persistentVolume.annotations))) "spec" (mustMergeOverwrite (dict "resources" (dict)) (dict "accessModes" (list "ReadWriteOnce") "resources" (mustMergeOverwrite (dict) (dict "requests" (dict "storage" $values.storage.persistentVolume.size))))))) -}}
{{- if (not (empty $values.storage.persistentVolume.storageClass)) -}}
{{- if (eq $values.storage.persistentVolume.storageClass "-") -}}
{{- $_ := (set $pvc.spec "storageClassName" "") -}}
{{- else -}}
{{- $_ := (set $pvc.spec "storageClassName" $values.storage.persistentVolume.storageClass) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $pvc) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.volumeClaimTemplateTieredStorageDir" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (or (not (get (fromJson (include "redpanda.Storage.IsTieredStorageEnabled" (dict "a" (list $values.storage)))) "r")) (ne (get (fromJson (include "redpanda.Storage.TieredMountType" (dict "a" (list $values.storage)))) "r") "persistentVolume")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $pvc := (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "resources" (dict)) "status" (dict)) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (default "tiered-storage-dir" $values.storage.persistentVolume.nameOverwrite) "labels" (merge (dict) (dict `app.kubernetes.io/name` (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r") `app.kubernetes.io/instance` $dot.Release.Name `app.kubernetes.io/component` (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r")) (get (fromJson (include "redpanda.Storage.TieredPersistentVolumeLabels" (dict "a" (list $values.storage)))) "r") $values.commonLabels) "annotations" (default (coalesce nil) (get (fromJson (include "redpanda.Storage.TieredPersistentVolumeAnnotations" (dict "a" (list $values.storage)))) "r")))) "spec" (mustMergeOverwrite (dict "resources" (dict)) (dict "accessModes" (list "ReadWriteOnce") "resources" (mustMergeOverwrite (dict) (dict "requests" (dict "storage" (index (get (fromJson (include "redpanda.Storage.GetTieredStorageConfig" (dict "a" (list $values.storage)))) "r") `cloud_storage_cache_size`)))))))) -}}
{{- $sc_15 := (get (fromJson (include "redpanda.Storage.TieredPersistentVolumeStorageClass" (dict "a" (list $values.storage)))) "r") -}}
{{- if (eq $sc_15 "-") -}}
{{- $_ := (set $pvc.spec "storageClassName" "") -}}
{{- else -}}{{- if (not (empty $sc_15)) -}}
{{- $_ := (set $pvc.spec "storageClassName" $sc_15) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $pvc) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.statefulSetTopologySpreadConstraints" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $result := (coalesce nil) -}}
{{- $labelSelector := (mustMergeOverwrite (dict) (dict "matchLabels" (get (fromJson (include "redpanda.StatefulSetPodLabelsSelector" (dict "a" (list $dot)))) "r"))) -}}
{{- range $_, $v := $values.statefulset.topologySpreadConstraints -}}
{{- $result = (concat (default (list) $result) (list (mustMergeOverwrite (dict "maxSkew" 0 "topologyKey" "" "whenUnsatisfiable" "") (dict "maxSkew" ($v.maxSkew | int) "topologyKey" $v.topologyKey "whenUnsatisfiable" $v.whenUnsatisfiable "labelSelector" $labelSelector)))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StorageTieredConfig" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.Storage.GetTieredStorageConfig" (dict "a" (list $values.storage)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

