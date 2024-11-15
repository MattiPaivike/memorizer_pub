server {
    listen ${LISTEN_PORT};

    # Main proxy for application traffic
    location / {
        proxy_pass http://${APP_HOST}:${APP_PORT};
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    # Serve static files
    location /static/ {
        alias /vol/web/static/;
    }

    # Health check endpoint
    location /healthcheck {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}