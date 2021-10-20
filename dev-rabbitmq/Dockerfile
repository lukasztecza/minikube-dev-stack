FROM rabbitmq:3.8-management-alpine

COPY rabbitmqadmin /usr/sbin/rabbitmqadmin
RUN addgroup -g 1010 -S devgroup \
    && adduser -u 1010 -S -G devgroup devuser \
    && chown -R devuser:devgroup /var/lib/rabbitmq \
    && chown devuser:devgroup /usr/sbin/rabbitmqadmin
USER devuser

EXPOSE 5672
EXPOSE 15672
