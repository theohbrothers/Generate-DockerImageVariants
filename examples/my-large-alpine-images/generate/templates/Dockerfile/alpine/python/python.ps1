@'
# Install curl
RUN apk update \
    && apk add --no-cache \
        python \
        python-dev \
    && rm -rf /var/cache/apk/*
'@