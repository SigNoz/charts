{{- /* Generated from "post_install_upgrade_job.go" */ -}}

{{- define "redpanda.bootstrapYamlTemplater" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $env := (get (fromJson (include "redpanda.TieredStorageCredentials.AsEnvVars" (dict "a" (list $values.storage.tiered.credentialsSecretRef (get (fromJson (include "redpanda.Storage.GetTieredStorageConfig" (dict "a" (list $values.storage)))) "r"))))) "r") -}}
{{- $image := (printf `%s:%s` $values.statefulset.sideCars.controllers.image.repository $values.statefulset.sideCars.controllers.image.tag) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" "bootstrap-yaml-envsubst" "image" $image "command" (list "/redpanda-operator" "envsubst" "/tmp/base-config/bootstrap.yaml" "--output" "/tmp/config/.bootstrap.yaml") "env" $env "resources" (mustMergeOverwrite (dict) (dict "limits" (dict "cpu" (get (fromJson (include "_shims.resource_MustParse" (dict "a" (list "100m")))) "r") "memory" (get (fromJson (include "_shims.resource_MustParse" (dict "a" (list "125Mi")))) "r")) "requests" (dict "cpu" (get (fromJson (include "_shims.resource_MustParse" (dict "a" (list "100m")))) "r") "memory" (get (fromJson (include "_shims.resource_MustParse" (dict "a" (list "125Mi")))) "r")))) "securityContext" (mustMergeOverwrite (dict) (dict "allowPrivilegeEscalation" false "readOnlyRootFilesystem" true "runAsNonRoot" true)) "volumeMounts" (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "config" "mountPath" "/tmp/config/")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "base-config" "mountPath" "/tmp/base-config/")))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.PostInstallUpgradeJob" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.post_install_job.enabled) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $image := (printf `%s:%s` $values.statefulset.sideCars.controllers.image.repository $values.statefulset.sideCars.controllers.image.tag) -}}
{{- $job := (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "containers" (coalesce nil)))) "status" (dict)) (mustMergeOverwrite (dict) (dict "apiVersion" "batch/v1" "kind" "Job")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (printf "%s-configuration" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) "namespace" $dot.Release.Namespace "labels" (merge (dict) (default (dict) $values.post_install_job.labels) (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r")) "annotations" (merge (dict) (default (dict) $values.post_install_job.annotations) (dict "helm.sh/hook" "post-install,post-upgrade" "helm.sh/hook-delete-policy" "before-hook-creation" "helm.sh/hook-weight" "-5")))) "spec" (mustMergeOverwrite (dict "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "containers" (coalesce nil)))) (dict "template" (get (fromJson (include "redpanda.StrategicMergePatch" (dict "a" (list $values.post_install_job.podTemplate (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "containers" (coalesce nil))) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "generateName" (printf "%s-post-" $dot.Release.Name) "labels" (merge (dict) (dict "app.kubernetes.io/name" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r") "app.kubernetes.io/instance" $dot.Release.Name "app.kubernetes.io/component" (printf "%.50s-post-install" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r"))) (default (dict) $values.commonLabels)))) "spec" (mustMergeOverwrite (dict "containers" (coalesce nil)) (dict "nodeSelector" $values.nodeSelector "affinity" (get (fromJson (include "redpanda.postInstallJobAffinity" (dict "a" (list $dot)))) "r") "tolerations" (get (fromJson (include "redpanda.tolerations" (dict "a" (list $dot)))) "r") "restartPolicy" "Never" "securityContext" (get (fromJson (include "redpanda.PodSecurityContext" (dict "a" (list $dot)))) "r") "imagePullSecrets" (default (coalesce nil) $values.imagePullSecrets) "initContainers" (list (get (fromJson (include "redpanda.bootstrapYamlTemplater" (dict "a" (list $dot)))) "r")) "automountServiceAccountToken" false "containers" (list (mustMergeOverwrite (dict "name" "" "resources" (dict)) (dict "name" "post-install" "image" $image "env" (get (fromJson (include "redpanda.PostInstallUpgradeEnvironmentVariables" (dict "a" (list $dot)))) "r") "command" (list "/redpanda-operator" "sync-cluster-config" "--users-directory" "/etc/secrets/users" "--redpanda-yaml" "/tmp/base-config/redpanda.yaml" "--bootstrap-yaml" "/tmp/config/.bootstrap.yaml") "resources" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.post_install_job.resources (mustMergeOverwrite (dict) (dict)))))) "r") "securityContext" (merge (dict) (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.post_install_job.securityContext (mustMergeOverwrite (dict) (dict)))))) "r") (get (fromJson (include "redpanda.ContainerSecurityContext" (dict "a" (list $dot)))) "r")) "volumeMounts" (concat (default (list) (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r")) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "config" "mountPath" "/tmp/config")) (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "base-config" "mountPath" "/tmp/base-config"))))))) "volumes" (concat (default (list) (get (fromJson (include "redpanda.CommonVolumes" (dict "a" (list $dot)))) "r")) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "configMap" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) (dict)))) (dict "name" "base-config")) (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "emptyDir" (mustMergeOverwrite (dict) (dict)))) (dict "name" "config")))) "serviceAccountName" (get (fromJson (include "redpanda.ServiceAccountName" (dict "a" (list $dot)))) "r"))))))))) "r"))))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $job) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.postInstallJobAffinity" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not (empty $values.post_install_job.affinity)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $values.post_install_job.affinity) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $values.post_install_job.affinity $values.affinity)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.tolerations" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $result := (coalesce nil) -}}
{{- range $_, $t := $values.tolerations -}}
{{- $result = (concat (default (list) $result) (list (merge (dict) $t))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.PostInstallUpgradeEnvironmentVariables" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $envars := (list) -}}
{{- $license_1 := (get (fromJson (include "redpanda.GetLicenseLiteral" (dict "a" (list $dot)))) "r") -}}
{{- $secretReference_2 := (get (fromJson (include "redpanda.GetLicenseSecretReference" (dict "a" (list $dot)))) "r") -}}
{{- if (ne $license_1 "") -}}
{{- $envars = (concat (default (list) $envars) (list (mustMergeOverwrite (dict "name" "") (dict "name" "REDPANDA_LICENSE" "value" $license_1)))) -}}
{{- else -}}{{- if (ne (toJson $secretReference_2) "null") -}}
{{- $envars = (concat (default (list) $envars) (list (mustMergeOverwrite (dict "name" "") (dict "name" "REDPANDA_LICENSE" "valueFrom" (mustMergeOverwrite (dict) (dict "secretKeyRef" $secretReference_2)))))) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.bootstrapEnvVars" (dict "a" (list $dot $envars)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.GetLicenseLiteral" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (ne $values.enterprise.license "") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $values.enterprise.license) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $values.license_key) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.GetLicenseSecretReference" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not (empty $values.enterprise.licenseSecretRef)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "key" "") (mustMergeOverwrite (dict) (dict "name" $values.enterprise.licenseSecretRef.name)) (dict "key" $values.enterprise.licenseSecretRef.key))) | toJson -}}
{{- break -}}
{{- else -}}{{- if (not (empty $values.license_secret_ref)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "key" "") (mustMergeOverwrite (dict) (dict "name" $values.license_secret_ref.secret_name)) (dict "key" $values.license_secret_ref.secret_key))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

