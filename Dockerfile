FROM docker.io/library/php:8.5-apache

# Install dependencies for intl and GD
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

# Install driver database
RUN docker-php-ext-install mysqli pdo pdo_mysql intl

# Aktifkan rewrite
RUN a2enmod rewrite

# Copy source code ke container untuk deployment production
COPY . /var/www/html/

# Pastikan folder uploads ada dan writable, serta permission file sesuai
RUN mkdir -p /var/www/html/uploads/thumbnails \
	&& chown -R www-data:www-data /var/www/html \
	&& chmod -R 755 /var/www/html \
	&& chmod -R 775 /var/www/html/uploads

CMD ["apache2-foreground"]
