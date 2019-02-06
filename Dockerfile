FROM php:7.2-apache

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y zlib1g-dev zip apache2 git libssl-dev
RUN pecl install mongodb-1.5.3 && docker-php-ext-enable mongodb
RUN docker-php-ext-install json zip
RUN apt-get clean -y
RUN apt-get autoclean -y

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/bin/composer

RUN a2enmod rewrite

ADD apache/vhost.conf /etc/apache2/sites-enabled/000-default.conf
ADD . .
WORKDIR .

RUN composer install --no-dev --optimize-autoloader --no-interaction
RUN composer clearcache
RUN chown www-data .
RUN service apache2 restart
