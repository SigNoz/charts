{{/*
Shared networking helpers: the Ingress and Gateway API routes of a component.
Each reads only its arguments (a dict), never .Values, .Release or .Chart.
*/}}

{{/*
signoz.lib.route: a Gateway API route of a component.
Takes: kind (HTTPRoute or GRPCRoute), name, namespace, labels (the chart's labels, a map), route (the
block with annotations, labels, parentRefs, hostnames and rules), service (the Service name), port
(the Service port, may be empty).
Emits: the route, labelled with the merge of labels and route.labels. Empty rules give one rule with
one backendRef; a backendRef without a name gets service, and one without a port gets port when port
is set, else none, so the API server rejects it. A rule without backendRefs renders as written.
*/}}
{{- define "signoz.lib.route" -}}
apiVersion: gateway.networking.k8s.io/v1
kind: {{ .kind }}
metadata:
  name: {{ .name }}
  namespace: {{ .namespace }}
  labels:
    {{- include "signoz.lib.mergedMap" (dict "maps" (list .labels .route.labels)) | nindent 4 }}
  {{- with .route.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .route.parentRefs }}
  parentRefs:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .route.hostnames }}
  hostnames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  rules:
    {{- range .route.rules | default (list (dict "backendRefs" (list (dict)))) }}
    {{- $rule := deepCopy . }}
    {{- with $rule.backendRefs }}
    {{- $refs := list }}
    {{- range . }}
    {{- $ref := merge (deepCopy .) (dict "name" $.service) }}
    {{- if and (not $ref.port) $.port }}
    {{- $_ := set $ref "port" $.port }}
    {{- end }}
    {{- $refs = append $refs $ref }}
    {{- end }}
    {{- $_ := set $rule "backendRefs" $refs }}
    {{- end }}
    - {{ toYaml $rule | nindent 6 | trim }}
    {{- end }}
{{- end -}}

{{/*
signoz.lib.ingress: the Ingress of a component.
Takes: name, namespace, labels (the chart's labels, a map), ingress (the block with className,
annotations, labels, hosts and tls), service (the Service name), port (the Service port, may be
empty).
Emits: the Ingress, labelled with the merge of labels and ingress.labels. Every path goes to service,
on its own port, else port; with neither the backend has no port, so the API server rejects it. A
path without pathType gets ImplementationSpecific.
*/}}
{{- define "signoz.lib.ingress" -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .name }}
  namespace: {{ .namespace }}
  labels:
    {{- include "signoz.lib.mergedMap" (dict "maps" (list .labels .ingress.labels)) | nindent 4 }}
  {{- with .ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .ingress.className }}
  ingressClassName: {{ . }}
  {{- end }}
  {{- with .ingress.tls }}
  tls:
    {{- range . }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      {{- with .secretName }}
      secretName: {{ . }}
      {{- end }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "ImplementationSpecific" }}
            backend:
              service:
                name: {{ $.service }}
                {{- with .port | default $.port }}
                port:
                  number: {{ . }}
                {{- end }}
          {{- end }}
    {{- end }}
{{- end -}}
