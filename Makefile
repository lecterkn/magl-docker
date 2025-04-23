prod: 
	cp ./env/.env.prod .env && \
		source .env && \
		docker-compose -f compose.yml -f compose.prod.yml up
local:
	cp ./env/.env.local .env && \
		source .env && \
		docker-compose -f compose.yml up 
down:
	docker-compose -f compose.yml -f compose.prod.yml down
clean:
	docker-compose -f compose.yml -f compose.prod.yml down -v --remove-orphans
