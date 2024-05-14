#!/usr/bin/make

SHELL := env PATH=$(PATH) /bin/bash
CURRENT_DIR := $(shell pwd)

include .env

.DEFAULT_GOAL := help


########################################################################################################################
# SYSTEM
########################################################################################################################


.PHONY: docker-network-create
docker-network-create:
	docker network create $(COMPOSE_PROJECT_NAME)-network || true


.PHONY: docker-network-rm
docker-network-rm:
	docker network rm $(COMPOSE_PROJECT_NAME)-network || true


.PHONY: build
build:
	docker compose build


.PHONY: rebuild
rebuild:
	docker compose build --force-rm --no-cache


.PHONY: up
up:
	docker compose up -d


.PHONY: down
down:
	docker compose down --volumes --remove-orphans --rmi local


.PHONY: install
install: docker-network-create build up minio-create-buckets


.PHONY: uninstall
uninstall: stop down docker-network-rm


.PHONY: reinstall
reinstall: uninstall install


.PHONY: start
start: up


.PHONY: stop
stop:
	docker compose stop


.PHONY: restart
restart: stop start


.PHONY: logs
logs:
	docker compose logs -f --tail=150 minio1


.PHONY: status
status:
	docker compose logs
	docker compose ps


.PHONY: bash
bash: up
	docker compose exec minio1 bash


########################################################################################################################
# PROJECT
########################################################################################################################


.PHONY: minio-create-buckets
minio-create-buckets: up
	docker compose run --rm minio-create-buckets


########################################################################################################################
# DATA
########################################################################################################################


.PHONY: data-pull-from-remote
data-pull-from-remote:
	rsync -avzr -e "ssh -p $(REMOTE_PORT)" --chmod=777 --chown=1000:1000 --delete --progress $(REMOTE_DESTINATION):$(REMOTE_PATH)/docker/minio/data/ $(CURRENT_DIR)/docker/minio/data/


.PHONY: data-push-to-remote
data-push-to-remote:
	rsync -avzr -e "ssh -p $(REMOTE_PORT)" --chmod=777 --chown=1000:1000 --delete --progress $(CURRENT_DIR)/docker/minio/data/ $(REMOTE_DESTINATION):$(REMOTE_PATH)/docker/minio/data/


.PHONY: data-fix-permissions
data-fix-permissions: stop
	sudo chmod -R 777 ./ && sudo chown -R 1000:1000 ./


########################################################################################################################
# DEPLOY
########################################################################################################################


.PHONY: git-pull
git-pull:
	git pull


.PHONY: deploy
deploy: stop git-pull start


.PHONY: deploy-fast
deploy-fast: git-pull start


########################################################################################################################
# REMOTE
########################################################################################################################


.PHONY: remote-start
remote-start:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make start"


.PHONY: remote-stop
remote-stop:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make stop"


.PHONY: remote-status
remote-status:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make status"


.PHONY: remote-logs
remote-logs:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make logs"


.PHONY: remote-bash
remote-bash:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make bash"


.PHONY: remote-data-fix-permissions
remote-data-fix-permissions:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make data-fix-permissions"


.PHONY: remote-data-fix-permissions-and-start
remote-data-fix-permissions-and-start: remote-data-fix-permissions remote-start


.PHONY: remote-deploy
remote-deploy:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make deploy"


.PHONY: remote-deploy-fast
remote-deploy-fast:
	ssh -t -p $(REMOTE_PORT) $(REMOTE_DESTINATION) "cd $(REMOTE_PATH) && make deploy-fast"
