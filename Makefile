prod: 
	cp ./env/.env.prod .env && \
		source .env && \
		docker-compose -f compose.yml -f compose.prod.yml up
local:
	cp ./env/.env.local .env && \
		source .env && \
		docker-compose -f compose.yml up 
dev:
	${MAKE} local
pull:
	docker-compose -f compose.yml -f compose.prod.yml pull
sync:
	${MAKE} pull
down:
	docker-compose -f compose.yml -f compose.prod.yml down
clean:
	docker-compose -f compose.yml -f compose.prod.yml down -v --remove-orphans
