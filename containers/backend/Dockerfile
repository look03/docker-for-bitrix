FROM debian:bullseye-20240211-slim

LABEL maintainer="TEST <hello@test.ru>"

RUN apt-get update && \
    apt-get upgrade -y

ENV DEBIAN_FRONTEND=noninteractive \
    APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid

RUN apt-get install -y apt-transport-https gnupg wget curl rsyslog cron zip unzip ssmtp && \
    wget -qO- https://packages.sury.org/php/apt.gpg | apt-key add - 2>/dev/null && \
    echo "deb https://packages.sury.org/php/ bullseye main" | tee /etc/apt/sources.list.d/php.list

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
      git \
      apache2 \
      php8.1 \
      php8.1-gd \
      php8.1-imagick \
      php8.1-curl \
      php8.1-intl \
      php8.1-interbase \
      php8.1-mbstring \
      php8.1-mcrypt \
      php8.1-memcache \
      php8.1-memcached \
      php8.1-mysql \
      php8.1-opcache \
      php8.1-soap \
      php8.1-zip \
      && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY ./rootfs/ /

RUN a2enmod remoteip && \
    a2enconf remoteip && \
    a2enmod php8.1 && \
    a2enmod rewrite && \
    update-alternatives --set php /usr/bin/php8.1 && \
    phpenmod -v 8.1 -s apache2 soap bitrixenv testenv && \
    phpenmod -v 8.1 -s cli clienv && \
    echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf && \
    usermod -u 1000 www-data && \
    touch /var/log/bitrix.log && \
    chown www-data:1000 /var/log/bitrix.log && \
    chown www-data:1000 /tmp && \
    chmod 777 /tmp

WORKDIR /var/www/html/

CMD ["sh", "-c", "/etc/init.d/rsyslog start 1>/dev/null; /etc/init.d/cron start 1>/dev/null; /usr/sbin/apache2ctl -D FOREGROUND"]

EXPOSE 80
