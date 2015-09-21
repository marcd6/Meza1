#!/bin/bash
#
# Setup PHP

print_title "Starting script php.sh"

#
# Prompt user for PHP version
#
while [ -z "$phpversion" ]
do
echo -e "\n\n\n\nVisit http://php.net/downloads.php"
echo -e "\nEnter the version of PHP you would like (such as 5.4.42) and press [ENTER]: "
read phpversion
done


#
# Download (for example) PHP 5.6.10, 5.5.26, or 5.4.42 source
#
cd ~/sources
tarfile="php-$phpversion.tar.bz2"
wget "http://php.net/get/php-$phpversion.tar.bz2/from/this/mirror" -O "$tarfile"


#
# Check if PHP successfully downloaded, exit if not
#
if [ -f $tarfile ];
then
   echo "PHP v$phpversion downloaded. Unpacking."
else
   echo "PHP v$phpversion not downloaded. Exiting."
   exit 1
fi


#
# Unpack tar.bz2
#
tar jxf "php-$phpversion.tar.bz2"
cd "php-$phpversion/"


#
# Configure, make, make install
#
cmd_profile "START php build"
./configure \
    --with-apxs2=/usr/local/apache2/bin/apxs \
    --enable-bcmath \
    --with-bz2 \
    --enable-calendar \
    --with-curl \
    --enable-exif \
    --enable-ftp \
    --with-gd \
    --with-jpeg-dir \
    --with-png-dir \
    --with-freetype-dir \
    --enable-gd-native-ttf \
    --with-imap \
    --with-imap-ssl \
    --with-kerberos \
    --enable-mbstring \
    --with-mcrypt \
    --with-mhash \
    --with-mysql \
    --with-mysqli \
    --with-openssl \
    --with-pcre-regex \
    --with-pdo-mysql \
    --with-zlib-dir \
    --with-regex \
    --enable-sysvsem \
    --enable-sysvshm \
    --enable-sysvmsg \
    --enable-soap \
    --enable-sockets \
    --with-xmlrpc \
    --enable-zip \
    --with-zlib \
    --enable-inline-optimization \
    --enable-mbregex \
    --enable-opcache \
    --enable-fpm \
    --enable-intl \
    --prefix=/usr/local/php
make
make install
cmd_profile "END php build"

# add symlink to php binary in location already in path
sudo ln -s /usr/local/php/bin/php /usr/bin/php

#
# Initiate php.ini
#
cp "$m_meza/client_files/php.ini-development" /usr/local/php/lib/php.ini

#
# Add wiki landing page
#
cd "$m_htdocs"
cp "$m_meza/client_files/index.php" ./index.php

#
# Create info.php
#
touch info.php
echo '<?php phpinfo();' > info.php

# Check and make sure php5_module is enabled?
# @todo: do we need this?
#LoadModule php5_module modules/libphp5.so

#
# Start webserver service
#
chkconfig httpd on
service httpd status
service httpd restart


echo -e "\n\nPHP has been setup.\n\nPlease use the web browser on your host computer to navigate to http://192.168.56.56/info.php to verify php is being executed."
