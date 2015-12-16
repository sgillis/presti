FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install -y nginx

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/nginx_presti.conf /etc/nginx/conf.d/presti.conf

RUN mkdir -p /data/www/src
ADD css /data/www/css
ADD js /data/www/js
ADD src/elm.js /data/www/src/elm.js
ADD index.html /data/www/index.html

EXPOSE 80

CMD bash /data/www/js/glue.js.sh && nginx -g "daemon off;"
