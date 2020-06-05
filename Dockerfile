FROM php:7.4-apache

MAINTAINER Jhonatan Morais <jhonatanvinicius@gmail.com>

# Update system
RUN apt-get update && \
    apt-get upgrade -y

# my stuffs
RUN apt-get install -y nano wget unzip git

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer

#Instalação do php-zip
RUN apt-get install -y libzip-dev zip && \
    docker-php-ext-install zip

#Instalação do php-ldap
RUN apt-get install libldap2-dev -y && \ 
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

# Instalação do php-pgsql
RUN apt-get install libpq-dev -y && \
    docker-php-ext-install pdo_pgsql

# Instalação do mysql
RUN docker-php-ext-install mysqli pdo_mysql

# instalação do GD
RUN docker-php-ext-install gd    

#Instalação laravel
RUN composer global require laravel/installer && \
	echo "alias laravel='~/.composer/vendor/bin/laravel'" >> ~/.bashrc && \
	alias laravel='~/.composer/vendor/bin/laravel' && \
    a2enmod rewrite

#https://www.digitalocean.com/community/tutorials/how-to-create-a-self-signed-ssl-certificate-for-apache-in-debian-10-pt
#Configuração de SSL Gerado em 30/05/2020 
ADD apache-selfsigned.key /etc/ssl/private/apache-selfsigned.key
ADD apache-selfsigned.crt /etc/ssl/certs/apache-selfsigned.crt
ADD ssl-params.conf /etc/apache2/conf-available/ssl-params.conf
RUN cp /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf.bak
ADD default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
RUN a2enmod ssl && \
    a2enmod headers && \
    a2ensite default-ssl && \
    a2enconf ssl-params

#Facilidades de uso
RUN sed -i 's+/var/www/html+/var/www/html/${DOCUMENT_ROOT_CONTEXT}+g' /etc/apache2/sites-available/000-default.conf && \
    sed -i 's+/var/www/html+/var/www/html/${DOCUMENT_ROOT_CONTEXT}+g' /etc/apache2/sites-available/default-ssl.conf && \
	sed -i 's+AllowOverride None+AllowOverride ${ALLOW_OVERRIDE_OPTION} \n SetEnv APPLICATION_ENV ${APPLICATION_ENV_OPTION}+g' /etc/apache2/apache2.conf








