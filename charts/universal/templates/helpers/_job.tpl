{{- define "helpers.job" }}
{{- $ := .context }}
{{- $val := .value }}
{{- $component := .component }}
{{- range $fname, $fvalue := $val }}
{{- if has $fname (list "activeDeadlineSeconds" "backoffLimit" "completionMode" "completions" "parallelism" "ttlSecondsAfterFinished") }}
{{ $fname }}: {{ $fvalue }}
{{- end }}
{{- end }}
template:
  spec:
    {{- include "helpers.pod" (dict "component" $component "value" $val "context" $) | nindent 4 }}
{{- end }}
