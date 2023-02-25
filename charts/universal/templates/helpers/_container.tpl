{{- define "helpers.container" }}
{{- $ := .context }}
{{- $val := .value }}
{{- range $name, $_ := $val }}
- name: {{ $name }}
  image: {{ .image | default (printf "%s:%s" $.Values.image.repository $.Values.image.tag) }}
  imagePullPolicy: {{ .imagePullPolicy | default $.Values.image.pullPolicy }}
  {{- range $fname, $fvalue := . }}
  {{- if has $fname (list "lifecycle" "livenessProbe" "readinessProbe" "resources" "securityContext" "startupProbe") }}
  {{ $fname }}:
    {{- toYaml $fvalue | nindent 4 }}
  {{- else if has $fname (list "args" "command" "env" "ports" "volumeMounts") }}
  {{ $fname }}:
  {{- toYaml $fvalue | nindent 2 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
