# OPENSTACK 혹은 기타 CLOUD 환경에서 배포(설치) 자동화

* 포함내역
```
- DB 생성
- CLUSTER GROUP 생성 및 MEMBER 추가
- DATA REBALANCE
- LOCATOR 정보 추가
```

* 유의사항
```
- INSTANCE의 HOSTNAME은 G#N#을 규칙으로 한다.
- 그룹은 총 9개까지 멤버도 총 9개까지로 한다. (필요시 수정하도록 한다. 두자릿수(99)까지 하게 될경우 G01N01 ~ G99N99로 설정가능케 스크립트 수정))
- GLOCATOR는 G1N1 에서 뜬다.
- CLUSTER 생성 및 MEMBER 추가 등은 모두 G1N1에서 수행하므로 G1N1이 없는경우는 수행이 안된다.
```

* 필요사항
```
- 기타 다른 멤버가 G1N1의 IP를 자동으로 습득하는방법? (IP가 불특정하게 생성되므로 미리 DNS에 등록한다던지 등의 아이디어는 X)
- 아니면 G1N1의 IP는 ENV로 받을까? -> 아쉽지만 쉬운방법
- G1N1의 HOSTNAME을 가진 인스턴스에게 L4단에서 VIP를 준다면? -> 가능하겠다. 클라우드에서 FLOATING IP를 고정으로 주는것도 한가지 방법일듯
``` 
