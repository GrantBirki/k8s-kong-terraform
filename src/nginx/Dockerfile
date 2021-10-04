FROM nginx:mainline-alpine
RUN rm /etc/nginx/conf.d/*
ADD config/default.conf /etc/nginx/conf.d/
ADD config/index.html /usr/share/nginx/html/
