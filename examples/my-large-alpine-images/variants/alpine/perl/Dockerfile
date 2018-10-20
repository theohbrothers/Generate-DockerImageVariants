FROM alpine:3.8

LABEL maintainer="The Oh Brothers"

# Install curl
RUN apk update \
    && apk add --no-cache \
        perl \
        perl-doc \
        perl-dev \
    && rm -rf /var/cache/apk/*

COPY app /app