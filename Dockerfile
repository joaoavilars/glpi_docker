FROM php:8.2-apache

# Dependências e extensões
RUN apt update && apt install -y \
    wget unzip mariadb-client libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libldap2-dev libzip-dev libbz2-dev bzip2 \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd intl pdo pdo_mysql mysqli exif ldap zip bz2 opcache \
    && a2enmod rewrite

# Sessão segura
RUN echo "session.cookie_httponly = On" > /usr/local/etc/php/conf.d/glpi_session.ini

# Instala GLPI em /var/www/glpi
WORKDIR /var/www/glpi
RUN wget https://github.com/glpi-project/glpi/releases/download/10.0.18/glpi-10.0.18.tgz -O /tmp/glpi.tgz && \
    tar -xvzf /tmp/glpi.tgz -C /var/www/glpi --strip-components=1 && \
    chown -R www-data:www-data /var/www/glpi && \
    rm /tmp/glpi.tgz

# Aponta DocumentRoot para a pasta segura (public/)
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/glpi/public|' /etc/apache2/sites-available/000-default.conf

# Define as permissões
RUN chown -R www-data:www-data /var/www/glpi

# Define configurações padrão para o Apache
COPY glpi.conf /etc/apache2/sites-available/glpi.conf
RUN a2ensite glpi.conf && a2dissite 000-default.conf
