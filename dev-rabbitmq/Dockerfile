FROM rabbitmq:3.8-management-alpine

COPY rabbitmqadmin /usr/sbin/rabbitmqadmin
RUN addgroup -S rabbitmquser \
    && adduser -S -G rabbitmquser rabbitmquser \
    && chown -R rabbitmquser:rabbitmquser /var/lib/rabbitmq \
    && chown rabbitmquser:rabbitmquser /usr/sbin/rabbitmqadmin
USER rabbitmquser

EXPOSE 5672
EXPOSE 15672
