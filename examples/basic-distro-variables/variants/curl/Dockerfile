FROM alpine:3.8

LABEL maintainer="bar"

# Install curl
RUN apk update \
    && apk add --no-cache \
        curl \
    && rm -rf /var/cache/apk/*

CMD ["crond", "-f"]