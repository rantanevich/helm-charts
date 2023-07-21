{{- define "helpers.external-secrets.secretStore" }}
{{- $ := .context }}
{{- $val := .value }}
provider:
  {{- toYaml $val.provider | nindent 2 }}
{{- with $val.controller }}
controller: {{ . }}
{{- end }}
{{- with $val.refreshInterval }}
refreshInterval: {{ . }}
{{- end }}
{{- with $val.retrySettings }}
retrySettings:
  {{ toYaml . | nindent 2 }}
{{- end }}
{{- end }}
