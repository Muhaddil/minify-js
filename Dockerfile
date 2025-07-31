FROM node:22

COPY entrypoint.sh /entrypoint.sh

RUN apt-get update && \
    apt-get install -y moreutils parallel && \
    rm -rf /var/lib/apt/lists/*
    
RUN npm install -g \
    terser \
    esbuild \
    lightningcss-cli \
    minify \
    html-minifier-terser

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]