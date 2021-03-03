* GOLDILOCKS 배포를 위한 구성요소
```
1. sts 
2. pv/pvc
3. service(master)
```

* 순서
```
1. service 배포
2. pv/pvc 배포
3. sts 배포 (클러스터 형태 및 기타 config 를 수정후 배포)
```

* 주의
```
cluster 배포 시 순서 & 관계 및 상태 check를 위해서 deployment로 배포하지 않고 statefulset으로 배포한다.
```
