@'
# Install curl
RUN apk update \
    && apk add --no-cache curl \
    && rm -rf /var/cache/apk/*
'@