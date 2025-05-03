FROM us-east4-docker.pkg.dev/dev-45627/uequations-docker-registry/php:v1.12-add-redis

# Set working directory
WORKDIR /var/www/html

RUN requirements="libpng++-dev libzip-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg-turbo8 libjpeg-turbo8-dev libfreetype6-dev libicu-dev libxslt1-dev zip unzip libxml2 libonig-dev" \
    set -eux; \
    apt-get update; \
    apt-get install -y $requirements; \
    rm -rf /var/lib/apt/lists/* 

# Install dependencies
RUN set -eux; \
    docker-php-ext-install pdo_mysql; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install gd; \
    docker-php-ext-install mbstring; \
    docker-php-ext-install zip; \
    docker-php-ext-install intl; \
    docker-php-ext-install xsl; \
    docker-php-ext-install soap; \
    docker-php-ext-install sockets; \
    docker-php-ext-install bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy existing application directory contents
COPY . /var/www/html

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

WORKDIR /var/www/html

RUN composer validate

RUN set -ex; \
	find var generated vendor pub/static pub/media app/etc -type f -exec chmod 644 {} + \
	&& find var generated vendor pub/static pub/media app/etc -type d -exec chmod 755 {} + \
	&& find \
	lib \
	vendor \
	pub/static \
	app/etc \
	generated/code \
	generated/metadata \
	var/view_preprocessed \
	\( -type d -or -type f \) -exec chmod g-w {} \; \
	&& chmod o-rwx app/etc/env.php

RUN set -eux; \
    mkdir -p var/cache; \
	chown -R www-data:www-data /var/www/html

# Expose port 80 and start Apache server
EXPOSE 80
# CMD ["apache2-foreground"]
