{{- /* Generated from "deployment.go" */ -}}

{{- define "console.ContainerPort" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $listenPort := ((8080 | int) | int) -}}
{{- if (ne (toJson $values.service.targetPort) "null") -}}
{{- $listenPort = $values.service.targetPort -}}
{{- end -}}
{{- $configListenPort := (dig "server" "listenPort" (coalesce nil) $values.console.config) -}}
{{- $tmp_tuple_1 := (get (fromJson (include "_shims.compact" (dict "a" (list (get (fromJson (include "_shims.asintegral" (dict "a" (list $configListenPort) ))) "r")) ))) "r") -}}
{{- $ok_2 := $tmp_tuple_1.T2 -}}
{{- $asInt_1 := ($tmp_tuple_1.T1 | int) -}}
{{- if $ok_2 -}}
{{- $_is_returning = true -}}
{{- (dict "r" ($asInt_1 | int)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $listenPort) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.Deployment" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.deployment.create) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $replicas := (coalesce nil) -}}
{{- if (not $values.autoscaling.enabled) -}}
{{- $replicas = ($values.replicaCount | int) -}}
{{- end -}}
{{- $initContainers := (coalesce nil) -}}
{{- if (not (empty $values.initContainers.extraInitContainers)) -}}
{{- $initContainers = (fromYamlArray (tpl $values.initContainers.extraInitContainers $dot)) -}}
{{- end -}}
{{- $volumeMounts := (list (mustMergeOverwrite (dict "name" "" "mountPath" "" ) (dict "name" "configs" "mountPath" "/etc/console/configs" "readOnly" true ))) -}}
{{- if $values.secret.create -}}
{{- $volumeMounts = (concat (default (list ) $volumeMounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "" ) (dict "name" "secrets" "mountPath" "/etc/console/secrets" "readOnly" true )))) -}}
{{- end -}}
{{- range $_, $mount := $values.secretMounts -}}
{{- $volumeMounts = (concat (default (list ) $volumeMounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "" ) (dict "name" $mount.name "mountPath" $mount.path "subPath" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $mount.subPath "") ))) "r") )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $volumeMounts = (concat (default (list ) $volumeMounts) (default (list ) $values.extraVolumeMounts)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "selector" (coalesce nil) "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) "strategy" (dict ) ) "status" (dict ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "apps/v1" "kind" "Deployment" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") "labels" (get (fromJson (include "console.Labels" (dict "a" (list $dot) ))) "r") "namespace" $dot.Release.Namespace "annotations" $values.annotations )) "spec" (mustMergeOverwrite (dict "selector" (coalesce nil) "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) "strategy" (dict ) ) (dict "replicas" $replicas "selector" (mustMergeOverwrite (dict ) (dict "matchLabels" (get (fromJson (include "console.SelectorLabels" (dict "a" (list $dot) ))) "r") )) "strategy" $values.strategy "template" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "annotations" (merge (dict ) (dict "checksum/config" (sha256sum (toYaml (get (fromJson (include "console.ConfigMap" (dict "a" (list $dot) ))) "r"))) ) $values.podAnnotations) "labels" (merge (dict ) (get (fromJson (include "console.SelectorLabels" (dict "a" (list $dot) ))) "r") $values.podLabels) )) "spec" (mustMergeOverwrite (dict "containers" (coalesce nil) ) (dict "imagePullSecrets" $values.imagePullSecrets "serviceAccountName" (get (fromJson (include "console.ServiceAccountName" (dict "a" (list $dot) ))) "r") "automountServiceAccountToken" $values.automountServiceAccountToken "securityContext" $values.podSecurityContext "nodeSelector" $values.nodeSelector "affinity" $values.affinity "topologySpreadConstraints" $values.topologySpreadConstraints "priorityClassName" $values.priorityClassName "tolerations" $values.tolerations "volumes" (get (fromJson (include "console.consolePodVolumes" (dict "a" (list $dot) ))) "r") "initContainers" $initContainers "containers" (concat (default (list ) (list (mustMergeOverwrite (dict "name" "" "resources" (dict ) ) (dict "name" $dot.Chart.Name "command" $values.deployment.command "args" (concat (default (list ) (list "--config.filepath=/etc/console/configs/config.yaml")) (default (list ) $values.deployment.extraArgs)) "securityContext" $values.securityContext "image" (get (fromJson (include "console.containerImage" (dict "a" (list $dot) ))) "r") "imagePullPolicy" $values.image.pullPolicy "ports" (list (mustMergeOverwrite (dict "containerPort" 0 ) (dict "name" "http" "containerPort" ((get (fromJson (include "console.ContainerPort" (dict "a" (list $dot) ))) "r") | int) "protocol" "TCP" ))) "volumeMounts" $volumeMounts "livenessProbe" (mustMergeOverwrite (dict ) (mustMergeOverwrite (dict ) (dict "httpGet" (mustMergeOverwrite (dict "port" 0 ) (dict "path" "/admin/health" "port" "http" )) )) (dict "initialDelaySeconds" ($values.livenessProbe.initialDelaySeconds | int) "periodSeconds" ($values.livenessProbe.periodSeconds | int) "timeoutSeconds" ($values.livenessProbe.timeoutSeconds | int) "successThreshold" ($values.livenessProbe.successThreshold | int) "failureThreshold" ($values.livenessProbe.failureThreshold | int) )) "readinessProbe" (mustMergeOverwrite (dict ) (mustMergeOverwrite (dict ) (dict "httpGet" (mustMergeOverwrite (dict "port" 0 ) (dict "path" "/admin/health" "port" "http" )) )) (dict "initialDelaySeconds" ($values.readinessProbe.initialDelaySeconds | int) "periodSeconds" ($values.readinessProbe.periodSeconds | int) "timeoutSeconds" ($values.readinessProbe.timeoutSeconds | int) "successThreshold" ($values.readinessProbe.successThreshold | int) "failureThreshold" ($values.readinessProbe.failureThreshold | int) )) "resources" $values.resources "env" (get (fromJson (include "console.consoleContainerEnv" (dict "a" (list $dot) ))) "r") "envFrom" $values.extraEnvFrom )))) (default (list ) $values.extraContainers)) )) )) )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.containerImage" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $tag := $dot.Chart.AppVersion -}}
{{- if (not (empty $values.image.tag)) -}}
{{- $tag = $values.image.tag -}}
{{- end -}}
{{- $image := (printf "%s:%s" $values.image.repository $tag) -}}
{{- if (not (empty $values.image.registry)) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (printf "%s/%s" $values.image.registry $image)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $image) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.consoleContainerEnv" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.secret.create) -}}
{{- $vars := $values.extraEnv -}}
{{- if (not (empty $values.enterprise.licenseSecretRef.name)) -}}
{{- $vars = (concat (default (list ) $values.extraEnv) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "LICENSE" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" $values.enterprise.licenseSecretRef.name )) (dict "key" (default "enterprise-license" $values.enterprise.licenseSecretRef.key) )) )) )))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $vars) | toJson -}}
{{- break -}}
{{- end -}}
{{- $possibleVars := (list (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.saslPassword "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_SASL_PASSWORD" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "kafka-sasl-password" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.protobufGitBasicAuthPassword "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_PROTOBUF_GIT_BASICAUTH_PASSWORD" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "kafka-protobuf-git-basicauth-password" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.awsMskIamSecretKey "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_SASL_AWSMSKIAM_SECRETKEY" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "kafka-sasl-aws-msk-iam-secret-key" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.tlsCa "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_TLS_CAFILEPATH" "value" "/etc/console/secrets/kafka-tls-ca" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.tlsCert "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_TLS_CERTFILEPATH" "value" "/etc/console/secrets/kafka-tls-cert" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.tlsKey "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_TLS_KEYFILEPATH" "value" "/etc/console/secrets/kafka-tls-key" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.schemaRegistryTlsCa "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_SCHEMAREGISTRY_TLS_CAFILEPATH" "value" "/etc/console/secrets/kafka-schemaregistry-tls-ca" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.schemaRegistryTlsCert "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_SCHEMAREGISTRY_TLS_CERTFILEPATH" "value" "/etc/console/secrets/kafka-schemaregistry-tls-cert" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.schemaRegistryTlsKey "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_SCHEMAREGISTRY_TLS_KEYFILEPATH" "value" "/etc/console/secrets/kafka-schemaregistry-tls-key" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.kafka.schemaRegistryPassword "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "KAFKA_SCHEMAREGISTRY_PASSWORD" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "kafka-schema-registry-password" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" true "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_JWTSECRET" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "login-jwt-secret" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.login.google.clientSecret "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_GOOGLE_CLIENTSECRET" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "login-google-oauth-client-secret" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.login.google.groupsServiceAccount "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_GOOGLE_DIRECTORY_SERVICEACCOUNTFILEPATH" "value" "/etc/console/secrets/login-google-groups-service-account.json" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.login.github.clientSecret "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_GITHUB_CLIENTSECRET" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "login-github-oauth-client-secret" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.login.github.personalAccessToken "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_GITHUB_DIRECTORY_PERSONALACCESSTOKEN" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "login-github-personal-access-token" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.login.okta.clientSecret "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_OKTA_CLIENTSECRET" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "login-okta-client-secret" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.login.okta.directoryApiToken "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_OKTA_DIRECTORY_APITOKEN" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "login-okta-directory-api-token" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.login.oidc.clientSecret "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LOGIN_OIDC_CLIENTSECRET" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "login-oidc-client-secret" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.enterprise.license "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "LICENSE" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "enterprise-license" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.redpanda.adminApi.password "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "REDPANDA_ADMINAPI_PASSWORD" "valueFrom" (mustMergeOverwrite (dict ) (dict "secretKeyRef" (mustMergeOverwrite (dict "key" "" ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict "key" "redpanda-admin-api-password" )) )) )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.redpanda.adminApi.tlsCa "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "REDPANDA_ADMINAPI_TLS_CAFILEPATH" "value" "/etc/console/secrets/redpanda-admin-api-tls-ca" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.redpanda.adminApi.tlsKey "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "REDPANDA_ADMINAPI_TLS_KEYFILEPATH" "value" "/etc/console/secrets/redpanda-admin-api-tls-key" )) )) (mustMergeOverwrite (dict "Value" (coalesce nil) "EnvVar" (dict "name" "" ) ) (dict "Value" $values.secret.redpanda.adminApi.tlsCert "EnvVar" (mustMergeOverwrite (dict "name" "" ) (dict "name" "REDPANDA_ADMINAPI_TLS_CERTFILEPATH" "value" "/etc/console/secrets/redpanda-admin-api-tls-cert" )) ))) -}}
{{- $vars := $values.extraEnv -}}
{{- range $_, $possible := $possibleVars -}}
{{- if (not (empty $possible.Value)) -}}
{{- $vars = (concat (default (list ) $vars) (list $possible.EnvVar)) -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $vars) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "console.consolePodVolumes" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $volumes := (list (mustMergeOverwrite (dict "name" "" ) (mustMergeOverwrite (dict ) (dict "configMap" (mustMergeOverwrite (dict ) (mustMergeOverwrite (dict ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) (dict )) )) (dict "name" "configs" ))) -}}
{{- if $values.secret.create -}}
{{- $volumes = (concat (default (list ) $volumes) (list (mustMergeOverwrite (dict "name" "" ) (mustMergeOverwrite (dict ) (dict "secret" (mustMergeOverwrite (dict ) (dict "secretName" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") )) )) (dict "name" "secrets" )))) -}}
{{- end -}}
{{- range $_, $mount := $values.secretMounts -}}
{{- $volumes = (concat (default (list ) $volumes) (list (mustMergeOverwrite (dict "name" "" ) (mustMergeOverwrite (dict ) (dict "secret" (mustMergeOverwrite (dict ) (dict "secretName" $mount.secretName "defaultMode" $mount.defaultMode )) )) (dict "name" $mount.name )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list ) $volumes) (default (list ) $values.extraVolumes))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

