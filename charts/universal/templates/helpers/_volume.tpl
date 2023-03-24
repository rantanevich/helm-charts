{{- define "helpers.volumes" }}
{{- $ := .context }}
{{- $val := .value }}
volumes:
{{- range $name, $_ := $val }}
- name: {{ $name }}
  {{- with .persistentVolumeClaim }}
  persistentVolumeClaim:
    claimName: {{ include "helpers.app.name" $ }}-{{ .claimName }}
  {{- else }}
  {{- toYaml . | nindent 2 }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "helpers.volumeMounts" }}
volumeMounts:
{{- range $name, $_ := . }}
- name: {{ $name }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
