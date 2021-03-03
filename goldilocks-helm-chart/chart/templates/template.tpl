{{ define "vttablet-service" -}}
# set tuple values to more recognizable variables
{{- $pmm := index . 0 }}
apiVersion: v1
kind: Service
metadata:
  name: vttablet
  labels:
    app: vitess
  annotations:
    service.alpha.kubernetes.io/tolerate-unready-endpoints: "true"
spec:
  publishNotReadyAddresses: true
  ports:
    - port: 15002
      name: web
    - port: 16002
      name: grpc
{{ if $pmm.enabled }}
    - port: 42001
      name: query-data
    - port: 42002
      name: mysql-metrics
{{ end }}
  clusterIP: None
  selector:
    app: vitess
    component: vttablet
---
{{- end -}}
