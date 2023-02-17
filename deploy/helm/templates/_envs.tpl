{{/* vim: set filetype=mustache: */}}
{{/*
Environment variables for web and worker containers
*/}}
{{- define "app.envs" }}
env:
  {{ if .Values.postgresql.enabled }}
  - name: POSTGRES_USER
    value: {{ .Values.postgresql.postgresqlUsername }}
  - name: POSTGRES_PASSWORD
    value: {{ .Values.postgresql.postgresqlPassword }}
  - name: POSTGRES_HOST
    value: {{ printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" }}
  - name: POSTGRES_DATABASE
    value: {{ .Values.postgresql.postgresqlDatabase }}
  {{ else }}
  - name: POSTGRES_USER
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: database_username
  - name: POSTGRES_PASSWORD
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: database_password
  - name: POSTGRES_HOST
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: rds_instance_address
  - name: POSTGRES_DATABASE
    valueFrom:
      secretKeyRef:
        name: rds-postgresql-instance-output
        key: database_name
  {{ end }}
  - name: SECRET_KEY_BASE
    valueFrom:
      secretKeyRef:
        name: kube-secrets
        key: secret-key-base
  - name: SENTRY_DSN
    valueFrom:
      secretKeyRef:
        name: kube-secrets
        key: sentry-dsn
  - name: RAILS_ENV
    value: production
  - name: RAILS_LOG_TO_STDOUT
    value: 'true'
  - name: USE_TEST_THRESHOLD_DATA
    value: {{ .Values.threshold.useTestData | quote }}
  - name: HOST
    value: {{ .Values.deploy.host }}
  - name: LEGAL_FRAMEWORK_API_HOST
    value: {{ .Values.legalFrameworkApi.host }}
  - name: SENTRY
    value: {{ .Values.sentry.enabled | quote }}
  - name: NOTIFICATIONS_API_KEY
    valueFrom:
      secretKeyRef:
        name: kube-secrets
        key: notifications-api-key
  - name: NOTIFICATIONS_ERROR_MESSAGE_TEMPLATE_ID
    value: {{ .Values.notifications.errorMessageTemplateId }}
  - name: NOTIFICATIONS_RECIPIENT
    value: {{ .Values.notifications.recipient }}
{{- end }}
