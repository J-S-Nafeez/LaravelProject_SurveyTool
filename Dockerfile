# 1. Use official PHP 8.2 image with FPM
FROM php:8.2-fpm

# 2. Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    git \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip pdo pdo_mysql \
    && rm -rf /var/lib/apt/lists/*

# 3. Set working directory
WORKDIR /var/www

# 4. Copy the composer.json and composer.lock first (for better caching)
COPY composer.json composer.lock /var/www/

# 5. Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 6. Install PHP dependencies
RUN composer install --no-dev --optimize-autoloader

# 7. Copy the full application code (after dependencies installed)
COPY . /var/www

# 8. Set correct permissions (important for Laravel)
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# 9. Expose port 9000
EXPOSE 9000

# 10. Start PHP-FPM
CMD ["php-fpm"]
