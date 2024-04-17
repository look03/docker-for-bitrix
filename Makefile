#!/usr/bin/make
include .env

## Команда по умолчанию
.DEFAULT_GOAL := help

## Текущее время
CURRENT_TIME := $(shell date +%Y%m%d-%H%M)

## Обработчики Docker и Docker-Compose
DOCKER_BIN := $(shell command -v docker 2> /dev/null)
DOCKER_COMPOSE_BIN := $(shell command -v docker-compose 2> /dev/null)

# --- [ Git ] ----------------------------------------------------------------------------------------------------------
## Подтягивает актуальные данные
git-pull:
	@git pull

# --- [ Docker ] -------------------------------------------------------------------------------------------------------
## Отображает информацию о контейнерах
ps:
	@$(DOCKER_BIN) ps -a

## Инициализирует проект
init: copy-env init-folders up database-create

## Копирование env
copy-env:
	sh ./scripts/copy-env.sh

## Создание папок для сервисов, выдача прав на изменение
init-folders:
	chown -R $(USER):$(USER) ./src/ \
	&& cd ./src \
	&& mkdir api || true \
	&& chown -R $(USER):$(USER) api/


## Подтягивает актуальные образы
pull:
	@$(DOCKER_COMPOSE_BIN) pull
	@echo 'Завершение подтягивания актуальных образов'

## Поднимает сервисы
up:
	@$(DOCKER_COMPOSE_BIN) up --build -d && sudo sysctl -w vm.max_map_count=262144
	@echo 'Завершение запуска всех сервисов'

## Останавливает сервисы
down:
	@$(DOCKER_COMPOSE_BIN) down --remove-orphans
	@echo 'Завершение всех сервисов'

## Пересобирает и запускает все сервисы
deploy: down git-pull pull up

## Перезапускает все сервисы
reset: down up
	@echo 'Завершение перезапуска всех сервисов'

# --- [ Database ] -----------------------------------------------------------------------------------------------------
## Удаляет базу данных, если создана, создает и распаковывает из дампа
database-database-dump: database-show database-drop database-create database-restore-content database-show

## Показывает базы данных
database-show:
	@echo '+------------------------+'
	@echo '| Список всех баз данных |'
	@echo '+------------------------+'
	@$(DOCKER_COMPOSE_BIN) exec database \
	sh -c "export MYSQL_PWD=$(DATABASE_ROOT_PASSWORD) && \
	echo 'SHOW DATABASES;' | \
	mysql -uroot | tail -n +2"

## Создает базу данных
database-create:
	@echo 'Начало создания базы данных'
	@$(DOCKER_COMPOSE_BIN) exec database \
	sh -c "export MYSQL_PWD=$(DATABASE_PASSWORD) && \
	echo 'CREATE DATABASE $(DATABASE_NAME) CHARACTER SET $(DATABASE_CHARACTER_SET) COLLATE $(DATABASE_COLLATION);' | \
	mysql -u $(DATABASE_USER)"
	@echo 'Завершение создания базы данных'

## Удаляет базу данных
database-drop:
	@echo 'Начало удаления базы данных'
	@$(DOCKER_COMPOSE_BIN) exec database \
	sh -c "export MYSQL_PWD=$(DATABASE_PASSWORD) && \
	echo 'DROP DATABASE IF EXISTS $(DATABASE_NAME);' | \
	mysql -u$(DATABASE_USER)"
	@echo 'Завершение удаления базы данных'

## Разворачивает бэкап базы данных
database-restore:
	@echo 'Начало разворачивания базы данных из бэкапа'
	@$(DOCKER_COMPOSE_BIN) exec database \
	sh -c "export MYSQL_PWD=$(DATABASE_PASSWORD) && \
	mysql -u$(DATABASE_USER) $(DATABASE_NAME) < ./backup/$(DATABASE_RESTORE_NAME).sql"
	@echo 'Завершение разворачивания базы данных из бэкапа'

## Разворачивает бэкап базы данных
database-restore-content:
	@echo 'Начало разворачивания базы данных из бэкапа'
	@$(DOCKER_COMPOSE_BIN) exec database \
	sh -c "export MYSQL_PWD=$(DATABASE_PASSWORD) && \
	gunzip < /backup/db_example.sql.gz | mysql -u$(DATABASE_USER) $(DATABASE_NAME) "
	@echo 'Завершение разворачивания базы данных из бэкапа'


## Создает бэкап базы данных
database-backup:
	@echo 'Начало создания бэкапа базы данных'
	@$(DOCKER_COMPOSE_BIN) exec database \
	sh -c "export MYSQL_PWD=$(DATABASE_PASSWORD) && \
	mysqldump -u$(DATABASE_USER) $(DATABASE_RESTORE_NAME) > /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql"
	@echo 'Завершение создания бэкапа базы данных'


# --- [ Composer ] -----------------------------------------------------------------------------------------------------
## Устанавливает зависимости Composer
composer-install:
	@echo 'Установка Composer'
	@$(DOCKER_COMPOSE_BIN) exec backend \
	sh -c "cd /var/www/html/api/ && php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" && \
		php -r \"if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;\" && \
		php composer-setup.php && \
		php -r \"unlink('composer-setup.php');\" "
	@echo 'Завершение установки Composer'

## Устанавливает зависимости Composer
composer-update:
	@echo 'Начало установки зависимостей Composer'
	@$(DOCKER_COMPOSE_BIN) exec backend \
	sh -c "cd /var/www/html/api/ && php composer.phar install --no-interaction"
	@echo 'Завершение установки зависимостей Composer'

# --- [ Help ] ---------------------------------------------------------------------------------------------------------
## Отображает помощь
help:
	@echo '+-------------------------+'
	@echo '| Список доступных команд |'
	@echo '+-------------------------+'
	@echo 'Использование: make [КОМАНДА]'
	@awk 'BEGIN {FS = ":"} /^##.*?/ {printf "\n%s", $$1} /^[a-zA-Z_-]+:/ {printf ":%s\n", $$1} /^# ---/ {printf "\n%s\n", $$1}' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":"} /^##.*?:/ {print $$2, $$1} /\[.*?\]/ {print}' | \
	sed 's/# -* \(.*\) -*/\1/' | \
	awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+/ {printf " \033[1;1m%-38s\033[0m\t- %s\n", $$1, $$2} /\[.*?\]/ {printf "\n\033[1;1m%s\033[0m\n", $$1}'
