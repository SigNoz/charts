{{- /* Generated from "notes.go" */ -}}

{{- define "redpanda.Warnings" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $warnings := (coalesce nil) -}}
{{- $w_1 := (get (fromJson (include "redpanda.cpuWarning" (dict "a" (list $dot)))) "r") -}}
{{- if (ne $w_1 "") -}}
{{- $warnings = (concat (default (list) $warnings) (list (printf `**Warning**: %s` $w_1))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $warnings) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.cpuWarning" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $coresInMillis := ((get (fromJson (include "_shims.resource_MilliValue" (dict "a" (list $values.resources.cpu.cores)))) "r") | int64) -}}
{{- if (lt $coresInMillis (1000 | int64)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%dm is below the minimum recommended CPU value for Redpanda" $coresInMillis)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" "") | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.Notes" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $anySASL := (get (fromJson (include "redpanda.Auth.IsSASLEnabled" (dict "a" (list $values.auth)))) "r") -}}
{{- $notes := (coalesce nil) -}}
{{- $notes = (concat (default (list) $notes) (list `` `` `` `` (printf `Congratulations on installing %s!` $dot.Chart.Name) `` `The pods will rollout in a few seconds. To check the status:` `` (printf `  kubectl -n %s rollout status statefulset %s --watch` $dot.Release.Namespace (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")))) -}}
{{- if (and $values.external.enabled (eq $values.external.type "LoadBalancer")) -}}
{{- $notes = (concat (default (list) $notes) (list `` `If you are using the load balancer service with a cloud provider, the services will likely have automatically-generated addresses. In this scenario the advertised listeners must be updated in order for external access to work. Run the following command once Redpanda is deployed:` `` (printf `  helm upgrade %s redpanda/redpanda --reuse-values -n %s --set $(kubectl get svc -n %s -o jsonpath='{"external.addresses={"}{ range .items[*]}{.status.loadBalancer.ingress[0].ip }{.status.loadBalancer.ingress[0].hostname}{","}{ end }{"}\n"}')` (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r") $dot.Release.Namespace $dot.Release.Namespace))) -}}
{{- end -}}
{{- $profiles := (keys $values.listeners.kafka.external) -}}
{{- $_ := (sortAlpha $profiles) -}}
{{- $profileName := (index $profiles (0 | int)) -}}
{{- $notes = (concat (default (list) $notes) (list `` `Set up rpk for access to your external listeners:`)) -}}
{{- $profile := (ternary (index $values.listeners.kafka.external $profileName) (dict "enabled" (coalesce nil) "advertisedPorts" (coalesce nil) "port" 0 "nodePort" (coalesce nil) "authenticationMethod" (coalesce nil) "prefixTemplate" (coalesce nil) "tls" (coalesce nil)) (hasKey $values.listeners.kafka.external $profileName)) -}}
{{- if (get (fromJson (include "redpanda.TLSEnabled" (dict "a" (list $dot)))) "r") -}}
{{- $external := "" -}}
{{- if (and (ne (toJson $profile.tls) "null") (ne (toJson $profile.tls.cert) "null")) -}}
{{- $external = $profile.tls.cert -}}
{{- else -}}
{{- $external = $values.listeners.kafka.tls.cert -}}
{{- end -}}
{{- $notes = (concat (default (list) $notes) (list (printf `  kubectl get secret -n %s %s-%s-cert -o go-template='{{ index .data "ca.crt" | base64decode }}' > ca.crt` $dot.Release.Namespace (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") $external))) -}}
{{- if (or $values.listeners.kafka.tls.requireClientAuth $values.listeners.admin.tls.requireClientAuth) -}}
{{- $notes = (concat (default (list) $notes) (list (printf `  kubectl get secret -n %s %s-client -o go-template='{{ index .data "tls.crt" | base64decode }}' > tls.crt` $dot.Release.Namespace (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")) (printf `  kubectl get secret -n %s %s-client -o go-template='{{ index .data "tls.key" | base64decode }}' > tls.key` $dot.Release.Namespace (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r")))) -}}
{{- end -}}
{{- end -}}
{{- $notes = (concat (default (list) $notes) (list (printf `  rpk profile create --from-profile <(kubectl get configmap -n %s %s-rpk -o go-template='{{ .data.profile }}') %s` $dot.Release.Namespace (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") $profileName) `` `Set up dns to look up the pods on their Kubernetes Nodes. You can use this query to get the list of short-names to IP addresses. Add your external domain to the hostnames and you could test by adding these to your /etc/hosts:` `` (printf `  kubectl get pod -n %s -o custom-columns=node:.status.hostIP,name:.metadata.name --no-headers -l app.kubernetes.io/name=redpanda,app.kubernetes.io/component=redpanda-statefulset` $dot.Release.Namespace))) -}}
{{- if $anySASL -}}
{{- $notes = (concat (default (list) $notes) (list `` `Set the credentials in the environment:` `` (printf `  kubectl -n %s get secret %s -o go-template="{{ range .data }}{{ . | base64decode }}{{ end }}" | IFS=: read -r %s` $dot.Release.Namespace $values.auth.sasl.secretRef (get (fromJson (include "redpanda.RpkSASLEnvironmentVariables" (dict "a" (list $dot)))) "r")) (printf `  export %s` (get (fromJson (include "redpanda.RpkSASLEnvironmentVariables" (dict "a" (list $dot)))) "r")))) -}}
{{- end -}}
{{- $notes = (concat (default (list) $notes) (list `` `Try some sample commands:`)) -}}
{{- if $anySASL -}}
{{- $notes = (concat (default (list) $notes) (list `Create a user:` `` (printf `  %s` (get (fromJson (include "redpanda.RpkACLUserCreate" (dict "a" (list $dot)))) "r")) `` `Give the user permissions:` `` (printf `  %s` (get (fromJson (include "redpanda.RpkACLCreate" (dict "a" (list $dot)))) "r")))) -}}
{{- end -}}
{{- $notes = (concat (default (list) $notes) (list `` `Get the api status:` `` (printf `  %s` (get (fromJson (include "redpanda.RpkClusterInfo" (dict "a" (list $dot)))) "r")) `` `Create a topic` `` (printf `  %s` (get (fromJson (include "redpanda.RpkTopicCreate" (dict "a" (list $dot)))) "r")) `` `Describe the topic:` `` (printf `  %s` (get (fromJson (include "redpanda.RpkTopicDescribe" (dict "a" (list $dot)))) "r")) `` `Delete the topic:` `` (printf `  %s` (get (fromJson (include "redpanda.RpkTopicDelete" (dict "a" (list $dot)))) "r")))) -}}
{{- $_is_returning = true -}}
{{- (dict "r" $notes) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RpkACLUserCreate" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf `rpk acl user create myuser --new-password changeme --mechanism %s` (get (fromJson (include "redpanda.SASLMechanism" (dict "a" (list $dot)))) "r"))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.SASLMechanism" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (ne (toJson $values.auth.sasl) "null") -}}
{{- $_is_returning = true -}}
{{- (dict "r" $values.auth.sasl.mechanism) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" "SCRAM-SHA-512") | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RpkACLCreate" -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" `rpk acl create --allow-principal 'myuser' --allow-host '*' --operation all --topic 'test-topic'`) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RpkClusterInfo" -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" `rpk cluster info`) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RpkTopicCreate" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf `rpk topic create test-topic -p 3 -r %d` (min (3 | int64) (($values.statefulset.replicas | int) | int64)))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RpkTopicDescribe" -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" `rpk topic describe test-topic`) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RpkTopicDelete" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $_is_returning = true -}}
{{- (dict "r" `rpk topic delete test-topic`) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RpkSASLEnvironmentVariables" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- if (get (fromJson (include "redpanda.RedpandaAtLeast_23_2_1" (dict "a" (list $dot)))) "r") -}}
{{- $_is_returning = true -}}
{{- (dict "r" `RPK_USER RPK_PASS RPK_SASL_MECHANISM`) | toJson -}}
{{- break -}}
{{- else -}}
{{- $_is_returning = true -}}
{{- (dict "r" `REDPANDA_SASL_USERNAME REDPANDA_SASL_PASSWORD REDPANDA_SASL_MECHANISM`) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- end -}}

