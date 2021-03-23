# Goldilocks docker build 

# Goldilocks Helm chart deploy 

* 라이선스 파일을 kube config map 으로 생성  (현재는 무기한 free license로 구성되어 있으며, 추후 라이선스 정책에 따라 config기능에 대한 사용유무를 정의 할 예정입니다.)

```sh 
cd example 

sh 01.create-configmap.sh
```

* helm chart 배포 
```sh 
cd chart 

helm install goldilocks --namespace <namespace> <PATH>


kubectl exec -it goldilocks-0 bash 

gsql sys gliese --as sysdba
(if replica = 2)
gSQL> select * from x$instance;

VERSION                            STARTUP_TIME               STATUS OS_USER_ID IS_CLUSTER LOCAL_GROUP_ID LOCAL_MEMBER_ID LOCAL_MEMBER_NAME LOCAL_MEMBER_POSITION
---------------------------------- -------------------------- ------ ---------- ---------- -------------- --------------- ----------------- ---------------------
Release 20c 20.1.9 revision(32316) 2021-03-03 08:37:04.940014 OPEN         1000 TRUE                    1               1 GOLDILOCKS-0                          0
Release 20c 20.1.9 revision(32316) 2021-03-03 08:37:51.096965 OPEN         1000 TRUE                    1               2 GOLDILOCKS-1                          1

2 rows selected.

Elapsed time: 7.13500 ms 

----

```

* values
```
pv/pvc 사용유무
service 사용유무 등 k8s 모듈 사용 여부에 대한 check

goldilocks config에 대한 내용 (init sql 등..)

```

* templates 구성
```
statefulset 
pv
pvc
service - cluster_ip ( master -> for cluster join , regular -> for access randoming instance )
service - node_port ( listening port )

```
