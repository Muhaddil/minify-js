FROM node:lts

COPY entrypoint.sh /entrypoint.sh

RUN apt-get update && \
    apt-get install -y moreutils parallel && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g \
    terser \
    esbuild \
    lightningcss \
    minify \
    html-minifier-terser  # (opcional, para características avanzadas de HTML)

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]