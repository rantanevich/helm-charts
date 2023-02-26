{{- define "helpers.render" }}
{{- $tmpl := toYaml .value }}
{{- if contains "{{" $tmpl }}
{{- tpl $tmpl .context }}
{{- else }}
{{- $tmpl }}
{{- end }}
{{- end }}
