# Tomcat-Apache-BackupLog
SCRIPT BACKUP LOGS APACHE 2 & TOMCATS 
BACKUP DAY ONLY                       


> FIRST INSTALL 

- Install APACHE2
- Install TOMCAT8
- recover script archive :
- unzip the archive /opt :
* **	/opt/backup.sh **
* **	/opt/log/ **
* **	/opt/tmp/ **
* **	/opt/tmp/backup/ **
* **	/opt/tmp/backup/apache/ **
* **	/opt/tmp/backup/tomcat/ **

- Setting up the environment (Commande SHELL):
* **	mkdir /var/www/html/archives **
* **	mkdir /var/www/html/archives/days/apache2 **
* **	mkdir /var/www/html/archives/days/tomcat **
* **	mkdir /var/www/html/archives/weeks/tomcat **
* **	mkdir /var/www/html/archives/weeks/apache2 **
* **	chown -R www-data:www-data /var/www/html/archives/' **

- Scheduled :
	vi /etc/crontab
	Add the lines :
* **		#daily backup 00h30 everyday **
* **		0  30  *  *  *  root  /bin/bash /opt/backup.sh days >> /opt/log/backup.log **
* **		# Weekly backup 1h00 every Sunday **
* **		0  1   *  *  7  root  /bin/bash /opt/backup.sh weeks >> /opt/log/backup.log **

- Protect access to backup with an htaccess :
* **	/var/www/html/archives/.htaccess **
* **	/var/www/html/archives/.htpasswd **

	--------------------------------------------------------------
        |                                                            |
        |  Defaut                                                    |
        |  url :           http://localhost/archives                 |
        |  user :          .htaccess                                 |
	|  password :      .htaccess                                 |
        |                                                            |
        '-------------------------------------------------------------
        
	  ----------------------------------------------------------
	  |                                                        |
	  |  Please specify if backup is  daily or weekly :        |
	  |                                                        |
	  |           bash '$dirscript'/backup.sh days             |
	  |                      or                                |
	  |           bash '$dirscript'/backup.sh weeks            |
	  |                                                        |
	  |    COMMAND HELP : bash '$dirscript'/backup.sh --help   |
	  |                                                        |
	  '---------------------------------------------------------

