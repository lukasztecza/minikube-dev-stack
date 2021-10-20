FROM mysql:8.0

RUN adduser --system --no-create-home --group mysqluser \
    && chown -R mysqluser:mysqluser /var/lib/mysql
USER mysqluser

EXPOSE 3306
