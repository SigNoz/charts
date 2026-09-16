{{- /* Generated from "deployment.go" */ -}}

{{- define "connectors.Deployment" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.deployment.create) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $topologySpreadConstraints := (coalesce nil) -}}
{{- range $_, $spread := $values.deployment.topologySpreadConstraints -}}
{{- $topologySpreadConstraints = (concat (default (list ) $topologySpreadConstraints) (list (mustMergeOverwrite (dict "maxSkew" 0 "topologyKey" "" "whenUnsatisfiable" "" ) (dict "labelSelector" (mustMergeOverwrite (dict ) (dict "matchLabels" (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r") )) "maxSkew" ($spread.maxSkew | int) "topologyKey" $spread.topologyKey "whenUnsatisfiable" $spread.whenUnsatisfiable )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $ports := (list (mustMergeOverwrite (dict "containerPort" 0 ) (dict "containerPort" ($values.connectors.restPort | int) "name" "rest-api" "protocol" "TCP" ))) -}}
{{- range $_, $port := $values.service.ports -}}
{{- $ports = (concat (default (list ) $ports) (list (mustMergeOverwrite (dict "containerPort" 0 ) (dict "name" $port.name "containerPort" ($port.port | int) "protocol" "TCP" )))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $podAntiAffinity := (coalesce nil) -}}
{{- if (ne (toJson $values.deployment.podAntiAffinity) "null") -}}
{{- if (eq $values.deployment.podAntiAffinity.type "hard") -}}
{{- $podAntiAffinity = (mustMergeOverwrite (dict ) (dict "requiredDuringSchedulingIgnoredDuringExecution" (list (mustMergeOverwrite (dict "topologyKey" "" ) (dict "topologyKey" $values.deployment.podAntiAffinity.topologyKey "namespaces" (list $dot.Release.Namespace) "labelSelector" (mustMergeOverwrite (dict ) (dict "matchLabels" (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r") )) ))) )) -}}
{{- else -}}{{- if (eq $values.deployment.podAntiAffinity.type "soft") -}}
{{- $podAntiAffinity = (mustMergeOverwrite (dict ) (dict "preferredDuringSchedulingIgnoredDuringExecution" (list (mustMergeOverwrite (dict "weight" 0 "podAffinityTerm" (dict "topologyKey" "" ) ) (dict "weight" $values.deployment.podAntiAffinity.weight "podAffinityTerm" (mustMergeOverwrite (dict "topologyKey" "" ) (dict "topologyKey" $values.deployment.podAntiAffinity.topologyKey "namespaces" (list $dot.Release.Namespace) "labelSelector" (mustMergeOverwrite (dict ) (dict "matchLabels" (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r") )) )) ))) )) -}}
{{- else -}}{{- if (eq $values.deployment.podAntiAffinity.type "custom") -}}
{{- $podAntiAffinity = $values.deployment.podAntiAffinity.custom -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "selector" (coalesce nil) "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) "strategy" (dict ) ) "status" (dict ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "apps/v1" "kind" "Deployment" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "connectors.Fullname" (dict "a" (list $dot) ))) "r") "labels" (merge (dict ) (get (fromJson (include "connectors.FullLabels" (dict "a" (list $dot) ))) "r") $values.deployment.annotations) )) "spec" (mustMergeOverwrite (dict "selector" (coalesce nil) "template" (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) "strategy" (dict ) ) (dict "replicas" $values.deployment.replicas "progressDeadlineSeconds" ($values.deployment.progressDeadlineSeconds | int) "revisionHistoryLimit" $values.deployment.revisionHistoryLimit "selector" (mustMergeOverwrite (dict ) (dict "matchLabels" (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r") )) "strategy" $values.deployment.strategy "template" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) "spec" (dict "containers" (coalesce nil) ) ) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "annotations" $values.deployment.annotations "labels" (get (fromJson (include "connectors.PodLabels" (dict "a" (list $dot) ))) "r") )) "spec" (mustMergeOverwrite (dict "containers" (coalesce nil) ) (dict "automountServiceAccountToken" false "terminationGracePeriodSeconds" $values.deployment.terminationGracePeriodSeconds "affinity" (mustMergeOverwrite (dict ) (dict "nodeAffinity" $values.deployment.nodeAffinity "podAffinity" $values.deployment.podAffinity "podAntiAffinity" $podAntiAffinity )) "serviceAccountName" (get (fromJson (include "connectors.ServiceAccountName" (dict "a" (list $dot) ))) "r") "containers" (list (mustMergeOverwrite (dict "name" "" "resources" (dict ) ) (dict "name" "connectors-cluster" "image" (printf "%s:%s" $values.image.repository (get (fromJson (include "connectors.Tag" (dict "a" (list $dot) ))) "r")) "imagePullPolicy" $values.image.pullPolicy "securityContext" $values.container.securityContext "command" $values.deployment.command "env" (get (fromJson (include "connectors.env" (dict "a" (list $values) ))) "r") "envFrom" $values.deployment.extraEnvFrom "livenessProbe" (mustMergeOverwrite (dict ) (mustMergeOverwrite (dict ) (dict "httpGet" (mustMergeOverwrite (dict "port" 0 ) (dict "path" "/" "port" "rest-api" "scheme" "HTTP" )) )) (dict "initialDelaySeconds" ($values.deployment.livenessProbe.initialDelaySeconds | int) "timeoutSeconds" ($values.deployment.livenessProbe.timeoutSeconds | int) "periodSeconds" ($values.deployment.livenessProbe.periodSeconds | int) "successThreshold" ($values.deployment.livenessProbe.successThreshold | int) "failureThreshold" ($values.deployment.livenessProbe.failureThreshold | int) )) "readinessProbe" (mustMergeOverwrite (dict ) (mustMergeOverwrite (dict ) (dict "httpGet" (mustMergeOverwrite (dict "port" 0 ) (dict "path" "/connectors" "port" "rest-api" "scheme" "HTTP" )) )) (dict "initialDelaySeconds" ($values.deployment.readinessProbe.initialDelaySeconds | int) "timeoutSeconds" ($values.deployment.readinessProbe.timeoutSeconds | int) "periodSeconds" ($values.deployment.readinessProbe.periodSeconds | int) "successThreshold" ($values.deployment.readinessProbe.successThreshold | int) "failureThreshold" ($values.deployment.readinessProbe.failureThreshold | int) )) "ports" $ports "resources" (mustMergeOverwrite (dict ) (dict "requests" $values.container.resources.request "limits" $values.container.resources.limits )) "terminationMessagePath" "/dev/termination-log" "terminationMessagePolicy" "File" "volumeMounts" (get (fromJson (include "connectors.volumeMountss" (dict "a" (list $values) ))) "r") ))) "dnsPolicy" "ClusterFirst" "restartPolicy" $values.deployment.restartPolicy "schedulerName" $values.deployment.schedulerName "nodeSelector" $values.deployment.nodeSelector "imagePullSecrets" $values.imagePullSecrets "securityContext" $values.deployment.securityContext "tolerations" $values.deployment.tolerations "topologySpreadConstraints" $topologySpreadConstraints "volumes" (get (fromJson (include "connectors.volumes" (dict "a" (list $values) ))) "r") )) )) )) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.env" -}}
{{- $values := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $env := (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_CONFIGURATION" "value" (get (fromJson (include "connectors.connectorConfiguration" (dict "a" (list $values) ))) "r") )) (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_ADDITIONAL_CONFIGURATION" "value" $values.connectors.additionalConfiguration )) (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_BOOTSTRAP_SERVERS" "value" $values.connectors.bootstrapServers ))) -}}
{{- if (not (empty $values.connectors.schemaRegistryURL)) -}}
{{- $env = (concat (default (list ) $env) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "SCHEMA_REGISTRY_URL" "value" $values.connectors.schemaRegistryURL )))) -}}
{{- end -}}
{{- $env = (concat (default (list ) $env) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_GC_LOG_ENABLED" "value" $values.container.javaGCLogEnabled )) (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_HEAP_OPTS" "value" (printf "-Xms256M -Xmx%s" $values.container.resources.javaMaxHeapSize) )) (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_LOG_LEVEL" "value" $values.logging.level )))) -}}
{{- if (get (fromJson (include "connectors.Auth.SASLEnabled" (dict "a" (list $values.auth) ))) "r") -}}
{{- $env = (concat (default (list ) $env) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_SASL_USERNAME" "value" $values.auth.sasl.userName )) (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_SASL_MECHANISM" "value" $values.auth.sasl.mechanism )) (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_SASL_PASSWORD_FILE" "value" "rc-credentials/password" )))) -}}
{{- end -}}
{{- $env = (concat (default (list ) $env) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_TLS_ENABLED" "value" (printf "%v" $values.connectors.brokerTLS.enabled) )))) -}}
{{- if (not (empty $values.connectors.brokerTLS.ca.secretRef)) -}}
{{- $ca := (default "ca.crt" $values.connectors.brokerTLS.ca.secretNameOverwrite) -}}
{{- $env = (concat (default (list ) $env) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_TRUSTED_CERTS" "value" (printf "ca/%s" $ca) )))) -}}
{{- end -}}
{{- if (not (empty $values.connectors.brokerTLS.cert.secretRef)) -}}
{{- $cert := (default "tls.crt" $values.connectors.brokerTLS.cert.secretNameOverwrite) -}}
{{- $env = (concat (default (list ) $env) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_TLS_AUTH_CERT" "value" (printf "cert/%s" $cert) )))) -}}
{{- end -}}
{{- if (not (empty $values.connectors.brokerTLS.key.secretRef)) -}}
{{- $key := (default "tls.key" $values.connectors.brokerTLS.key.secretNameOverwrite) -}}
{{- $env = (concat (default (list ) $env) (list (mustMergeOverwrite (dict "name" "" ) (dict "name" "CONNECT_TLS_AUTH_KEY" "value" (printf "key/%s" $key) )))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list ) $env) (default (list ) $values.deployment.extraEnv))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.connectorConfiguration" -}}
{{- $values := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $lines := (list (printf "rest.advertised.port=%d" ($values.connectors.restPort | int)) (printf "rest.port=%d" ($values.connectors.restPort | int)) "key.converter=org.apache.kafka.connect.converters.ByteArrayConverter" "value.converter=org.apache.kafka.connect.converters.ByteArrayConverter" (printf "group.id=%s" $values.connectors.groupID) (printf "offset.storage.topic=%s" $values.connectors.storage.topic.offset) (printf "config.storage.topic=%s" $values.connectors.storage.topic.config) (printf "status.storage.topic=%s" $values.connectors.storage.topic.status) (printf "offset.storage.redpanda.remote.read=%t" $values.connectors.storage.remote.read.offset) (printf "offset.storage.redpanda.remote.write=%t" $values.connectors.storage.remote.write.offset) (printf "config.storage.redpanda.remote.read=%t" $values.connectors.storage.remote.read.config) (printf "config.storage.redpanda.remote.write=%t" $values.connectors.storage.remote.write.config) (printf "status.storage.redpanda.remote.read=%t" $values.connectors.storage.remote.read.status) (printf "status.storage.redpanda.remote.write=%t" $values.connectors.storage.remote.write.status) (printf "offset.storage.replication.factor=%d" ($values.connectors.storage.replicationFactor.offset | int)) (printf "config.storage.replication.factor=%d" ($values.connectors.storage.replicationFactor.config | int)) (printf "status.storage.replication.factor=%d" ($values.connectors.storage.replicationFactor.status | int)) (printf "producer.linger.ms=%d" ($values.connectors.producerLingerMS | int)) (printf "producer.batch.size=%d" ($values.connectors.producerBatchSize | int)) "config.providers=file,secretsManager,env" "config.providers.file.class=org.apache.kafka.common.config.provider.FileConfigProvider") -}}
{{- if $values.connectors.secretManager.enabled -}}
{{- $lines = (concat (default (list ) $lines) (list "config.providers.secretsManager.class=com.github.jcustenborder.kafka.config.aws.SecretsManagerConfigProvider" (printf "config.providers.secretsManager.param.secret.prefix=%s%s" $values.connectors.secretManager.consolePrefix $values.connectors.secretManager.connectorsPrefix) (printf "config.providers.secretsManager.param.aws.region=%s" $values.connectors.secretManager.region))) -}}
{{- end -}}
{{- $lines = (concat (default (list ) $lines) (list "config.providers.env.class=org.apache.kafka.common.config.provider.EnvVarConfigProvider")) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (join "\n" $lines)) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.volumes" -}}
{{- $values := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $volumes := (coalesce nil) -}}
{{- if (not (empty $values.connectors.brokerTLS.ca.secretRef)) -}}
{{- $volumes = (concat (default (list ) $volumes) (list (mustMergeOverwrite (dict "name" "" ) (mustMergeOverwrite (dict ) (dict "secret" (mustMergeOverwrite (dict ) (dict "defaultMode" (0o444 | int) "secretName" $values.connectors.brokerTLS.ca.secretRef )) )) (dict "name" "truststore" )))) -}}
{{- end -}}
{{- if (not (empty $values.connectors.brokerTLS.cert.secretRef)) -}}
{{- $volumes = (concat (default (list ) $volumes) (list (mustMergeOverwrite (dict "name" "" ) (mustMergeOverwrite (dict ) (dict "secret" (mustMergeOverwrite (dict ) (dict "defaultMode" (0o444 | int) "secretName" $values.connectors.brokerTLS.cert.secretRef )) )) (dict "name" "cert" )))) -}}
{{- end -}}
{{- if (not (empty $values.connectors.brokerTLS.key.secretRef)) -}}
{{- $volumes = (concat (default (list ) $volumes) (list (mustMergeOverwrite (dict "name" "" ) (mustMergeOverwrite (dict ) (dict "secret" (mustMergeOverwrite (dict ) (dict "defaultMode" (0o444 | int) "secretName" $values.connectors.brokerTLS.key.secretRef )) )) (dict "name" "key" )))) -}}
{{- end -}}
{{- if (get (fromJson (include "connectors.Auth.SASLEnabled" (dict "a" (list $values.auth) ))) "r") -}}
{{- $volumes = (concat (default (list ) $volumes) (list (mustMergeOverwrite (dict "name" "" ) (mustMergeOverwrite (dict ) (dict "secret" (mustMergeOverwrite (dict ) (dict "defaultMode" (0o444 | int) "secretName" $values.auth.sasl.secretRef )) )) (dict "name" "rc-credentials" )))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list ) $volumes) (default (list ) $values.storage.volume))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "connectors.volumeMountss" -}}
{{- $values := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $mounts := (coalesce nil) -}}
{{- if (get (fromJson (include "connectors.Auth.SASLEnabled" (dict "a" (list $values.auth) ))) "r") -}}
{{- $mounts = (concat (default (list ) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "" ) (dict "mountPath" "/opt/kafka/connect-password/rc-credentials" "name" "rc-credentials" )))) -}}
{{- end -}}
{{- if (not (empty $values.connectors.brokerTLS.ca.secretRef)) -}}
{{- $mounts = (concat (default (list ) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "" ) (dict "name" "truststore" "mountPath" "/opt/kafka/connect-certs/ca" )))) -}}
{{- end -}}
{{- if (not (empty $values.connectors.brokerTLS.cert.secretRef)) -}}
{{- $mounts = (concat (default (list ) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "" ) (dict "name" "cert" "mountPath" "/opt/kafka/connect-certs/cert" )))) -}}
{{- end -}}
{{- if (not (empty $values.connectors.brokerTLS.key.secretRef)) -}}
{{- $mounts = (concat (default (list ) $mounts) (list (mustMergeOverwrite (dict "name" "" "mountPath" "" ) (dict "name" "key" "mountPath" "/opt/kafka/connect-certs/key" )))) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (concat (default (list ) $mounts) (default (list ) $values.storage.volumeMounts))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

