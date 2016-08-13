# wordpress docker-compose makefile

# MySQL Varibles
MYSQL_ROOT_PASSWORD = wordpress
MYSQL_DATABASE = wordpress
MYSQL_USER = wordpress
MYSQL_PASSWORD = wordpress

# Container Names
WORDPRESS_CONTAINER = zi_wordpress
MYSQL_CONTAINER = zi_mysql

.PHONY: up

rm :
	docker rmi `docker images | awk "{print $3}"`

rm_exited :
	docker rm `docker ps -aqf status=exited`

pull :
	docker-compose pull

up : pull
	docker-compose up -d

up_local :
	docker-compose up -d

down :
	docker-compose down

stop :
	docker-compose stop

restart :
	docker-compose restart

reset : down
	make up

sync_wp :
	if make import_db; then make install_plugins; fi

install_wp :
	docker exec $(WORDPRESS_CONTAINER) wp \
		core install \
		--url=http://localhost:8000 \
		--title=z-wordpress-docker \
		--admin_user=z-dev \
		--admin_password=z-dev-pass \
		--admin_email=z-dev@example.com \

install_plugins :
	while read -r plugin; do \
			docker exec $(WORDPRESS_CONTAINER) wp \
			plugin install \
			$$plugin \
			--force \
			--activate ; \
	done < src/plugins.txt

dump_db:
	mkdir -p src/mysql
	docker exec -i $(MYSQL_CONTAINER) mysqldump \
		$(MYSQL_DATABASE) \
		--events \
		-uroot \
		-p$(MYSQL_ROOT_PASSWORD) > src/mysql/database.sql

import_db:
	docker exec -i $(MYSQL_CONTAINER) \
		mysql -uroot -p$(MYSQL_ROOT_PASSWORD) $(MYSQL_DATABASE) < src/mysql/database.sql

shell_wordpress :
	docker exec -ti $(WORDPRESS_CONTAINER) /bin/bash

tail_wordpress :
	docker logs -f $(WORDPRESS_CONTAINER)