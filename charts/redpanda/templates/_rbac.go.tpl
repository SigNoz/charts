{{- /* Generated from "rbac.go" */ -}}

{{- define "redpanda.Roles" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $mapping := (dict "files/sidecar.Role.yaml" (and $values.rbac.enabled $values.statefulset.sideCars.controllers.createRBAC) "files/pvcunbinder.Role.yaml" (and $values.rbac.enabled $values.statefulset.sideCars.controllers.createRBAC) "files/decommission.Role.yaml" (and $values.rbac.enabled $values.statefulset.sideCars.controllers.createRBAC) "files/rpk-debug-bundle.Role.yaml" (and $values.rbac.enabled $values.rbac.rpkDebugBundle)) -}}
{{- $roles := (coalesce nil) -}}
{{- range $file, $enabled := $mapping -}}
{{- if (not $enabled) -}}
{{- continue -}}
{{- end -}}
{{- $role := (get (fromJson (include "_shims.fromYaml" (dict "a" (list ($dot.Files.Get $file))))) "r") -}}
{{- $_ := (set $role.metadata "name" (printf "%s-%s" (get (fromJson (include "redpanda.Name" (dict "a" (list $dot)))) "r") $role.metadata.name)) -}}
{{- $_ := (set $role.metadata "namespace" $dot.Release.Namespace) -}}
{{- $_ := (set $role.metadata "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r")) -}}
{{- $_ := (set $role.metadata "annotations" (merge (dict) (dict) $values.serviceAccount.annotations $values.rbac.annotations)) -}}
{{- $roles = (concat (default (list) $roles) (list $role)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $roles) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ClusterRoles" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $mapping := (dict "files/pvcunbinder.ClusterRole.yaml" (and $values.rbac.enabled $values.statefulset.sideCars.controllers.createRBAC) "files/decommission.ClusterRole.yaml" (and $values.rbac.enabled $values.statefulset.sideCars.controllers.createRBAC) "files/rack-awareness.ClusterRole.yaml" (and $values.rbac.enabled $values.rackAwareness.enabled)) -}}
{{- $clusterRoles := (coalesce nil) -}}
{{- range $file, $enabled := $mapping -}}
{{- if (not $enabled) -}}
{{- continue -}}
{{- end -}}
{{- $role := (get (fromJson (include "_shims.fromYaml" (dict "a" (list ($dot.Files.Get $file))))) "r") -}}
{{- $_ := (set $role.metadata "name" (printf "%s-%s" (get (fromJson (include "redpanda.Fullname" (dict "a" (list $dot)))) "r") $role.metadata.name)) -}}
{{- $_ := (set $role.metadata "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r")) -}}
{{- $_ := (set $role.metadata "annotations" (merge (dict) (dict) $values.serviceAccount.annotations $values.rbac.annotations)) -}}
{{- $clusterRoles = (concat (default (list) $clusterRoles) (list $role)) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $clusterRoles) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.RoleBindings" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $roleBindings := (coalesce nil) -}}
{{- range $_, $role := (get (fromJson (include "redpanda.Roles" (dict "a" (list $dot)))) "r") -}}
{{- $roleBindings = (concat (default (list) $roleBindings) (list (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "roleRef" (dict "apiGroup" "" "kind" "" "name" "")) (mustMergeOverwrite (dict) (dict "apiVersion" "rbac.authorization.k8s.io/v1" "kind" "RoleBinding")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" $role.metadata.name "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace "annotations" (merge (dict) (dict) $values.serviceAccount.annotations $values.rbac.annotations))) "roleRef" (mustMergeOverwrite (dict "apiGroup" "" "kind" "" "name" "") (dict "apiGroup" "rbac.authorization.k8s.io" "kind" "Role" "name" $role.metadata.name)) "subjects" (list (mustMergeOverwrite (dict "kind" "" "name" "") (dict "kind" "ServiceAccount" "name" (get (fromJson (include "redpanda.ServiceAccountName" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace))))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $roleBindings) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

{{- define "redpanda.ClusterRoleBindings" -}}
{{- $dot := (index .a 0) -}}
{{- range $_ := (list 1) -}}
{{- $_is_returning := false -}}
{{- $values := $dot.Values.AsMap -}}
{{- $crbs := (coalesce nil) -}}
{{- range $_, $clusterRole := (get (fromJson (include "redpanda.ClusterRoles" (dict "a" (list $dot)))) "r") -}}
{{- $crbs = (concat (default (list) $crbs) (list (mustMergeOverwrite (dict "metadata" (dict "creationTimestamp" (coalesce nil)) "roleRef" (dict "apiGroup" "" "kind" "" "name" "")) (mustMergeOverwrite (dict) (dict "apiVersion" "rbac.authorization.k8s.io/v1" "kind" "ClusterRoleBinding")) (dict "metadata" (mustMergeOverwrite (dict "creationTimestamp" (coalesce nil)) (dict "name" $clusterRole.metadata.name "labels" (get (fromJson (include "redpanda.FullLabels" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace "annotations" (merge (dict) (dict) $values.serviceAccount.annotations $values.rbac.annotations))) "roleRef" (mustMergeOverwrite (dict "apiGroup" "" "kind" "" "name" "") (dict "apiGroup" "rbac.authorization.k8s.io" "kind" "ClusterRole" "name" $clusterRole.metadata.name)) "subjects" (list (mustMergeOverwrite (dict "kind" "" "name" "") (dict "kind" "ServiceAccount" "name" (get (fromJson (include "redpanda.ServiceAccountName" (dict "a" (list $dot)))) "r") "namespace" $dot.Release.Namespace))))))) -}}
{{- end -}}
{{- if $_is_returning -}}
{{- break -}}
{{- end -}}
{{- $_is_returning = true -}}
{{- (dict "r" $crbs) | toJson -}}
{{- break -}}
{{- end -}}
{{- end -}}

