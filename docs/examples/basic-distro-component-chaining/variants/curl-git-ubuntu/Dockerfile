FROM ubuntu:16.04

echo "My tag is curl-git-ubuntu"


# Install curl
RUN apt-get update \
    && apt-get install -y \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Install curl
RUN apt-get update \
    && apt-get install -y \
        git \
    && rm -rf /var/lib/apt/lists/*

CMD ["cron", "-f"]