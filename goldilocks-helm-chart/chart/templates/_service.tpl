{{ define "goldilocks-master-service" -}}
---
# group master service 
apiVersion: v1
kind: Service
metadata:
  name: {{ template "goldilocks.fullname" . }}-master
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ template "goldilocks.fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  annotations:
{{- if .Values.service.annotations }}
{{ toYaml .Values.service.annotations | indent 4 }}
{{- end }}
spec:
  type: {{ .Values.service.type }}
  {{- if (and (eq .Values.service.type "LoadBalancer") (not (empty .Values.service.loadBalancerIP))) }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP }}
  {{- end }}
  ports:
  - name: goldilocks
    port: 10101
    targetPort: goldilocks
    {{- if .Values.service.nodePort }}
    nodePort: {{ .Values.service.nodePort }}
    {{- end }}
  - name: goldilocks-master
    port: 22581
    targetPort: 22581
  - name: goldilocks-glocator
    port: 42581
    targetPort: 42581
    protocol: UDP

  selector:
    app: {{ template "goldilocks.fullname" . }}
    statefulset.kubernetes.io/pod-name: {{ .Values.groupMaster }}
{{- end -}}
---
{{ define "goldilocks-cluster-service" -}}
---
# application service 
apiVersion: v1
kind: Service
metadata:
  name: {{ template "goldilocks.fullname" . }}
  namespace: {{ .Release.Namespace }}
  labels:
    app: {{ template "goldilocks.fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
  annotations:
{{- if .Values.service.annotations }}
{{ toYaml .Values.service.annotations | indent 4 }}
{{- end }}
spec:
  type: {{ .Values.service.type }}
  {{- if (and (eq .Values.service.type "LoadBalancer") (not (empty .Values.service.loadBalancerIP))) }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP }}
  {{- end }}
  ports:
  - name: goldilocks
    port: {{ .Values.service.port }}
    targetPort: goldilocks
    {{- if .Values.service.nodePort }}
    nodePort: {{ .Values.service.nodePort }}
    {{- end }}
  selector:
    app: {{ template "goldilocks.fullname" . }}
---
{{- end -}}
