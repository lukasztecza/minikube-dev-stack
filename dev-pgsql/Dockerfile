FROM postgres:14.0-alpine3.14

RUN mkdir /var/lib/postgresql/data/pgdata \
    && addgroup -S postgresuser \
    && adduser -S -G postgresuser postgresuser \
    && chown -R postgresuser:postgresuser /var/lib/postgresql/data/pgdata
USER postgresuser

EXPOSE 5432 
