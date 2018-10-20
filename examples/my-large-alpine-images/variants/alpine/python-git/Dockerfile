FROM alpine:3.8

LABEL maintainer="The Oh Brothers"

# Install curl
RUN apk update \
    && apk add --no-cache \
        python \
        python-dev \
    && rm -rf /var/cache/apk/*

# Install curl
RUN apk update \
    && apk add --no-cache \
        git \
    && rm -rf /var/cache/apk/*

COPY app /app