.PHONY: all stop start build clean toolchain submodule install-submodule env-init

all: start

GIT_BRANCH = lede-17.01
GIT_REPO_URL = https://github.com/simetnicbr/openwrt-openwrt.git

check-prerequisites:
	@if [ ! -f ./env/.git_credentials.env ]; then \
		echo "Arquivo ./env/.git_credentials.env não encontrado."; \
		exit 1; \
	fi; \
	if ! command -v docker &> /dev/null; then \
		echo "Docker não está instalado. Por favor, instale o Docker."; \
		exit 1; \
	fi; \
	if ! command -v git &> /dev/null; then \
		echo "Git não está instalado. Por favor, instale o Git."; \
		exit 1; \
	fi;
	if ! command -v python3 &> /dev/null; then \
		echo "Python3 não está instalado. Por favor, instale o Python3."; \
		exit 1; \
	fi; \

env-init:
	@bash -c '\
		mkdir -p env; \
		echo "Digite o usuário do Git (GIT_USER):"; \
		read GIT_USER; \
		echo "Digite a senha do Git (GIT_PASS):"; \
		read -s GIT_PASS; echo ""; \
		echo "Digite a URL do repositório Git (ex: https://git.intelbras.com.br/user/repo.git):"; \
		read FULL_URL; \
		GIT_URL=$$(echo $$FULL_URL | sed "s~https\?://~~"); \
		URLESCAPED_PASS=$$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$$GIT_PASS"); \
		ENCODED_PASS=$$(echo "$$URLESCAPED_PASS" | base64); \
		echo "FORCE_UNSAFE_CONFIGURE=1" > env/.git_credentials.env; \
		echo "GIT_USER=$$GIT_USER" >> env/.git_credentials.env; \
		echo "GIT_PASS=$$ENCODED_PASS" >> env/.git_credentials.env; \
		echo "GIT_URL=$$GIT_URL" >> env/.git_credentials.env; \
		echo "Arquivo env/.git_credentials.env criado com sucesso!"; \
	'

submodule-install: toolchain-install openwrt-install

submodule-clean: 
	@echo "Cleaning submodules..."
	@sudo rm -rf submodules/*

openwrt-install: 
	@echo "Cloning openwrt..."
	@mkdir -p submodules
	@git clone -b $(GIT_BRANCH) $(GIT_REPO_URL) submodules/openwrt

toolchain-install:
	@echo "Cloning toolchain..."
	@mkdir -p submodules
	@if [ ! -f ./env/.git_credentials.env ]; then \
		echo "Arquivo ./env/.git_credentials.env não encontrado."; \
		exit 1; \
	fi; \
	set -a && . ./env/.git_credentials.env; \
	GIT_PASS_DECODED=$$(echo $$GIT_PASS | base64 -d); \
	echo "GIT_USER=$${GIT_USER}"; \
	echo "GIT_URL=$${GIT_URL}"; \
	git clone -b main https://$${GIT_USER}:$${GIT_PASS_DECODED}@$${GIT_URL} submodules/toolchain

build: 
	@echo "Building..."
	@docker compose -f docker/docker-compose.yaml build

start: build
	@echo "Starting..."
	@docker compose -f docker/docker-compose.yaml up openwrtcompiler

stop:
	@echo "Stopping..."
	@docker compose -f docker/docker-compose.yaml down

restart: stop start

start-server: 
	@echo "Starting server..."
	@docker compose -f docker/docker-compose.yaml up httpserver

restart-hard: stop clean submodule-install start

clean: stop submodule-clean
	docker ps -a -q | xargs -r docker stop
	docker ps -a -q | xargs -r docker rm
	docker images -q | xargs -r docker rmi -f
	docker volume ls -q | xargs -r docker volume rm
