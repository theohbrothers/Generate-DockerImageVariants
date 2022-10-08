@"
FROM alpine:3.8

"@

if ('curl' -in $VARIANT['components']) {
    @'
# Install curl
RUN apk update \
    && apk add --no-cache \
        curl \
    && rm -rf /var/cache/apk/*

'@
}

if ('git' -in $VARIANT['components']) {
    @'
# Install git
RUN apk update \
    && apk add --no-cache \
        git \
    && rm -rf /var/cache/apk/*

'@
}

@'
CMD ["crond", "-f"]
'@
