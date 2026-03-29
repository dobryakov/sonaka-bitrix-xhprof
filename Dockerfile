# PHP + Apache для 1C-Битрикс (типовые требования документации)
FROM php:8.2-apache-bookworm

# Системные библиотеки для расширений PHP
RUN apt-get update && apt-get install -y --no-install-recommends \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libwebp-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libssl-dev \
    libmagickwand-dev \
    ghostscript \
    graphviz \
    locales \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen ru_RU.UTF-8
ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8
# Graphviz/dot (Fontconfig) при запуске от www-data должен иметь доступный каталог кеша
ENV XDG_CACHE_HOME=/var/www/.cache

RUN mkdir -p /var/www/.cache/fontconfig \
    && chown -R www-data:www-data /var/www/.cache

# Расширения ядра и рекомендуемые для Битрикс
RUN docker-php-ext-configure gd \
        --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        opcache \
        intl \
        zip \
        soap \
        bcmath \
        calendar \
        exif \
        sockets \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && pecl install xhprof \
    && docker-php-ext-enable xhprof

# Модуль переписывания URL (ЧПУ, .htaccess)
RUN a2enmod rewrite headers ssl

# ЧПУ и служебные файлы Битрикс требуют AllowOverride All
COPY docker/000-bitrix.conf /etc/apache2/sites-available/000-default.conf

# Настройки php.ini под Битрикс (upload, сессии, max_input_vars и т.д.)
COPY docker/php-bitrix.ini /usr/local/etc/php/conf.d/bitrix.ini
COPY docker/php-xhprof.ini /usr/local/etc/php/conf.d/xhprof.ini

WORKDIR /var/www/html
