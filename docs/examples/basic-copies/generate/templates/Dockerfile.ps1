@"
FROM alpine:3.8

echo "My tag is $( $VARIANT['tag'] )"

COPY app /app

# Install curl
RUN apk update \
    && apk add --no-cache \
        curl \
    && rm -rf /var/cache/apk/*

CMD ["crond", "-f"]
"@
