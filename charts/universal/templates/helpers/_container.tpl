{{- define "helpers.container" }}
{{- $ := .context }}
{{- $val := .value }}
{{- range $name, $_ := $val }}
- name: {{ $name }}
  image: {{ .image | default (printf "%s:%s" $.Values.image.repository $.Values.image.tag) }}
  imagePullPolicy: {{ .imagePullPolicy | default $.Values.image.pullPolicy }}
  {{- with .volumeMounts }}
  volumeMounts:
  {{- range $volumeName, $_ := . }}
  - name: {{ $volumeName }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- range $fname, $fvalue := . }}
  {{- if has $fname (list "lifecycle" "livenessProbe" "readinessProbe" "resources" "securityContext" "startupProbe") }}
  {{ $fname }}:
    {{- toYaml $fvalue | nindent 4 }}
  {{- else if has $fname (list "args" "command" "ports") }}
  {{ $fname }}:
  {{- toYaml $fvalue | nindent 2 }}
  {{- end }}
  {{- end }}
  {{- if or .env .envFromSecret }}
  env:
  {{- range $envName, $envValue := .env }}
  - name: {{ $envName }}
    value: {{ $envValue | quote }}
  {{- end }}
  {{- range $secretName, $items := .envFromSecret }}
  {{- $secretName := ternary (printf "%s-%s" (include "helpers.app.name" $) $secretName) $secretName (hasKey $.Values.secrets $secretName) }}
  {{- range $envName, $secretKey := $items }}
  - name: {{ $envName }}
    valueFrom:
      secretKeyRef:
        name: {{ $secretName }}
        key: {{ $secretKey }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
