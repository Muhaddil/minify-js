FROM node:lts

COPY entrypoint.sh /entrypoint.sh

RUN apt-get update && \
    apt-get install -y moreutils parallel && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g terser minify@9.2.0 html-minifier-terser postcss-cli cssnano

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
