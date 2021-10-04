build:
	@script/build

destroy:
	@script/destroy

enable-tls:
	@script/enable-tls

run:
	@echo "\033[0;34m[#] Killing old docker processes\033[0m"
	docker-compose rm -fs

	@echo "\033[0;34m[#] Building docker containers\033[0m"
	docker-compose up --build -d

	@echo "\e[32m[#] Containers are now running!\e[0m"
