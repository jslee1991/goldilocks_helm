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

sh get-cluster-member.sh 

gSQL> 
GROUP_ID GROUP_NAME MEMBER_ID MEMBER_NAME MEMBER_HOST   MEMBER_PORT
-------- ---------- --------- ----------- ------------- -----------
       1 G1                 1 G1M1        10.233.41.232       10101
       1 G1                 3 G1M2        10.233.88.156       10101
       1 G1                 4 G1M3        10.233.88.112       10101
       2 G2                 2 G2M1        10.233.88.149       10101

```
