* GOLDILOCKS 배포를 위한 구성요소
```
sts 
pv/pvc
service(master)
```

* 순서
```
service 배포
pv/pvc 배포
sts 배포 (클러스터 형태 및 기타 config 를 수정후 배포)
```
