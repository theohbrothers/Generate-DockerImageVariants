@"
FROM alpine:3.8

echo "My tag is $( $VARIANT['tag'] )"

# Install curl
RUN apk update \
    && apk add --no-cache \
        curl \
    && rm -rf /var/cache/apk/*

$( Download-Binary )

$( Download-Binary2 )

CMD ["crond", "-f"]
"@
