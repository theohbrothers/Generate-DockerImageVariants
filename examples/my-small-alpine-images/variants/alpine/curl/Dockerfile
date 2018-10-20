FROM nginx:1.14-alpine

# Install curl
RUN apk update \
    && apk add --no-cache curl \
    && rm -rf /var/cache/apk/*

CMD ["nginx", "-g", "daemon off;"]