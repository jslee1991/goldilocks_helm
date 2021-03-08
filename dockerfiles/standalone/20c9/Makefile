include dockerenv.default

build: 
	docker build -t $(NS)/$(IMAGE_NAME):$(VERSION) -f Dockerfile .
exec_shell:
	docker exec -it $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) bash
run_shell:
	docker run -it --rm  --name $(CONTAINER_NAME)-$(CONTAINER_INSTANCE) $(PORTS) $(VOLUMES) $(OPTION) $(ENV) $(NS)/$(IMAGE_NAME):$(VERSION)
stop: 
	docker kill $(CONTAINER_NAME)-$(CONTAINER_INSTANCE)
clean:
	docker rmi sunjesoft/cluster:20c_1_9
remove:
	rm /home/son_kube/ymal/goldilocks/goldilocks/goldilocks_data/goldilocks-* -rf
push:
	docker push sunjesoft/$(IMAGE_NAME):$(VERSION)
version:
	@echo $(VERSION)
