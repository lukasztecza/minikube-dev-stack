FROM nginx:stable-alpine

RUN rm /etc/nginx/nginx.conf \
    && rm /etc/nginx/conf.d/* \
    && rm /usr/share/nginx/html/* \
    && addgroup -S nginxuser \
    && adduser -S -G nginxuser nginxuser \
    && chown nginxuser:nginxuser /etc/nginx/conf.d
COPY nginx.conf /etc/nginx/nginx.conf
COPY error.html /usr/share/nginx/html/error.html
COPY favicon.ico /var/www/html/public/assets/favicon.ico
COPY favicon.jpg /var/www/html/public/assets/favicon.jpg
COPY ["default.conf.template", "extra.conf.template", "/etc/nginx/templates/"]
USER nginxuser

EXPOSE 8080
EXPOSE 8181
