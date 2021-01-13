@"
COPY app /app
COPY config /config

CMD ["perl", "/app/hello.pl"]
"@
