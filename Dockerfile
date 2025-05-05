FROM us-east4-docker.pkg.dev/dev-45627/uequations-docker-registry/php:v1.12-add-redis

RUN { \
		echo 'memory_limit=2G'; \
        echo 'max_execution_time=1800'; \
        echo 'zlib.output_compression=On'; \
        echo 'output_buffering=On'; \
        echo 'max_input_vars=5000'; \
        echo 'max_input_time=600'; \
        echo 'post_max_size=128M'; \
        echo 'upload_max_filesize=128M'; \
        echo 'session.gc_maxlifetime=86400'; \
        echo 'realpath_cache_size=10M'; \
        echo 'realpath_cache_ttl=7200'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.enable=1'; \
        echo 'opcache.enable_cli=1'; \
        echo 'opcache.memory_consumption=512'; \
        echo 'opcache.interned_strings_buffer=16'; \
        echo 'opcache.max_accelerated_files=100000'; \
        echo 'opcache.revalidate_freq=0'; \
        echo 'opcache.validate_timestamps=0'; \
        echo 'opcache.save_comments=1'; \
        echo 'opcache.fast_shutdown=1'; \
	} > /usr/local/etc/php/conf.d/magento2-recommended.ini


# Set working directory
WORKDIR /var/www/html

# Install system dependencies and PHP extensions
RUN requirements="cron libpng++-dev libzip-dev libmcrypt-dev libmcrypt4 libcurl3-dev libfreetype6 libjpeg-turbo8 libjpeg-turbo8-dev libfreetype6-dev libicu-dev libxslt1-dev zip unzip libxml2 libonig-dev" \
    set -eux; \
    apt-get update; \
    apt-get install -y $requirements

RUN set -eux; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install \
        pdo_mysql \
        -j$(nproc) gd \
        mbstring \
        zip \
        intl \
        xsl \
        soap \
        sockets \
        bcmath; \
    a2enmod rewrite; \
    rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN mkdir -p generated/code generated/metadata

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

# Install PHP dependencies
RUN set -eux; \
    composer validate && \
    composer install

# Ensure correct permissions before running Magento CLI
RUN chown -R www-data:www-data var generated pub/static pub/media

USER www-data

# Set file and directory permissions
RUN set -eux; \
    find var generated vendor pub/static pub/media app/etc -type f -exec chmod 644 {} + && \
    find var generated vendor pub/static pub/media app/etc -type d -exec chmod 755 {} + && \
    find lib vendor pub/static app/etc generated/code var/view_preprocessed \
    \( -type d -or -type f \) -exec chmod g-w {} \; && \    
    mkdir -p var/cache && \
    chown -R www-data:www-data /var/www/html

# Expose port 80
ENV PORT=80
EXPOSE 80

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
