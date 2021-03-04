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

### 
```
위 변수 정의에 대해서는 values를 통해 정의를 해 주어야 함.
변수로 정의 된 pv-pvc name / storage size / path는 cluster별로 구분되어야 함.

```
