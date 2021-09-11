FROM nginx:mainline-alpine
RUN rm /etc/nginx/conf.d/*
ADD config/hello.conf /etc/nginx/conf.d/
ADD config/index.html /usr/share/nginx/html/
