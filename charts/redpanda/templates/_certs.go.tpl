{{- /* Generated from "certs.go" */ -}}

{{- define "redpanda.ClientCerts" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (not (get (fromJson (include "redpanda.TLSEnabled" (dict "a" (list $dot)))) "r")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (list)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $values := $dot.Values.AsMap -}}
{{- $fullname := (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") -}}
{{- $service := (get (fromJson (include "redpanda.ServiceName" (dict "a" (list $dot)))) "r") -}}
{{- $ns := $dot.Release.Namespace -}}
{{- $domain := (trimSuffix "." $values.clusterDomain) -}}
{{- $certs := (coalesce nil) -}}
{{- range $name, $data := $values.tls.certs -}}
{{- if (or (not (empty $data.secretRef)) (not (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $data.enabled true)))) "r"))) -}}
{{- continue -}}
{{- end -}}
{{- $names := (coalesce nil) -}}
{{- if (or (eq (toJson $data.issuerRef) "null") (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $data.applyInternalDNSNames false)))) "r")) -}}
{{- $names = (concat (default (list) $names) (list (printf "%s-cluster.%s.%s.svc.%s" $fullname $service $ns $domain))) -}}
{{- $names = (concat (default (list) $names) (list (printf "%s-cluster.%s.%s.svc" $fullname $service $ns))) -}}
{{- $names = (concat (default (list) $names) (list (printf "%s-cluster.%s.%s" $fullname $service $ns))) -}}
{{- $names = (concat (default (list) $names) (list (printf "*.%s-cluster.%s.%s.svc.%s" $fullname $service $ns $domain))) -}}
{{- $names = (concat (default (list) $names) (list (printf "*.%s-cluster.%s.%s.svc" $fullname $service $ns))) -}}
{{- $names = (concat (default (list) $names) (list (printf "*.%s-cluster.%s.%s" $fullname $service $ns))) -}}
{{- $names = (concat (default (list) $names) (list (printf "%s.%s.svc.%s" $service $ns $domain))) -}}
{{- $names = (concat (default (list) $names) (list (printf "%s.%s.svc" $service $ns))) -}}
{{- $names = (concat (default (list) $names) (list (printf "%s.%s" $service $ns))) -}}
{{- $names = (concat (default (list) $names) (list (printf "*.%s.%s.svc.%s" $service $ns $domain))) -}}
{{- $names = (concat (default (list) $names) (list (printf "*.%s.%s.svc" $service $ns))) -}}
{{- $names = (concat (default (list) $names) (list (printf "*.%s.%s" $service $ns))) -}}
{{- end -}}
{{- if (ne (toJson $values.external.domain) "null") -}}
{{- $names = (concat (default (list) $names) (list (tpl $values.external.domain $dot))) -}}
{{- $names = (concat (default (list) $names) (list (printf "*.%s" (tpl $values.external.domain $dot)))) -}}
{{- end -}}
{{- $duration := (default "43800h" $data.duration) -}}
{{- $issuerRef := (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $data.issuerRef (mustMergeOverwrite (dict "name" "") (dict "kind" "Issuer" "group" "cert-manager.io" "name" (printf "%s-%s-root-issuer" $fullname $name))))))) "r") -}}
{{- $certs = (concat (default (list) $certs) (list (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "secretName" "" "issuerRef" (dict "name" "")) "status" (dict)) (mustMergeOverwrite (dict) (dict "apiVersion" "cert-manager.io/v1" "kind" "Certificate")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (printf "%s-%s-cert" $fullname $name) "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace)) "spec" (mustMergeOverwrite (dict "secretName" "" "issuerRef" (dict "name" "")) (dict "dnsNames" $names "duration" (get (fromJson (include "_shims.time_Duration_String" (dict "a" (list (get (fromJson (include "_shims.time_ParseDuration" (dict "a" (list $duration)))) "r"))))) "r") "isCA" false "issuerRef" $issuerRef "secretName" (printf "%s-%s-cert" $fullname $name) "privateKey" (mustMergeOverwrite (dict) (dict "algorithm" "ECDSA" "size" (256 | int))))))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $name := $values.listeners.kafka.tls.cert -}}
{{- $_99_data_ok := (get (fromJson (include "_shims.dicttest" (dict "a" (list $values.tls.certs $name (dict "enabled" (coalesce nil) "caEnabled" false "applyInternalDNSNames" (coalesce nil) "duration" "" "issuerRef" (coalesce nil) "secretRef" (coalesce nil) "clientSecretRef" (coalesce nil)))))) "r") -}}
{{- $data := (index $_99_data_ok 0) -}}
{{- $ok := (index $_99_data_ok 1) -}}
{{- if (not $ok) -}}
{{- $_ := (fail (printf "Certificate %q referenced but not defined" $name)) -}}
{{- end -}}
{{- if (or (not (empty $data.secretRef)) (not (get (fromJson (include "redpanda.ClientAuthRequired" (dict "a" (list $dot)))) "r"))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $certs) | toJson -}}
{{- break -}}
{{- end -}}
{{- $issuerRef := (mustMergeOverwrite (dict "name" "") (dict "group" "cert-manager.io" "kind" "Issuer" "name" (printf "%s-%s-root-issuer" $fullname $name))) -}}
{{- if (ne (toJson $data.issuerRef) "null") -}}
{{- $issuerRef = $data.issuerRef -}}
{{- $_ := (set $issuerRef "group" "cert-manager.io") -}}
{{- end -}}
{{- $duration := (default "43800h" $data.duration) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list) $certs) (list (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "spec" (dict "secretName" "" "issuerRef" (dict "name" "")) "status" (dict)) (mustMergeOverwrite (dict) (dict "apiVersion" "cert-manager.io/v1" "kind" "Certificate")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" (printf "%s-client" $fullname) "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r"))) "spec" (mustMergeOverwrite (dict "secretName" "" "issuerRef" (dict "name" "")) (dict "commonName" (printf "%s-client" $fullname) "duration" (get (fromJson (include "_shims.time_Duration_String" (dict "a" (list (get (fromJson (include "_shims.time_ParseDuration" (dict "a" (list $duration)))) "r"))))) "r") "isCA" false "secretName" (printf "%s-client" $fullname) "privateKey" (mustMergeOverwrite (dict) (dict "algorithm" "ECDSA" "size" (256 | int))) "issuerRef" $issuerRef))))))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

