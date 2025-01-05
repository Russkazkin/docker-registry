init: docker-down-clear docker-pull docker-build docker-up
up: docker-up
down: docker-down

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down --remove-orphans

docker-down-clear:
	docker-compose down -v --remove-orphans

docker-pull:
	docker-compose pull

docker-build:
	docker-compose build

deploy:
	ssh deploy@${HOST} -p ${PORT} 'rm -rf registry && mkdir registry'
	scp -P ${PORT} compose-production.yml ${HOST}:registry/compose.yml
	scp -P ${PORT} -r docker ${HOST}:registry/docker
	scp -P ${PORT} ${HTPASSWD_FILE} ${HOST}:registry/htpasswd
	ssh deploy@${HOST} -p ${PORT} 'cd registry && echo "COMPOSE_PROJECT_NAME=registry" >> .env'
	ssh deploy@${HOST} -p ${PORT} 'cd registry && docker-compose down --remove-orphans'
	ssh deploy@${HOST} -p ${PORT} 'cd registry && docker compose pull'
	ssh deploy@${HOST} -p ${PORT} 'cd registry && docker compose up -d'
