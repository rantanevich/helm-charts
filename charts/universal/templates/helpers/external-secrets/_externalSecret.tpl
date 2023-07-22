{{- define "helpers.external-secrets.externalSecret" }}
{{- $ := .context }}
{{- $val := .value }}
{{- $component := .component }}
refreshInterval: {{ $val.refreshInterval | default "1h" | quote }}
target:
  name: {{ $val.name | default (printf "%s-%s" (include "helpers.app.name" $) $component) }}
  creationPolicy: {{ $val.creationPolicy | default "Owner" }}
  deletionPolicy: {{ $val.deletionPolicy | default "Retain" }}
  {{- with $val.template }}
  template:
    {{- toYaml . | nindent 6 }}
  {{- end }}
  {{- if kindIs "bool" (get $val "immutable") }}
  immutable: {{ get $val "immutable" }}
  {{- end }}
{{- with $val.secretStoreRef }}
secretStoreRef:
  {{- $kind := .kind | default "SecretStore" }}
  {{- $store := get $.Values (printf "%ss" (untitle $kind)) | default dict }}
  kind: {{ $kind }}
  name: {{ ternary (printf "%s-%s" (include "helpers.app.name" $) .name) .name (hasKey $store .name) }}
{{- end }}
{{- with $val.data }}
data:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- with $val.dataFrom }}
dataFrom:
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
