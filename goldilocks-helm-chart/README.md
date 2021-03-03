# Goldilocks docker build 

# Goldilocks Helm chart deploy 

* 라이선스 파일을 kube config map 으로 생성 

```sh 
cd example 

sh 01.create-configmap.sh
```

* helm chart 배포 
```sh 
cd chart 

helm install goldilocks --namespace goldilocks . 


kubectl exec -it goldilocks0-0 bash 

gsql sys gliese --as sysdba
gsql) select * from x$instance;
----

```

* values
```
pv/pvc 사용유무
nfs 사용유무
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
