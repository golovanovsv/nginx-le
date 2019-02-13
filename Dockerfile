FROM nginx:stable-alpine
MAINTAINER GolovanovSV <golovanovsv@gmail.com>

COPY entrypoint.sh /entrypoint.sh

RUN echo "Build image" \
  && chmod 755 /entrypoint.sh \
  && apk add --update ca-certificates certbot tzdata openssl \
  && rm -rf /var/cache/apk/*

EXPOSE 80/tcp
EXPOSE 443/tcp
VOLUME /etc/nginx/conf.d

ENTRYPOINT ["/entrypoint.sh"]