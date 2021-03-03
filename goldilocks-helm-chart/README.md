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
