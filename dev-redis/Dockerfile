FROM redis:6.2.6-alpine3.14

RUN addgroup -g 1010 -S devgroup \
    && adduser -u 1010 -S -G devgroup devuser
USER devuser

EXPOSE 6379
