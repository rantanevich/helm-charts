{{- define "helpers.pod" -}}
{{- $ := .context }}
{{- $val := .value }}
{{- $component := .component }}
{{- $clusterExternalSecretNames := list }}
{{- range $name, $_ := $.Values.clusterExternalSecrets }}
{{- if not .externalSecretName }}
{{- $clusterExternalSecretNames = append $clusterExternalSecretNames $name }}
{{- end }}
{{- end }}
{{- $releaseSecretNames := concat list (keys $.Values.secrets) (keys $.Values.externalSecrets) $clusterExternalSecretNames | uniq }}
{{- range $fname, $fvalue := $val }}
{{- if has $fname (list "dnsPolicy" "hostNetwork" "hostname" "priority" "priorityClassName" "restartPolicy" "terminationGracePeriodSeconds") }}
{{ $fname }}: {{ $fvalue }}
{{- else if has $fname (list "affinity" "dnsConfig" "nodeSelector" "securityContext") }}
{{ $fname }}:
  {{- toYaml $fvalue | nindent 2 }}
{{- else if has $fname (list "tolerations" "topologySpreadConstraints") }}
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
serviceAccountName: {{ include "helpers.app.name" $ }}-{{ . }}
{{- end }}
{{- with $val.volumes }}
volumes:
{{- range $volumeName, $_ := . }}
{{- if and .secret (hasKey $.Values.secrets .secret.secretName) }}{{- $_ := set .secret "secretName" (printf "%s-%s" (include "helpers.app.name" $) .secret.secretName) }}{{- end }}
{{- if and .configMap (hasKey $.Values.configMaps .configMap.name) }}{{- $_ := set .configMap "name" (printf "%s-%s" (include "helpers.app.name" $) .configMap.name) }}{{- end }}
{{- if and .persistentVolumeClaim (hasKey $.Values.pvcs .persistentVolumeClaim.claimName) }}{{- $_ := set .persistentVolumeClaim "claimName" (printf "%s-%s" (include "helpers.app.name" $) .persistentVolumeClaim.claimName) }}{{- end }}
- name: {{ $volumeName }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- if kindIs "slice" $val.imagePullSecrets }}
{{- with $val.imagePullSecrets }}
imagePullSecrets:
{{ range $secret := . }}
- name: {{ ternary (printf "%s-%s" (include "helpers.app.name" $) $secret.name) $secret.name (has $secret.name $releaseSecretNames) }}
{{- end }}
{{- end }}
{{- else if kindIs "slice" $.Values.image.pullSecrets }}
{{- with $.Values.image.pullSecrets }}
imagePullSecrets:
{{ range $secret := . }}
- name: {{ ternary (printf "%s-%s" (include "helpers.app.name" $) $secret.name) $secret.name (has $secret.name $releaseSecretNames) }}
{{- end }}
{{- end }}
{{- end }}
containers:
{{- include "helpers.container" (dict "value" $val.containers "context" $) }}
{{- with $val.initContainers }}
initContainers:
{{- include "helpers.container" (dict "value" . "context" $) }}
{{- end }}
{{- end }}
