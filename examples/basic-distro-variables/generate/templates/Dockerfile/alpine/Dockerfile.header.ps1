@"
FROM alpine:3.8

LABEL maintainer="$( $PASS_VARIABLES['foo'] )"
"@
