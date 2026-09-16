{{- /* Generated from "secret.go" */ -}}

{{- define "console.Secret" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- if (not $values.secret.create) -}}
{{- $_is_returning = true -}}
{{- (dict "r" (coalesce nil)) | toJson -}}
{{- break -}}
{{- end -}}
{{- $jwtSecret := $values.secret.login.jwtSecret -}}
{{- if (eq $jwtSecret "") -}}
{{- $jwtSecret = (randAlphaNum (32 | int)) -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil) ) ) (mustMergeOverwrite (dict ) (dict "apiVersion" "v1" "kind" "Secret" )) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil) ) (dict "name" (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r") "labels" (get (fromJson (include "console.Labels" (dict "a" (list $dot) ))) "r") )) "type" "Opaque" "stringData" (dict "kafka-sasl-password" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.saslPassword "") ))) "r") "kafka-protobuf-git-basicauth-password" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.protobufGitBasicAuthPassword "") ))) "r") "kafka-sasl-aws-msk-iam-secret-key" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.awsMskIamSecretKey "") ))) "r") "kafka-tls-ca" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.tlsCa "") ))) "r") "kafka-tls-cert" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.tlsCert "") ))) "r") "kafka-tls-key" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.tlsKey "") ))) "r") "kafka-schema-registry-password" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.schemaRegistryPassword "") ))) "r") "kafka-schemaregistry-tls-ca" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.schemaRegistryTlsCa "") ))) "r") "kafka-schemaregistry-tls-cert" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.schemaRegistryTlsCert "") ))) "r") "kafka-schemaregistry-tls-key" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.kafka.schemaRegistryTlsKey "") ))) "r") "login-jwt-secret" $jwtSecret "login-google-oauth-client-secret" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.login.google.clientSecret "") ))) "r") "login-google-groups-service-account.json" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.login.google.groupsServiceAccount "") ))) "r") "login-github-oauth-client-secret" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.login.github.clientSecret "") ))) "r") "login-github-personal-access-token" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.login.github.personalAccessToken "") ))) "r") "login-okta-client-secret" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.login.okta.clientSecret "") ))) "r") "login-okta-directory-api-token" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.login.okta.directoryApiToken "") ))) "r") "login-oidc-client-secret" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.login.oidc.clientSecret "") ))) "r") "enterprise-license" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.enterprise.license "") ))) "r") "redpanda-admin-api-password" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.redpanda.adminApi.password "") ))) "r") "redpanda-admin-api-tls-ca" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.redpanda.adminApi.tlsCa "") ))) "r") "redpanda-admin-api-tls-cert" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.redpanda.adminApi.tlsCert "") ))) "r") "redpanda-admin-api-tls-key" (get (fromJson (include "_shims.ptr_Deref" (dict "a" (list $values.secret.redpanda.adminApi.tlsKey "") ))) "r") ) ))) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

