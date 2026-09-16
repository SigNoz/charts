{{- /* Generated from "helpers.go" */ -}}

{{- define "redpanda.ChartLabel" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.cleanForK8s" (dict "a" (list (replace "+" "_" (printf "%s-%s" $dot.Chart.Name $dot.Chart.Version)))))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Name" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_51_override_1_ok_2 := (get (fromJson (include "_shims.typetest" (dict "a" (list "string" (index $dot.Values "nameOverride") "")))) "r") -}}
{{- $override_1 := (index $_51_override_1_ok_2 0) -}}
{{- $ok_2 := (index $_51_override_1_ok_2 1) -}}
{{- if (and $ok_2 (ne $override_1 "")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.cleanForK8s" (dict "a" (list $override_1)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.cleanForK8s" (dict "a" (list $dot.Chart.Name)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Fullname" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_61_override_3_ok_4 := (get (fromJson (include "_shims.typetest" (dict "a" (list "string" (index $dot.Values "fullnameOverride") "")))) "r") -}}
{{- $override_3 := (index $_61_override_3_ok_4 0) -}}
{{- $ok_4 := (index $_61_override_3_ok_4 1) -}}
{{- if (and $ok_4 (ne $override_3 "")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.cleanForK8s" (dict "a" (list $override_3)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.cleanForK8s" (dict "a" (list $dot.Release.Name)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.FullLabels" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $labels := (dict) -}}
{{- if (ne (toJson $values.commonLabels) "null") -}}
{{- $labels = $values.commonLabels -}}
{{- end -}}
{{- $defaults := (dict "helm.sh/chart" (get (fromJson (include "redpanda.ChartLabel" (dict "a" (list $dot)))) "r") "app.kubernetes.io/name" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r") "app.kubernetes.io/instance" $dot.Release.Name "app.kubernetes.io/managed-by" $dot.Release.Service "app.kubernetes.io/component" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $labels $defaults)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Tag" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $tag := (toString $values.image.tag) -}}
{{- if (eq $tag "") -}}
{{- $tag = $dot.Chart.AppVersion -}}
{{- end -}}
{{- $pattern := "^v(0|[1-9]\\d*)\\.(0|[1-9]\\d*)\\.(0|[1-9]\\d*)(?:-((?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$" -}}
{{- if (not (regexMatch $pattern $tag)) -}}
{{- $_ := (fail "image.tag must start with a 'v' and be a valid semver") -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $tag) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ServiceName" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (and (ne (toJson $values.service) "null") (ne (toJson $values.service.name) "null")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.cleanForK8s" (dict "a" (list $values.service.name)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.InternalDomain" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $service := (get (fromJson (include "redpanda.ServiceName" (dict "a" (list $dot)))) "r") -}}
{{- $ns := $dot.Release.Namespace -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s.%s.svc.%s" $service $ns $values.clusterDomain)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.TLSEnabled" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if $values.tls.enabled -}}
{{- $_is_returning = true -}}
{{- (dict "r" true) | toJson -}}
{{- break -}}
{{- end -}}
{{- $listeners := (list "kafka" "admin" "schemaRegistry" "rpc" "http") -}}
{{- range $_, $listener := $listeners -}}
{{- $tlsCert := (dig "listeners" $listener "tls" "cert" false $dot.Values.AsMap) -}}
{{- $tlsEnabled := (dig "listeners" $listener "tls" "enabled" false $dot.Values.AsMap) -}}
{{- if (and (not (empty $tlsEnabled)) (not (empty $tlsCert))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" true) | toJson -}}
{{- break -}}
{{- end -}}
{{- $external := (dig "listeners" $listener "external" false $dot.Values.AsMap) -}}
{{- if (empty $external) -}}
{{- continue -}}
{{- end -}}
{{- $keys := (keys (get (fromJson (include "_shims.typeassertion" (dict "a" (list (printf "map[%s]%s" "string" "interface {}") $external)))) "r")) -}}
{{- range $_, $key := $keys -}}
{{- $enabled := (dig "listeners" $listener "external" $key "enabled" false $dot.Values.AsMap) -}}
{{- $tlsCert := (dig "listeners" $listener "external" $key "tls" "cert" false $dot.Values.AsMap) -}}
{{- $tlsEnabled := (dig "listeners" $listener "external" $key "tls" "enabled" false $dot.Values.AsMap) -}}
{{- if (and (and (not (empty $enabled)) (not (empty $tlsCert))) (not (empty $tlsEnabled))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" true) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" false) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ClientAuthRequired" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $listeners := (list "kafka" "admin" "schemaRegistry" "rpc" "http") -}}
{{- range $_, $listener := $listeners -}}
{{- $required := (dig "listeners" $listener "tls" "requireClientAuth" false $dot.Values.AsMap) -}}
{{- if (not (empty $required)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" true) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" false) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.DefaultMounts" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "base-config" "mountPath" "/etc/redpanda")))) (default (list) (get (fromJson (include "redpanda.CommonMounts" (dict "a" (list $dot)))) "r")))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.CommonMounts" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $mounts := (list) -}}
{{- $sasl_5 := $values.auth.sasl -}}
{{- if (and $sasl_5.enabled (ne $sasl_5.secretRef "")) -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "users" "mountPath" "/etc/secrets/users" "readOnly" true)))) -}}
{{- end -}}
{{- if (get (fromJson (include "redpanda.TLSEnabled" (dict "a" (list $dot)))) "r") -}}
{{- $certNames := (keys $values.tls.certs) -}}
{{- $_ := (sortAlpha $certNames) -}}
{{- range $_, $name := $certNames -}}
{{- $cert := (ternary (index $values.tls.certs $name) (dict "enabled" (coalesce nil) "caEnabled" false "applyInternalDNSNames" (coalesce nil) "duration" "" "issuerRef" (coalesce nil) "secretRef" (coalesce nil) "clientSecretRef" (coalesce nil)) (hasKey $values.tls.certs $name)) -}}
{{- if (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $cert.enabled true)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" (printf "redpanda-%s-cert" $name) "mountPath" (printf "%s/%s" "/etc/tls/certs" $name))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $adminTLS := $values.listeners.admin.tls -}}
{{- if $adminTLS.requireClientAuth -}}
{{- $mounts = (concat (default (list) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "") (dict "name" "mtls-client" "mountPath" (printf "%s/%s-client" "/etc/tls/certs" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")))))) -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $mounts) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.DefaultVolumes" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "configMap" (mustMergeOverwrite (dict) (mustMergeOverwrite (dict) (dict "name" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r"))) (dict)))) (dict "name" "base-config")))) (default (list) (get (fromJson (include "redpanda.CommonVolumes" (dict "a" (list $dot)))) "r")))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.CommonVolumes" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $volumes := (list) -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (get (fromJson (include "redpanda.TLSEnabled" (dict "a" (list $dot)))) "r") -}}
{{- $certNames := (keys $values.tls.certs) -}}
{{- $_ := (sortAlpha $certNames) -}}
{{- range $_, $name := $certNames -}}
{{- $cert := (ternary (index $values.tls.certs $name) (dict "enabled" (coalesce nil) "caEnabled" false "applyInternalDNSNames" (coalesce nil) "duration" "" "issuerRef" (coalesce nil) "secretRef" (coalesce nil) "clientSecretRef" (coalesce nil)) (hasKey $values.tls.certs $name)) -}}
{{- if (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $cert.enabled true)))) "r")) -}}
{{- continue -}}
{{- end -}}
{{- $volumes = (concat (default (list) $volumes) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" (get (fromJson (include "redpanda.CertSecretName" (dict "a" (list $dot $name $cert)))) "r") "defaultMode" (0o440 | int))))) (dict "name" (printf "redpanda-%s-cert" $name))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $adminTLS := $values.listeners.admin.tls -}}
{{- $cert := (ternary (index $values.tls.certs $adminTLS.cert) (dict "enabled" (coalesce nil) "caEnabled" false "applyInternalDNSNames" (coalesce nil) "duration" "" "issuerRef" (coalesce nil) "secretRef" (coalesce nil) "clientSecretRef" (coalesce nil)) (hasKey $values.tls.certs $adminTLS.cert)) -}}
{{- if $adminTLS.requireClientAuth -}}
{{- $secretName := (printf "%s-client" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) -}}
{{- if (ne (toJson $cert.clientSecretRef) "null") -}}
{{- $secretName = $cert.clientSecretRef.name -}}
{{- end -}}
{{- $volumes = (concat (default (list) $volumes) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" $secretName "defaultMode" (0o440 | int))))) (dict "name" "mtls-client")))) -}}
{{- end -}}
{{- end -}}
{{- $sasl_6 := $values.auth.sasl -}}
{{- if (and $sasl_6.enabled (ne $sasl_6.secretRef "")) -}}
{{- $volumes = (concat (default (list) $volumes) (list (mustMergeOverwrite (dict "name" "") (mustMergeOverwrite (dict) (dict "secret" (mustMergeOverwrite (dict) (dict "secretName" $sasl_6.secretRef)))) (dict "name" "users")))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $volumes) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.CertSecretName" -}}
{{- $dot := (index .a 0) -}}
{{- $certName := (index .a 1) -}}
{{- $cert := (index .a 2) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (ne (toJson $cert.secretRef) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $cert.secretRef.name) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s-%s-cert" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") $certName)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.PodSecurityContext" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $sc := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.statefulset.podSecurityContext $values.statefulset.securityContext)))) "r") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict) (dict "fsGroup" $sc.fsGroup "fsGroupChangePolicy" $sc.fsGroupChangePolicy))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ContainerSecurityContext" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $sc := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.statefulset.podSecurityContext $values.statefulset.securityContext)))) "r") -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict) (dict "runAsUser" $sc.runAsUser "runAsGroup" (get (fromJson (include "redpanda.coalesce" (dict "a" (list (list $sc.runAsGroup $sc.fsGroup))))) "r") "allowPrivilegeEscalation" (get (fromJson (include "redpanda.coalesce" (dict "a" (list (list $sc.allowPrivilegeEscalation $sc.allowPriviledgeEscalation))))) "r") "runAsNonRoot" $sc.runAsNonRoot))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_22_2_0" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=22.2.0-0 || <0.0.1-0")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_22_3_0" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=22.3.0-0 || <0.0.1-0")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_23_1_1" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=23.1.1-0 || <0.0.1-0")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_23_1_2" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=23.1.2-0 || <0.0.1-0")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_22_3_atleast_22_3_13" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=22.3.13-0,<22.4")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_22_2_atleast_22_2_10" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=22.2.10-0,<22.3")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_23_2_1" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=23.2.1-0 || <0.0.1-0")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RedpandaAtLeast_23_3_0" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (get (fromJson (include "redpanda.redpandaAtLeast" (dict "a" (list $dot ">=23.3.0-0 || <0.0.1-0")))) "r")) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.redpandaAtLeast" -}}
{{- $dot := (index .a 0) -}}
{{- $constraint := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $version := (trimPrefix "v" (get (fromJson (include "redpanda.Tag" (dict "a" (list $dot)))) "r")) -}}
{{- $_385_result_err := (list (semverCompare $constraint $version) nil) -}}
{{- $result := (index $_385_result_err 0) -}}
{{- $err := (index $_385_result_err 1) -}}
{{- if (ne (toJson $err) "null") -}}
{{- $_ := (fail $err) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $result) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.cleanForK8s" -}}
{{- $in := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (trimSuffix "-" (trunc (63 | int) $in))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.cleanForK8sWithSuffix" -}}
{{- $s := (index .a 0) -}}
{{- $suffix := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $lengthToTruncate := ((sub (((add ((get (fromJson (include "_shims.len" (dict "a" (list $s)))) "r") | int) ((get (fromJson (include "_shims.len" (dict "a" (list $suffix)))) "r") | int)) | int)) (63 | int)) | int) -}}
{{- if (gt $lengthToTruncate (0 | int)) -}}
{{- $s = (trunc $lengthToTruncate $s) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s-%s" $s $suffix)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.coalesce" -}}
{{- $values := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- range $_, $v := $values -}}
{{- if (ne (toJson $v) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $v) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.StrategicMergePatch" -}}
{{- $overrides := (index .a 0) -}}
{{- $original := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $overrideSpec := $overrides.spec -}}
{{- if (eq (toJson $overrideSpec) "null") -}}
{{- $overrideSpec = (mustMergeOverwrite (dict) (dict)) -}}
{{- end -}}
{{- $merged := (merge (dict) (mustMergeOverwrite (dict) (dict "metadata" (mustMergeOverwrite (dict) (dict "labels" $overrides.labels "annotations" $overrides.annotations)) "spec" $overrideSpec)) $original) -}}
{{- $_ := (set $merged.spec "initContainers" (get (fromJson (include "redpanda.mergeSliceBy" (dict "a" (list $original.spec.initContainers $overrideSpec.initContainers "name" "redpanda.mergeContainer")))) "r")) -}}
{{- $_ := (set $merged.spec "containers" (get (fromJson (include "redpanda.mergeSliceBy" (dict "a" (list $original.spec.containers $overrideSpec.containers "name" "redpanda.mergeContainer")))) "r")) -}}
{{- $_ := (set $merged.spec "volumes" (get (fromJson (include "redpanda.mergeSliceBy" (dict "a" (list $original.spec.volumes $overrideSpec.volumes "name" "redpanda.mergeVolume")))) "r")) -}}
{{- if (eq (toJson $merged.metadata.labels) "null") -}}
{{- $_ := (set $merged.metadata "labels" (dict)) -}}
{{- end -}}
{{- if (eq (toJson $merged.metadata.annotations) "null") -}}
{{- $_ := (set $merged.metadata "annotations" (dict)) -}}
{{- end -}}
{{- if (eq (toJson $merged.spec.nodeSelector) "null") -}}
{{- $_ := (set $merged.spec "nodeSelector" (dict)) -}}
{{- end -}}
{{- if (eq (toJson $merged.spec.tolerations) "null") -}}
{{- $_ := (set $merged.spec "tolerations" (list)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $merged) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.mergeSliceBy" -}}
{{- $original := (index .a 0) -}}
{{- $override := (index .a 1) -}}
{{- $mergeKey := (index .a 2) -}}
{{- $mergeFunc := (index .a 3) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $originalKeys := (dict) -}}
{{- $overrideByKey := (dict) -}}
{{- range $_, $el := $override -}}
{{- $_497_key_ok := (get (fromJson (include "_shims.get" (dict "a" (list $el $mergeKey)))) "r") -}}
{{- $key := (index $_497_key_ok 0) -}}
{{- $ok := (index $_497_key_ok 1) -}}
{{- if (not $ok) -}}
{{- continue -}}
{{- end -}}
{{- $_ := (set $overrideByKey $key $el) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $merged := (coalesce nil) -}}
{{- range $_, $el := $original -}}
{{- $_509_key__ := (get (fromJson (include "_shims.get" (dict "a" (list $el $mergeKey)))) "r") -}}
{{- $key := (index $_509_key__ 0) -}}
{{- $_ := (index $_509_key__ 1) -}}
{{- $_ := (set $originalKeys $key true) -}}
{{- $_511_elOverride_7_ok_8 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $overrideByKey $key (coalesce nil))))) "r") -}}
{{- $elOverride_7 := (index $_511_elOverride_7_ok_8 0) -}}
{{- $ok_8 := (index $_511_elOverride_7_ok_8 1) -}}
{{- if $ok_8 -}}
{{- $merged = (concat (default (list) $merged) (list (get (fromJson (include $mergeFunc (dict "a" (list $el $elOverride_7)))) "r"))) -}}
{{- else -}}
{{- $merged = (concat (default (list) $merged) (list $el)) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- range $_, $el := $override -}}
{{- $_521_key_ok := (get (fromJson (include "_shims.get" (dict "a" (list $el $mergeKey)))) "r") -}}
{{- $key := (index $_521_key_ok 0) -}}
{{- $ok := (index $_521_key_ok 1) -}}
{{- if (not $ok) -}}
{{- continue -}}
{{- end -}}
{{- $_526___ok_9 := (get (fromJson (include "_shims.dicttest" (dict "a" (list $originalKeys $key false)))) "r") -}}
{{- $_ := (index $_526___ok_9 0) -}}
{{- $ok_9 := (index $_526___ok_9 1) -}}
{{- if $ok_9 -}}
{{- continue -}}
{{- end -}}
{{- $merged = (concat (default (list) $merged) (list (merge (dict) $el))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $merged) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.mergeEnvVar" -}}
{{- $original := (index .a 0) -}}
{{- $overrides := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $overrides)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.mergeVolume" -}}
{{- $original := (index .a 0) -}}
{{- $override := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $override $original)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.mergeVolumeMount" -}}
{{- $original := (index .a 0) -}}
{{- $override := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (merge (dict) $override $original)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.mergeContainer" -}}
{{- $original := (index .a 0) -}}
{{- $override := (index .a 1) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $merged := (merge (dict) $override $original) -}}
{{- $_ := (set $merged "env" (get (fromJson (include "redpanda.mergeSliceBy" (dict "a" (list $original.env $override.env "name" "redpanda.mergeEnvVar")))) "r")) -}}
{{- $_ := (set $merged "volumeMounts" (get (fromJson (include "redpanda.mergeSliceBy" (dict "a" (list $original.volumeMounts $override.volumeMounts "name" "redpanda.mergeVolumeMount")))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $merged) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ParseCLIArgs" -}}
{{- $args := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $parsed := (dict) -}}
{{- $i := -1 -}}
{{- range $_, $_ := $args -}}
{{- $i = ((add $i (1 | int)) | int) -}}
{{- if (ge $i ((get (fromJson (include "_shims.len" (dict "a" (list $args)))) "r") | int)) -}}
{{- break -}}
{{- end -}}
{{- if (not (hasPrefix "-" (index $args $i))) -}}
{{- continue -}}
{{- end -}}
{{- $flag := (index $args $i) -}}
{{- $spl := (mustRegexSplit " |=" $flag (2 | int)) -}}
{{- if (eq ((get (fromJson (include "_shims.len" (dict "a" (list $spl)))) "r") | int) (2 | int)) -}}
{{- $_ := (set $parsed (index $spl (0 | int)) (index $spl (1 | int))) -}}
{{- continue -}}
{{- end -}}
{{- if (and (lt ((add $i (1 | int)) | int) ((get (fromJson (include "_shims.len" (dict "a" (list $args)))) "r") | int)) (not (hasPrefix "-" (index $args ((add $i (1 | int)) | int))))) -}}
{{- $_ := (set $parsed $flag (index $args ((add $i (1 | int)) | int))) -}}
{{- $i = ((add $i (1 | int)) | int) -}}
{{- continue -}}
{{- end -}}
{{- $_ := (set $parsed $flag "") -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $parsed) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

