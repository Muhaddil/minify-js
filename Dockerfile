FROM node:22-alpine

RUN apk add --no-cache moreutils parallel \
    && npm install -g terser esbuild lightningcss lightningcss-cli minify html-minifier-terser

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
