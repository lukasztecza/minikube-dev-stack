FROM nginx:stable-alpine

RUN mkdir -p /etc/customssl/live \
    && rm /etc/nginx/nginx.conf \
    && rm /etc/nginx/conf.d/* \
    && rm /usr/share/nginx/html/* \
    && addgroup -g 1010 -S devgroup \
    && adduser -u 1010 -S -G devgroup devuser \
    && chown devuser:devgroup /etc/nginx/conf.d \
    && chown devuser:devgroup /etc/customssl/live
COPY nginx.conf /etc/nginx/nginx.conf
COPY error.html /usr/share/nginx/html/error.html
COPY favicon.ico /var/www/html/public/assets/favicon.ico
COPY favicon.jpg /var/www/html/public/assets/favicon.jpg
COPY ["default.conf.template", "extra.conf.template", "/etc/nginx/templates/"]
USER devuser

EXPOSE 8080
EXPOSE 8181
EXPOSE 8443
