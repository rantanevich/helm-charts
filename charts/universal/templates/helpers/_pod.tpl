{{- define "helpers.pod" -}}
{{- $ := .context }}
{{- $val := .value }}
{{- $component := .component }}
{{- range $fname, $fvalue := $val }}
{{- if has $fname (list "dnsPolicy" "hostname" "priority" "priorityClassName" "restartPolicy" "serviceAccountName" "terminationGracePeriodSeconds") }}
{{ $fname }}: {{ $fvalue }}
{{- else if has $fname (list "affinity" "dnsConfig" "nodeSelector" "securityContext") }}
{{ $fname }}:
  {{- toYaml $fvalue | nindent 2 }}
{{- else if has $fname (list "imagePullSecrets" "tolerations" "topologySpreadConstraints" "volumes") }}
{{ $fname }}:
{{- toYaml $fvalue | nindent 0 }}
{{- else if and (has $fname (list "automountServiceAccountToken" "enableServiceLinks" "hostNetwork")) (kindIs "bool" (index $val $fname)) }}
{{ $fname }}: {{ $fvalue }}
{{- end }}
{{- end }}
containers:
{{- include "helpers.container" (dict "value" $val.containers "context" $) }}
{{- with $val.initContainers }}
initContainers:
{{- include "helpers.container" (dict "value" . "context" $) }}
{{- end }}
{{- end }}
