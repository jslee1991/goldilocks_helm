* explain:
```
docker image 생성 후 build 후 run_shell로 들어가서 정상 수행을 확인해보기 위해 만들었다.
step1. entrypoint-init.sh
컨테이너에서 사용하기 위해 받아 오는 변수가 있는데 docker로 하다 보니 값이
넘어 오지 않아 설정한 값들이 있다. 위의 값을 수정한후 make build한다.
MY_POD_NAME=goldilocks-0
APP_NAME=GOLDILOCKS
MY_POD_IP=127.0.0.1

step2. make build

step3. make exec_shell
docker 수행 후 namespace 지정 하지 않았기 때문에 아래의 값을 수행 한다.
docker execute : export GOLDILOCKS_DATA=/home/sunje/goldilocks_data/goldilocks/goldilocks-0


1. 설명
kubenets 이용하여 수행 하기 전 Docker File Make을 이용하여 쉽게
생성 하는 Docker Container 생성 파일이다.
[version]
20.1.3

[all_explain]
goldilocks global location 처리 시 glocaotr를 사용하여 수행되는 Image create

[db_explain]
- db 2by1로 구성 (20.1.2와 차이점)
- goldilocks_home/entrypoint-init.sh usage

2. 진행사항
2-1)root로 진행
2-2)docker image create
step1) Dockerfile 이용 image create
       exeucte) make build 
step2) Dockerfile execute에서하는일
       - goldilocks_home, goldilocks_data COPY 이용하여 Container 디렉토리
         생성 및 sunje user 생성.
       - entrypoint.sh execute

2-3) dockerenv.default
다르게 수정 할 것은 없다. 하는일은 아래와 같다.
step1) volumn,port,kernal 값을 설정한다.
       여기에서 goldilocks_data, goldilocks_home volumn공유하여 사용하게 된다.

2-4) goldilocks/goldilocks/goldilocks_home
step1) shard goldilocks_home/에 있는 entrypoint-init.sh 위의 파일을 이용하여
       DB 생성한다.

2-5) goldilocks/goldilocks/goldilocks_data/goldilocks-0
step1) entrypoint-init.sh shell에서 goldilocks-0 위의 파일이 없으면 만들어서
       해당 파일에 실제 goldilocks_data생성 하여 member별로 사용 하게 된다.

2-6) entrypoint-init.sh
컨테이너에서 사용하기 위해 받아 오는 변수가 있는데 docker로 하다 보니 값이
넘어 오지 않아 설정한 값들이 있다.
MY_POD_NAME=goldilocks-0
APP_NAME=GOLDILOCKS
MY_POD_IP=127.0.0.1

2-7) make run_shell
docker container start 처리 한다.

2-8) make exec_shell
docker container attach 한다.
.bash_profile 수정 -> MY_POD_NAME이 없어서 수정해서 사용한다.

2-9) 이외에 사용명령어
make stop   : container stop 처리 한다.
make clean  : image 삭제 한다.
make remove : container 생성 시 goldilocks-0이라는 pods에 생성을 하기 때문에
              수행 시 해당 Datafile을 삭제해주고 수행 한다.

3. docker image hub 내용
docker image에서 생성 하는것.
step1) cent o/s 7.0
step2) sunje 계정
step3) goldilocks_home, goldilocks_data

kubenetes에서 사용 시 image에서 받아와 사용하는 것은 위의 정도이고 실제
나먼지는 shell(entrypoint-init.sh) 생성 시 volumn을 공유하면 서 container
를 생성 하게 된다.

4. 작업절차.
step1) 파일 Root로 Copy
step2) 권란 777 확인
step3) make build
step4) make run_shell
step5) make exec_shell

```
