@"
FROM alpine:3.8

$(if ($VARIANT['components'] -contains 'curl') {
    @'
# Install curl
RUN apk update \
    && apk add --no-cache \
        curl
'@
})


$(if ($VARIANT['components'] -contains 'git') {
    @'
# Install git
RUN apk update \
    && apk add --no-cache \
        git
'@
})

CMD ["crond", "-f"]
"@
