{{- define "helpers.container" }}
{{- $ := .context }}
{{- $val := .value }}
{{- $releaseSecretNames := concat list (keys $.Values.secrets) (keys $.Values.externalSecrets) | uniq }}
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
  {{- if or .env .envFromSecret .envFromConfigMap }}
  env:
  {{- range $envName, $envValue := .env }}
  - name: {{ $envName }}
    value: {{ $envValue | quote }}
  {{- end }}
  {{- range $secretName, $items := .envFromSecret }}
  {{- $secretName := ternary (printf "%s-%s" (include "helpers.app.name" $) $secretName) $secretName (has $secretName $releaseSecretNames) }}
  {{- range $envName, $secretKey := $items }}
  - name: {{ $envName }}
    valueFrom:
      secretKeyRef:
        name: {{ $secretName }}
        key: {{ $secretKey }}
  {{- end }}
  {{- end }}
  {{- range $configName, $items := .envFromConfigMap }}
  {{- $configName := ternary (printf "%s-%s" (include "helpers.app.name" $) $configName) $configName (hasKey $.Values.configMaps $configName) }}
  {{- range $envName, $configKey := $items }}
  - name: {{ $envName }}
    valueFrom:
      configMapKeyRef:
        name: {{ $configName }}
        key: {{ $configKey }}
  {{- end }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
