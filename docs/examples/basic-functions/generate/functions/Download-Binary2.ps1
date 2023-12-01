function Download-Binary2 {
@"
# Install bar
RUN set -eux; \
    wget https://localhost/bar-linux-amd64; \
    mv bar-linux-amd64 /usr/local/bin/bar; \
    chmod +x /usr/local/bin/bar; \
    bar version
"@
}
