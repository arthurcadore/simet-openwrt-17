.PHONY: all stop start build clean toolchain submodule install-submodule

all: start

build: toolchain
	@echo "Building..."
	@docker compose build

start:
	@echo "Starting..."
	@docker compose up 

stop:
	@echo "Stopping..."
	@docker compose down

clean: stop
	docker ps -a -q | xargs -r docker stop
	docker ps -a -q | xargs -r docker rm
	docker images -q | xargs -r docker rmi -f
	docker volume ls -q | xargs -r docker volume rm

toolchain-install:
	@if [ ! -f ./env/.git_credentials.env ]; then \
		echo "Arquivo ./env/.git_credentials.env não encontrado."; \
		exit 1; \
	fi; \
	set -a && . ./env/.git_credentials.env; \
	echo "GIT_USER=$${GIT_USER}"; \
	echo "GIT_URL=$${GIT_URL}"; \
	git submodule add -b main https://$${GIT_USER}:$${GIT_PASS}@$${GIT_URL} submodules/toolchain

submodule-update: 
	@echo "Updating submodules..."
	@git submodule update --remote --merge

submodule-install: 
	@echo "Installing submodules..."
	@mkdir -p submodules
	@git submodule add -b lede-17.01 https://github.com/simetnicbr/openwrt-openwrt.git submodules/openwrt
