FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y nginx

ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx_presti.conf /etc/nginx/conf.d/presti.conf

RUN mkdir -p /data/www/
ADD css /data/www/css
ADD js /data/www/js
ADD data /data/www/data
ADD index.html /data/www/index.html
ADD elm.js /data/www/elm.js

EXPOSE 80

CMD nginx -g "daemon off;"
