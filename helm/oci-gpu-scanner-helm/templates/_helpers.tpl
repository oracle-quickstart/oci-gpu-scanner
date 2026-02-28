{{/*
Expand the name of the chart.
*/}}
{{- define "corrino-lens.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "corrino-lens.fullname" -}}
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
{{- define "corrino-lens.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "corrino-lens.labels" -}}
helm.sh/chart: {{ include "corrino-lens.chart" . }}
{{ include "corrino-lens.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "corrino-lens.selectorLabels" -}}
app.kubernetes.io/name: {{ include "corrino-lens.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "corrino-lens.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "corrino-lens.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name for the frontend.
*/}}
{{- define "corrino-lens.frontend.fullname" -}}
{{- printf "%s-%s" (include "corrino-lens.fullname" .) .Values.frontend.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name for the backend.
*/}}
{{- define "corrino-lens.backend.fullname" -}}
{{- printf "%s-%s" (include "corrino-lens.fullname" .) .Values.backend.name | trunc 63 | trimSuffix "-" }}
{{- end }} 

{{/*
Helper for Backend Service Host
*/}}
{{- define "corrino-lens.backendHost" -}}
{{ include "corrino-lens.fullname" . }}-backend
{{- end }}

{{/*
Create a default fully qualified app name for the database.
*/}}
{{- define "corrino-lens.postgresHost" -}}
{{ include "corrino-lens.fullname" . }}-postgres-lb
{{- end }} 

{{/*
Helper for generating hostnames for services using external IP
*/}}
{{- define "corrino-lens.hostname" -}}
{{- printf "%s.%s" .Values.ingress.domain .Release.Name }}
{{- end }}

{{/*
Helper for backend hostname
*/}}
{{- define "corrino-lens.backend.hostname" -}}
{{- printf "api-%s" (include "corrino-lens.hostname" .) }}
{{- end }}

{{/*
Helper for frontend hostname
*/}}
{{- define "corrino-lens.frontend.hostname" -}}
{{- printf "lens-%s" (include "corrino-lens.hostname" .) }}
{{- end }}

{{/*
Helper for grafana hostname
*/}}
{{- define "corrino-lens.grafana.hostname" -}}
{{- printf "grafana-%s" (include "corrino-lens.hostname" .) }}
{{- end }}

{{/*
Helper for prometheus hostname
*/}}
{{- define "corrino-lens.prometheus.hostname" -}}
{{- printf "prometheus-%s" (include "corrino-lens.hostname" .) }}
{{- end }}

{{/*
Helper for pushgateway hostname
*/}}
{{- define "corrino-lens.pushgateway.hostname" -}}
{{- printf "pushgateway-%s" (include "corrino-lens.hostname" .) }}
{{- end }}