build:
	@script/build

destroy:
	@script/destroy

enable-tls:
	@script/enable-tls

nginx-example:
	@echo "\033[0;34m[#] Killing old docker processes\033[0m"
	cd src/nginx_example && docker-compose rm -fs

	@echo "\033[0;34m[#] Building docker containers\033[0m"
	cd src/nginx_example && docker-compose up --build -d

	@echo "\e[32m[#] Container is now running!\e[0m"
