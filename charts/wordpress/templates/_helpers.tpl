{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "wordpress.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wordpress.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "wordpress.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wordpress.labels" -}}
helm.sh/chart: {{ include "wordpress.chart" . }}
{{ include "wordpress.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "wordpress.installationLabels" -}}
app.kubernetes.io/installation: {{ include "wordpress.fullname" . }}
{{- end }}

{{- define "wordpress.componentLabels" -}}
app.kubernetes.io/component: {{ .Values.component | default "app" }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wordpress.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wordpress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "wordpress.envValue" -}}
{{- $envList := index . 0 -}}
{{- $key := index . 1 -}}
{{- range $env := $envList }}
  {{- if eq $env.name $key }}
    {{- if $env.value }}
      {{- $env.value }}
    {{- else if $env.valueFromSecret }}
      {{- printf "__SECRET__:%s:%s" $env.valueFromSecret.secretName $env.valueFromSecret.key }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wordpress.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wordpress.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Resolve DB backup filename prefix

Precedence:
1. dbBackup.filenamePrefixOverride
2. wordpress.fullnameOverride
3. wordpress.fullname (generated)
*/}}
{{- define "wordpress.dbBackupFilenamePrefix" -}}
{{- if .Values.dbBackup.filenamePrefixOverride -}}
{{- .Values.dbBackup.filenamePrefixOverride -}}
{{- else if .Values.wordpress.fullnameOverride -}}
{{- .Values.wordpress.fullnameOverride -}}
{{- else -}}
{{- include "wordpress.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Resolve DB backup filename prefix

Precedence:
1. dbBackup.filenamePrefixOverride
2. wordpress.fullnameOverride
3. wordpress.fullname (generated)
*/}}
{{- define "wordpress.filesBackupPrefix" -}}
{{- if .Values.fileBackup.backupNamePrefixOverride -}}
{{- .Values.fileBackup.backupNamePrefixOverride -}}
{{- else if .Values.wordpress.fullnameOverride -}}
{{- .Values.wordpress.fullnameOverride -}}
{{- else -}}
{{- include "wordpress.fullname" . -}}
{{- end -}}
{{- end -}}