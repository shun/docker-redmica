# Redmica for Docker

This is the Redmica environment which is based on Docker.

This container has Nginx because of using REST API for preflight feature.

If you don't need Nginx in the container, please remove the ["nginx.conf"](/supervisor/conf.d/nginx.conf) file.

And change the port on [docker-compose.yaml](/docker-compose.yaml#L32) to "3000".

Redmica run with port 3000 in the container.

## How to run

```
$ docker-composee up -d
```

## Author

KUDO Shunsuke

