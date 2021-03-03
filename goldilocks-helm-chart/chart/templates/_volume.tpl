{{ define "goldilocks-volume" -}}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: #변수
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: #변수
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: ##변수

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: #변수
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: #변수
---
{{- end -}}

