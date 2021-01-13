FROM alpine:3.8

# Install curl
RUN apk update \
    && apk add --no-cache curl \
    && rm -rf /var/cache/apk/*

# Install curl
RUN apk update \
    && apk add --no-cache git \
    && rm -rf /var/cache/apk/*

CMD ["crond", "-f"]