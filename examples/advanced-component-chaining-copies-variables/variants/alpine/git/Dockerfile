FROM alpine:3.8

LABEL maintainer="The Oh Brothers"

# Install git
RUN apk update \
    && apk add --no-cache \
        git \
    && rm -rf /var/cache/apk/*

COPY app /app
COPY config /config

CMD ["perl", "/app/hello.pl"]