# Using https://github.com/gliderlabs/docker-alpine,
# plus  https://github.com/just-containers/s6-overlay for a s6 Docker overlay.
FROM gliderlabs/alpine:3.6
# Initially was based on work of Christian Lück <christian@lueck.tv>.
LABEL description="A complete, self-hosted Tiny Tiny RSS (TTRSS) environment." \
      maintainer="Andreas Löffler <andy@x86dev.com>"

RUN set -xe && \
    apk update && apk upgrade && \
    apk add --no-cache --virtual=run-deps \
    busybox nginx git ca-certificates curl \
    php7 php7-fpm php7-curl php7-dom php7-gd php7-iconv php7-fileinfo php7-json \
    php7-mcrypt php7-pgsql php7-pcntl php7-pdo php7-pdo_pgsql \
    php7-mysqli php7-pdo_mysql \
    php7-mbstring php7-posix php7-session \
    php7-intl postgresql-client

# Add user www-data for php-fpm.
# 82 is the standard uid/gid for "www-data" in Alpine.
RUN adduser -u 82 -D -S -G www-data www-data

# Add s6 overlay.
# Note: Tweak this line if you're running anything other than x86 AMD64 (64-bit).
RUN curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v1.19.1.1/s6-overlay-amd64.tar.gz | tar xvzf - -C /

# Add wait-for-it.sh
ADD https://raw.githubusercontent.com/Eficode/wait-for/master/wait-for /srv
RUN chmod 755 /srv/wait-for

ENV TTRSS_REPO_URL https://git.tt-rss.org/git/tt-rss.git
ENV TTRSS_PATH /var/www/ttrss
ENV TTRSS_PATH_THEMES ${TTRSS_PATH}/themes.local
ENV TTRSS_PATH_PLUGINS ${TTRSS_PATH}/plugins.local

ENV NGINX_CONF /etc/nginx/nginx.conf

RUN mkdir -p ${TTRSS_PATH} && \
    git clone --depth=1 ${TTRSS_REPO_URL} ${TTRSS_PATH} && \
    mkdir -p ${TTRSS_PATH_PLUGINS} && \
    git clone --depth=1 https://github.com/sepich/tt-rss-mobilize.git ${TTRSS_PATH_PLUGINS}/mobilize && \
    git clone --depth=1 https://github.com/m42e/ttrss_plugin-feediron.git ${TTRSS_PATH_PLUGINS}/feediron && \
    mkdir -p ${TTRSS_PATH_THEMES} && \
    git clone --depth=1 https://github.com/levito/tt-rss-feedly-theme.git ${TTRSS_PATH_THEMES}/levito-feedly-git && \
    git clone --depth=1 https://github.com/Gravemind/tt-rss-feedlish-theme.git ${TTRSS_PATH_THEMES}/gravemind-feedly-git

# Copy root file system.
COPY root /

RUN cd ${TTRSS_PATH_THEMES} && \
    ln -f -s ${TTRSS_PATH_THEMES}/levito-feedly-git/feedly && \
    ln -f -s ${TTRSS_PATH_THEMES}/levito-feedly-git/feedly.css && \
    ln -f -s ${TTRSS_PATH_THEMES}/gravemind-feedly-git/feedlish.css && \
    ln -f -s ${TTRSS_PATH_THEMES}/gravemind-feedly-git/feedlish.css.map && \
    ln -f -s ${TTRSS_PATH_THEMES}/gravemind-feedly-git/feedlish-night.css && \
    ln -f -s ${TTRSS_PATH_THEMES}/gravemind-feedly-git/feedlish-night.css.map && \
    chown -R root:root /etc/nginx /etc/php7 /var/lib/nginx /etc/services.d && \
    chown -R www-data:www-data ${TTRSS_PATH} && \
    rm /usr/bin/php && \
    ln -s /usr/bin/php7 /usr/bin/php && \
    ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm

COPY wukeys-init.php ${TTRSS_PATH_PLUGINS}/wukeys/init.php

# Clean up.
RUN set -xe && apk del --progress --purge && rm -rf /var/cache/apk/*

# Expose Nginx ports.
EXPOSE 8080

ENTRYPOINT ["/init"]
