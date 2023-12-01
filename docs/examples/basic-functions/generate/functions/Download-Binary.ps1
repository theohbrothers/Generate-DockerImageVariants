function Download-Binary {
@"
# Install foo
RUN set -eux; \
    wget https://localhost/foo-linux-amd64; \
    mv foo-linux-amd64 /usr/local/bin/foo; \
    chmod +x /usr/local/bin/foo; \
    foo version
"@
}
