# Dockerfile for Nginx
FROM nginxinc/nginx-unprivileged:1-alpine

# Copy the Nginx configuration file
COPY ./default.conf.tpl /etc/nginx/conf.d/default.conf.tpl

ENV LISTEN_PORT=8000
ENV APP_HOST=app
ENV APP_PORT=9000

USER root

RUN mkdir -p /vol/web && \
    chmod 755 /vol/web && \
    chown -R nginx:nginx /vol/web /etc/nginx/conf.d/default.conf
    
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER nginx

CMD ["/entrypoint.sh"]