{{- define "helpers.pod" -}}
{{- $ := .context }}
{{- $val := .value }}
{{- $component := .component }}
{{- range $fname, $fvalue := $val }}
{{- if has $fname (list "dnsPolicy" "hostNetwork" "hostname" "priority" "priorityClassName" "restartPolicy" "terminationGracePeriodSeconds") }}
{{ $fname }}: {{ $fvalue }}
{{- else if has $fname (list "affinity" "dnsConfig" "nodeSelector" "securityContext") }}
{{ $fname }}:
  {{- toYaml $fvalue | nindent 2 }}
{{- else if has $fname (list "tolerations" "topologySpreadConstraints" "volumes") }}
{{ $fname }}:
{{- toYaml $fvalue | nindent 0 }}
{{- end }}
{{- end }}
{{- range $_, $fname := (list "automountServiceAccountToken" "enableServiceLinks") }}
{{- if kindIs "bool" (get $val $fname) }}
{{ $fname }}: {{ get $val $fname }}
{{- else if kindIs "bool" (get $.Values.global $fname) }}
{{ $fname }}: {{ get $.Values.global $fname }}
{{- end }}
{{- end }}
{{- with (coalesce $val.serviceAccountName $.Values.global.serviceAccountName) }}
serviceAccountName: {{ . }}
{{- end }}
{{- if kindIs "slice" $val.imagePullSecrets }}
{{- with $val.imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 0 }}
{{- end }}
{{- else if kindIs "slice" $.Values.image.pullSecrets }}
{{- with $.Values.image.pullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}
containers:
{{- include "helpers.container" (dict "value" $val.containers "context" $) }}
{{- with $val.initContainers }}
initContainers:
{{- include "helpers.container" (dict "value" . "context" $) }}
{{- end }}
{{- end }}
