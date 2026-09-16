{{- /* Generated from "notes.go" */ -}}

{{- define "console.Notes" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $commands := (list `1. Get the application URL by running these commands:`) -}}
{{- if $values.ingress.enabled -}}
{{- $scheme := "http" -}}
{{- if (gt ((get (fromJson (include "_shims.len" (dict "a" (list $values.ingress.tls) ))) "r") | int) (0 | int)) -}}
{{- $scheme = "https" -}}
{{- end -}}
{{- range $_, $host := $values.ingress.hosts -}}
{{- range $_, $path := $host.paths -}}
{{- $commands = (concat (default (list ) $commands) (list (printf "%s://%s%s" $scheme $host.host $path.path))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- else -}}{{- if (contains "NodePort" (toString $values.service.type)) -}}
{{- $commands = (concat (default (list ) $commands) (list (printf `  export NODE_PORT=$(kubectl get --namespace %s -o jsonpath="{.spec.ports[0].nodePort}" services %s)` $dot.Release.Namespace (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r")) (printf `  export NODE_IP=$(kubectl get nodes --namespace %s -o jsonpath="{.items[0].status.addresses[0].address}")` $dot.Release.Namespace) "  echo http://$NODE_IP:$NODE_PORT")) -}}
{{- else -}}{{- if (contains "NodePort" (toString $values.service.type)) -}}
{{- $commands = (concat (default (list ) $commands) (list `    NOTE: It may take a few minutes for the LoadBalancer IP to be available.` (printf `          You can watch the status of by running 'kubectl get --namespace %s svc -w %s'` $dot.Release.Namespace (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r")) (printf `  export SERVICE_IP=$(kubectl get svc --namespace %s %s --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")` $dot.Release.Namespace (get (fromJson (include "console.Fullname" (dict "a" (list $dot) ))) "r")) (printf `  echo http://$SERVICE_IP:%d` ($values.service.port | int)))) -}}
{{- else -}}{{- if (contains "ClusterIP" (toString $values.service.type)) -}}
{{- $commands = (concat (default (list ) $commands) (list (printf `  export POD_NAME=$(kubectl get pods --namespace %s -l "app.kubernetes.io/name=%s,app.kubernetes.io/instance=%s" -o jsonpath="{.items[0].metadata.name}")` $dot.Release.Namespace (get (fromJson (include "console.Name" (dict "a" (list $dot) ))) "r") $dot.Release.Name) (printf `  export CONTAINER_PORT=$(kubectl get pod --namespace %s $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")` $dot.Release.Namespace) `  echo "Visit http://127.0.0.1:8080 to use your application"` (printf `  kubectl --namespace %s port-forward $POD_NAME 8080:$CONTAINER_PORT` $dot.Release.Namespace))) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $commands) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

