FROM alpine:3.8

LABEL maintainer="The Oh Brothers"

# Install perl
RUN apk update \
    && apk add --no-cache \
        perl \
        perl-doc \
        perl-dev \
    && rm -rf /var/cache/apk/*

# Install git
RUN apk update \
    && apk add --no-cache \
        git \
    && rm -rf /var/cache/apk/*

COPY app /app

CMD ["perl", "/app/hello.pl"]