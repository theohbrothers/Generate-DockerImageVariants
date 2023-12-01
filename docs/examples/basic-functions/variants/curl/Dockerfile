FROM alpine:3.8

echo "My tag is curl"

# Install curl
RUN apk update \
    && apk add --no-cache \
        curl \
    && rm -rf /var/cache/apk/*

# Install foo
RUN set -eux; \
    wget https://localhost/foo-linux-amd64; \
    mv foo-linux-amd64 /usr/local/bin/foo; \
    chmod +x /usr/local/bin/foo; \
    foo version

# Install bar
RUN set -eux; \
    wget https://localhost/bar-linux-amd64; \
    mv bar-linux-amd64 /usr/local/bin/bar; \
    chmod +x /usr/local/bin/bar; \
    bar version

CMD ["crond", "-f"]