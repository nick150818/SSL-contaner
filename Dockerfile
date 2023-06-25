# Define Alpine and NGINX versions to use.
ARG ALPINE_VERSION=3.17.3
ARG NGINX_VERSION=1.23.4

# Prepare an Alpine-based image with OpenSSL.
FROM alpine:${ALPINE_VERSION} as alpine
ARG DOMAIN_NAME=localhost
ARG DAYS_VALID=30

RUN apk add --no-cache openssl
RUN echo "Creating self-signed certificate valid for ${DAYS_VALID} days for domain ${DOMAIN_NAME}" && \
    openssl \
    req -x509 \
    -nodes \
    -subj "/CN=${DOMAIN_NAME}}" \
    -addext "subjectAltName=DNS:${DOMAIN_NAME}" \
    -days ${DAYS_VALID} \
    -newkey rsa:2048 -keyout /tmp/self-signed.key \
    -out /tmp/self-signed.crt

# Prepare an NGINX-based image with the certificate created above.
FROM nginx:${NGINX_VERSION} as nginx
COPY --from=alpine /tmp/self-signed.key /etc/ssl/private
COPY --from=alpine /tmp/self-signed.crt /etc/ssl/certs
COPY  . /etc/nginx/conf.d/default.conf
# server {
#    listen 80;
#    listen [::]:80;
#    listen 443 ssl;
#    listen [::]:443 ssl;
#    ssl_certificate /etc/ssl/certs/self-signed.crt;
#    ssl_certificate_key /etc/ssl/private/self-signed.key;
#    location / {
#        root   /usr/share/nginx/html;
#        index  index.html index.htm;
#    }
#    error_page   500 502 503 504  /50x.html;
#    location = /50x.html {
#        root   /usr/share/nginx/html;
#    }
# }
#EOF