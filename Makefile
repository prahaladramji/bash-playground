.PHONY : start stop clean exec
PWD = $(shell pwd)
PORTS ?= "-p 80:80 -p 3000:3000 -p 9090:9090"

start:
	@docker run -d --privileged --rm -it --name centos $(PORTS) \
			-e container=docker --cap-add SYS_ADMIN --security-opt seccomp:unconfined \
			-v /sys/fs/cgroup:/sys/fs/cgroup:ro -v $(PWD)/scripts:/mnt/scripts centos \
			/sbin/init

stop:
	@docker stop centos

exec:
	@echo "Entering centos docker shell :: scripts mounted to /mnt/scripts"
	@docker exec -it centos /bin/bash

clean:
	@echo "Cleaning up zombie dockers"
	@if [[ $$(docker ps -qa) ]]; then docker rm $$(docker ps -qa); else echo "no zombies"; fi
