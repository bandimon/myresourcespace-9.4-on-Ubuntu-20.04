FROM ubuntu:20.04

MAINTAINER Diego Picciani <*bandi*mon*@gmail.com>  (please remove *)

# SSH accessibile con root/root
# MYSQL localhost accessibile con
#   RW : resourcespacerw:resourcespacerw
#   RO :  resourcespacero:resourcespacero
#
# ricordarsi di mappare sempre :
#    /backupdb
#    /var/www/html/filestore oppure l'intera /var/www/html
#
# IMPORTANTE!!!!!
# In caso di upgrade ricordarsi di copia config.php da /backupdb a /var/www/html/include PRIMA dell'esecuzione di CRON altrimenti si perde la configurazione!!!!!
#

# aggiornamento repository
RUN apt-get update

#installazione SSH e utility APT
#RUN apt-get install -qy ssh software-properties-common
RUN DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes ssh rsyslog software-properties-common

#configurazione SSH ed impostazione password a root
RUN echo 'root:root' |chpasswd
RUN sed -ri 's/^#PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

#installazione Apache, MySQL, PHP e tutte le utility necessarie
#RUN add-apt-repository ppa:mc3man/trusty-media
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes curl vim nano less mc sudo unoconv imagemagick apache2 mariadb-server subversion inkscape ghostscript antiword poppler-utils postfix libimage-exiftool-perl cron wget php php-dev php-gd php-mysql php-curl php-mbstring php-zip libapache2-mod-php ffmpeg libgs-dev antiword zip python3-uno libreoffice-writer libreoffice-draw libreoffice-calc libreoffice-impress libreoffice-base-core libreoffice-core libreoffice-pdfimport libreoffice-avmedia-backend-gstreamer libreoffice-math libglu1-mesa
 
#configurazione PHP
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 8G/g" /etc/php/7.4/apache2/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 1G/g" /etc/php/7.4/apache2/php.ini
RUN sed -i -e "s/max_execution_time\s*=\s*30/max_execution_time = 1000/g" /etc/php/7.4/apache2/php.ini
RUN sed -i -e "s/memory_limit\s*=\s*128M/memory_limit = 8G/g" /etc/php/7.4/apache2/php.ini

#scarico ed installo ResourceSpace (trunk)
#RUN mkdir /var/www/html.first \
#    && cd /var/www/html.first \
#	&& svn co http://svn.resourcespace.org/svn/rs/trunk . \
#	&& mkdir filestore \
#	&& chmod 777 filestore \
#	&& chmod -R 777 include

#scarico ed installo ResourceSpace versione 9.4
RUN mkdir /var/www/html.first \
    && cd /var/www/html.first \
	&& svn co http://svn.resourcespace.org/svn/rs/releases/9.4 . \
	&& mkdir filestore \
	&& chmod 777 filestore \
	&& chmod -R 777 include

#inibisco la navigazione per cartelle nel sito web
RUN echo "<Directory /var/www/html>" >> /etc/apache2/sites-available/000-default.conf
RUN echo "Options -Indexes" >> /etc/apache2/sites-available/000-default.conf
RUN echo "AllowOverride All" >> /etc/apache2/sites-available/000-default.conf
RUN echo "Order allow,deny" >> /etc/apache2/sites-available/000-default.conf
RUN echo "Allow from all" >> /etc/apache2/sites-available/000-default.conf
RUN echo "</Directory>" >> /etc/apache2/sites-available/000-default.conf

# aggiungiungo le funzionalita' per unoconv (docx, xlsx)
RUN echo '$unoconv_path="/usr/bin";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$unoconv_extensions=array("doc","docx","odt","odp","html","rtf","txt","xls","xlsx","ppt","pptx","sxw","sdw","html","psw","rtf","sdw","pdb","bib","txt","ltx","sdd","sda","odg","sdc");' >> /var/www/html.first/include/config.new_installs.php

# aggiungo le funzionalita' per la preview dei video
RUN echo '$videojs=true;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview=true;' >> /var/www/html.first/include/config.new_installs.php 
RUN echo '$ffmpeg_preview_seconds=120; # how many seconds to preview' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_extension="mp4";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_min_width=32;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_min_height=18;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_max_width=480;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_max_height=270;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_options="-f mp4 -ar 22050 -b 650k -ab 32k -ac 1";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_global_options = "";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_force=false;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$video_preview_original=false;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_preview_async=false;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_get_par=false;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$ffmpeg_use_qscale = true;' >> /var/www/html.first/include/config.new_installs.php

# aggiungo le funzionalita' per il donwload ZIP
RUN echo '$archiver_path = "/usr/bin";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$archiver_executable = "zip";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$archiver_listfile_argument = "-@ <";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$collection_download = true;' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$collection_download_max_size = 10 * 1024 * 1024 * 1024; # default 10GB.' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$collection_download_settings[0]["name"] = "ZIP";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$collection_download_settings[0]["extension"] = "zip";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$collection_download_settings[0]["arguments"] = "-j";' >> /var/www/html.first/include/config.new_installs.php
RUN echo '$collection_download_settings[0]["mime"] = "application/zip";' >> /var/www/html.first/include/config.new_installs.php

# aggiungo il processo cron per il savataggio del db e processing automatico di resourcespace
RUN mkdir /backupdb
RUN chmod 666 /backupdb
RUN echo '#!/bin/bash' > /backupdb.sh
RUN echo 'mysqldump resourcespace --no-data --skip-set-charset > /backupdb/resourcespace_schema.sql' >> /backupdb.sh
RUN echo 'mysqldump resourcespace --no-create-db --no-create-info --skip-set-charset --resultfile=/backupdb/resourcespace_data.sql' >> /backupdb.sh
RUN echo 'cp /var/lib/htm/include/config.php /backupdb' >> /backupdb.sh
RUN echo '#!/bin/bash' > /resourcespacetask.sh
RUN echo 'wget http://localhost/batch/cron.php > /tmp/resourcespacetask.lastrun.log' >> /resourcespacetask.sh
RUN echo '30 4 * * * /backupdb.sh >> /var/log/cron.log 2>&1' >> /var/spool/cron/crontabs/root
RUN echo '00 4 * * * /resourcespacetask.sh >> /var/log/cron.log 2>&1' >> /var/spool/cron/crontabs/root
RUN chmod 600 /var/spool/cron/crontabs/root
RUN chown root.crontab /var/spool/cron/crontabs/root
RUN chmod 777 /backupdb.sh
RUN chmod 777 /resourcespacetask.sh

#copio lo script di run.sh
COPY run.sh /run.sh
RUN cd / \
    && chmod 777 run.sh

#eseguo il contenitore
CMD ["/run.sh"]
