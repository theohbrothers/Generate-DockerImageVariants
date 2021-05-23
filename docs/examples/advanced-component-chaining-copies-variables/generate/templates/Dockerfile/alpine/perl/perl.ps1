@'
# Install perl
RUN apk update \
    && apk add --no-cache \
        perl \
        perl-doc \
        perl-dev \
    && rm -rf /var/cache/apk/*
'@