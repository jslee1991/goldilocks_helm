* TEMPLATES 구성요소 *
```
- VOLUME 
  - PV/PVC

- SERVICE
  - CLUSTER_IP (모든 MEMBER)
    - CLUSTER_IP로 설정
    - 실질적으로 사용은 X 
  - MASTER_IP
    - CLUSTER JOIN & 관계 형성 시에 사용 (必)
    
- STS
  - 골드락스 CLUSTER를 배포하기 위한 가장 기본적인 파일
  
구성요소 중 1나라도 정상적으로 생성이 안된다면 골디락스 기동이 안됨.

```
