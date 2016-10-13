FROM alpine:3.4

# Set up certificates, our base tools, and Vault.
RUN apk add --no-cache ca-certificates openssl



RUN apk add --no-cache openssh-client git tar curl && \
    curl --silent --show-error --fail --location \
    --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
    "https://caddyserver.com/download/build?os=linux&arch=amd64&features=git" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy \
    && chmod 0755 /usr/bin/caddy

ADD myca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
ADD Caddyfile /etc/Caddyfile
EXPOSE 80 443 2015
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile"]
