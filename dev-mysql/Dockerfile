FROM mysql:8.0

RUN addgroup -gid 1010 --system devgroup \
    && adduser --uid 1010 --gid 1010 --system --no-create-home devuser \
    && chown -R devuser:devgroup /var/lib/mysql
USER devuser

EXPOSE 3306
