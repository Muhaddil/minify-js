FROM node:20
COPY entrypoint.sh /entrypoint.sh
RUN apt-get update
RUN apt-get -y install moreutils
RUN npm install -g minify@9.2.0 html-minifier-terser postcss-cli cssnano
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
