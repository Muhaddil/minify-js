FROM node:22-alpine

COPY entrypoint.sh /entrypoint.sh

RUN apk update && \
    apk add --no-cache moreutils parallel

RUN npm install -g \
    terser \
    esbuild \
    lightningcss-cli \
    minify \
    html-minifier-terser

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]