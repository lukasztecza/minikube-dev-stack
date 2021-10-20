FROM postgres:14.0-alpine3.14

RUN mkdir /var/lib/postgresql/data/pgdata \
    && addgroup -g 1010 -S devgroup \
    && adduser -u 1010 -S -G devgroup devuser \
    && chown -R devuser:devgroup /var/lib/postgresql/data/pgdata
USER devuser

EXPOSE 5432 
