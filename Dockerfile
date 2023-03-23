FROM node:16
COPY entrypoint.sh /entrypoint.sh
COPY minify_html.js /minify_html.js
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
