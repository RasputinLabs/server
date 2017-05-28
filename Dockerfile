FROM rasputinlabs/base-php:0.2
MAINTAINER David Ramsington <grokbot.dwr@gmail.com>

# Set some Environment variables + Build Arguments
ENV DEBIAN_FRONTEND noninteractive
ENV APP_HOST blackmail.local

RUN apt-get install -y -qq \
    nginx \
    gettext-base \
    supervisor \
    && usermod -u 1000 www-data

COPY conf/* /tmp/conf/

# Install Composer + rewrite APP_HOST variable + make the entrypoint executable + clean up our mess + move files to appropriate locations
RUN docker-php-ext-install pdo pdo_mysql mysqli && \
    docker-php-ext-enable opcache && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    envsubst \$APP_HOST < /tmp/conf/vhost.conf > /etc/nginx/conf.d/vhost.conf && \
    mv /tmp/conf/nginx.conf /etc/nginx/nginx.conf && \
    mv /tmp/conf/fastcgi_params /etc/nginx/fastcgi_params && \
    mv /tmp/conf/entrypoint.sh /entrypoint.sh && \
    mv /tmp/conf/supervisord.conf /etc/supervisord.conf && \
    mv /tmp/conf/php.ini /usr/local/etc/php/php.ini && \
    chmod a+x /entrypoint.sh && apt-get remove --purge -y software-properties-common && \
    apt-get autoremove -y && \
    apt-get clean && \
    apt-get autoclean && \
    echo -n > /var/lib/apt/extended_states && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /usr/share/man/?? && \
    rm -rf /usr/share/man/??_*

WORKDIR /usr/share/nginx/html

# Expose Port
EXPOSE 80

# Set Container Entrypoint + Command
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["start"]
