#!/bin/bash

	#################################################
	# SCRIPT BACKUP LOGS APACHE 2 & TOMCATS 	#
	# BACKUP DAY ONLY				#
	#################################################

        # ###############################################
        # EVENEMENTS :	 	                	#
	# Time execuction for days : 00:30am		#
	# Time execuction for weeks : 01:00am on Sunday #
        # /opt/backup.log                       	#
	# HELP : ./backup.sh --help			#
        #################################################

##########################################################
##########################################################

## ADDRESS TO BE SENT IN THE EVENT OF AN ALERT
mail_alerte=root

## DIRECTORY LOG SCRIPT
dirlog=/opt/log

## DIRECTORY SCRIPT
dirscript=/opt

##########################################################
##########################################################

## DIRECTORY ARCHIVES DAYS ALL
dirdaysarchives=/var/www/html/archives/days

## DIRECTORY ARCHIVES WEEKS ALL
dirweekssarchives=/var/www/html/archives/weeks

##########################################################
##########################################################

## DIRECTORY LOGS APACHE
dirlog_apache=/var/log/apache2

## DIRECTORY ARCHIVES APACHE DAYS
dirdaysarchives_apache=/var/www/html/archives/days/apache2

## DIRECTORY TMP APACHE
dirtmp_apache=/opt/tmp/backup/apache2

## DIRECTORY ARCHIVES APACHE WEEKS
dirweeksarchives_apache=/var/www/html/archives/weeks/apache2

###########################################################
###########################################################

## DIRECTORY LOGS TOMCAT
dirlog_tomcat=/var/log/tomcat8

## DIRECTORY ARCHIVES TOMCAT DAYS
dirdaysarchives_tomcat=/var/www/html/archives/days/tomcat

## DIRECTORY ARCHIVES TOMCAT WEEK
dirweeksarchives_tomcat=/var/www/html/archives/weeks/tomcat

## DIRECTORY TMP TOMCAT
dirtmp_tomcat=/opt/tmp/backup/tomcat

## COLOR
GREEN="\\033[1;32m"
RED="\\033[1;31m"
BLUE="\\033[1;34m"
NORMAL="\\033[0;39m"


### Function to stop apache2 and tomcat services
stop_services()
{
        service apache2 stop 2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
	echo -e "Service APACHE2 is : ----------------------------------------------------------------- : "$RED"Stopping" "$NORMAL"
        service tomcat8 stop 2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
	echo -e "Service TOMCAT is : ------------------------------------------------------------------ : "$RED"Stopping" "$NORMAL"
}

### Function for archiving Apache logs per day and per week.
archive_apache()
{
	if [ "$1" == "days" ]
	then
        	rsync -av --compare-dest=$dirtmp_apache/ $dirlog_apache/ $dirtmp_apache/  2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
        	echo -e ">>>>> Recover only changed files(apache) : -------------------------------------------   : "$GREEN"OK" "$NORMAL"

        	echo
        	tar zvcf $dirdaysarchives_apache/"DAY_LOG_APACHE_`date +"%Y-%m-%d"`".tar.gz $dirtmp_apache/
        	echo -e ">>>>> Compression of files recovered in archives(apache) : ---------------------------   : "$GREEN"OK" "$NORMAL"

        	echo
       		chown -R www-data:www-data $dirdaysarchives_apache/"DAY_LOG_APACHE_`date +"%Y-%m-%d"`".tar.gz  2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
        	echo -e ">>>>> Give Apache rights on the archives(apache) : ----------------------------------    : "$GREEN"OK" "$NORMAL"

        	echo 
        	rm -r $dirtmp_apache/*  2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
        	rsync -a $dirlog_apache/* $dirtmp_apache  2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
        	echo -e ">>>>> Copy the files for the next backup(apache) : ----------------------------------    : "$GREEN"OK" "$NORMAL"
	else
	        echo
        	tar zcvf $dirweeksarchives_apache/"WEEK_LOG_APACHE_`date +"%Y-%m-%d"`".tar.gz $dirdaysarchives_apache/
        	echo -e ">>>>> Compression all archives days (apache2) : --------------------------------------    : "$GREEN"OK" "$NORMAL"

        	echo
        	chown -R www-data:www-data $dirweeksarchives_apache/"WEEK_LOG_APACHE_`date +"%Y-%m-%d"`".tar.gz 2>> /opt/log/week_error.`date +"%Y-%m-%d"`.log
        	echo -e ">>>>> Give Apache rights on the archives(apache) : -----------------------------------    : "$GREEN"OK" "$NORMAL"
	fi
}

### Function for archiving Tomcat logs per day and per week.
archive_tomcat()
{
        if [ "$1" == "days" ]
	then
        	rsync -av --compare-dest=$dirtmp_tomcat/ $dirlog_tomcat/ $dirtmp_tomcat/  2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
		echo -e ">>>>> Recover only changed files(tomcat) : ------------------------------------------    : "$GREEN"OK" "$NORMAL"

		echo
		tar zvcf $dirdaysarchives_tomcat/"DAY_LOG_TOMCAT_`date +"%Y-%m-%d"`".tar.gz $dirtmp_tomcat/
		echo -e ">>>>> Compression of files recovered in archives(tomcat) : --------------------------    : "$GREEN"OK" "$NORMAL"

		echo
        	chown -R www-data:www-data $dirdaysarchives_tomcat/"DAY_LOG_TOMCAT_`date +"%Y-%m-%d"`".tar.gz  2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
		echo -e ">>>>> Give Apache rights on the archives(tomcat) : ----------------------------------    : "$GREEN"OK" "$NORMAL"

		echo
		rm -r $dirtmp_tomcat/* 2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
		rsync -a $dirlog_tomcat/* $dirtmp_tomcat  2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
		echo -e ">>>>> Copy the files for the next backup(tomcat) : ----------------------------------    : "$GREEN"OK" "$NORMAL"
	else
		echo
        	tar zcvf $dirweeksarchives_tomcat/"WEEK_LOG_TOMCAT_`date +"%Y-%m-%d"`".tar.gz $dirdaysarchives_tomcat/
        	echo -e ">>>>> Compression all archives days (tomcat) : ---------------------------------------    : "$GREEN"OK" "$NORMAL"

        	echo
        	chown -R www-data:www-data $dirweeksarchives_tomcat/"WEEK_LOG_TOMCAT_`date +"%Y-%m-%d"`".tar.gz 2>> /opt/log/week_error.`date +"%Y-%m-%d"`.log
        	echo -e ">>>>> Give Apache rights on the archives(tomcat) : -----------------------------------    : "$GREEN"OK" "$NORMAL"
	fi
}

### Function to delete the daily and weekly archives
delete_archive()
{
        if [ "$1" == "days" ]
        then
		find $dirdaysarchives/ -mtime +10 -exec rm -f DAY_LOG_* \; 2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
		echo -e ">>>>> Delete archives > 10 days : ---------------------------------------------------    : "$GREEN"OK" "$NORMAL"
	else
		find $dirweekssarchives/ -mtime +37 -exec rm -f WEEK_LOG_* \; 2>> /opt/log/week_error.`date +"%Y-%m-%d"`.log
	        echo -e ">>>>> Delete archives > 37 days : ----------------------------------------------------    : "$GREEN"OK" "$NORMAL"
	fi
}

### function to send a message in case of error
send_mail_check()
{
        echo -e ">>>>> $1 : $2 : --------------------------------------    : "$RED"NOT OK" "$NORMAL"
        echo ">>>>> E-mail send dest : "$mail_alerte
        echo ">>>>> $1 : $2 " | mail -s "ALERTE : SCRIPT LOGS APACHE-TOMCAT" $mail_alerte
        exit 1
}

### Checking the existence of archives
check_exist_archive()
{
	if [ "$1" == "days" ]
        then
		echo ">>>>> Checking archive day APACHE2 :"
		cd $dirdaysarchives_apache
		if [ ! -e "DAY_LOG_APACHE_`date +"%Y-%m-%d"`.tar.gz" ]
   		then
			send_mail_check apache2 "DAY_LOG_APACHE_`date +"%Y-%m-%d"`.tar.gz"
		else
			echo -e ">>>>> Apache2: Day_Archives.tar.gz : ------------------------------------------------    : "$GREEN"OK" "$NORMAL"
		fi
		echo
		echo ">>>>> Checking archive day TOMCAT :"
		cd $dirdaysarchives_tomcat
        	if [ ! -e "DAY_LOG_TOMCAT_`date +"%Y-%m-%d"`.tar.gz" ]
        	then
			send_mail_check tomcat "DAY_LOG_TOMCAT_`date +"%Y-%m-%d"`.tar.gz"
        	else
			echo -e ">>>>> Tomcat: Day_Archives.tar.gz : --------------------------------------------------   : "$GREEN"OK" "$NORMAL"
        	fi
	else
        	echo ">>>>> Checking archive week APACHE2 :"
        	cd $dirweeksarchives_apache
        	if [ ! -e "WEEK_LOG_APACHE_`date +"%Y-%m-%d"`.tar.gz" ]
        	then 
        	        send_mail_check apache2 "WEEK_LOG_APACHE_`date +"%Y-%m-%d"`.tar.gz"
        	else 
        	        echo -e ">>>>> Apache2: Week_Archives.tar.gz : ------------------------------------------------    : "$GREEN"OK" "$NORMAL"
        	fi
        	echo    
        	echo ">>>>> Checking archive week TOMCAT :"
        	cd $dirweeksarchives_tomcat
        	if [ ! -e "WEEK_LOG_TOMCAT_`date +"%Y-%m-%d"`.tar.gz" ]
        	then 
        	        send_mail_check tomcat "WEEK_LOG_TOMCAT_`date +"%Y-%m-%d"`.tar.gz"
        	else 
        	        echo -e ">>>>> Tomcat: Week_Archives.tar.gz : --------------------------------------------------   : "$GREEN"OK" "$NORMAL"
        	fi
	fi
}

### Check whether the log error file is empty
check_file_error()
{
        cd $dirlog
	echo ">>>>> Checking errors or success :"
	if [ "$1" == "days" ]
        then
		if [ ! -s "day_error.`date +"%Y-%m-%d"`.log" ]
		then
		       rm "day_error.`date +"%Y-%m-%d"`.log"
		       echo -e "$GREEN" ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SUCCESS" "$NORMAL"
		else
        	       send_mail_check "DAYS" ">>>>> See /opt/log/day_error.`date +"%Y-%m-%d"`.log" 
		fi
	else
	        if [ ! -s "week_error.`date +"%Y-%m-%d"`.log" ]
	        then
	               rm "week_error.`date +"%Y-%m-%d"`.log"
	               echo -e "$GREEN" ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> SUCCESS""$NORMAL"
 	        else
         	       send_mail_check "WEEKS" "See /opt/log/week_error.`date +"%Y-%m-%d"`.log" 
        	fi
	fi
}

### Function to start apache2 and tomcat services
start_services()
{
        service apache2 start 2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
        echo -e "Service APACHE2 is : ----------------------------------------------------------------- : "$GREEN"Running" "$NORMAL"
        service tomcat8 start 2>> /opt/log/day_error.`date +"%Y-%m-%d"`.log
        echo -e "Service TOMCAT is : ------------------------------------------------------------------ : "$GREEN"Running" "$NORMAL"
}

head()
{
	echo
        echo  "    -------------- BACKUP: Backup logs Apache2/Tomcat ------------ "
        echo  "   |             	vdbnicolas@gmail.com                     |"
        echo  "    -------------------------------------------------------------- "
        echo
        echo
        echo -e "$(date)  ====>  \c"
        echo "DEBUT DE SCRIPT : "
        echo 
}


end()
{
        echo
        echo -e "$(date)  ====>  \c"
        echo "FIN DE SCRIPT "
        echo
        echo -e "$BLUE" '-------------------------------------------------'
        echo -e "$BLUE" '|                                                |'
        echo -e "$BLUE" '|  access backUP : http://localhost/archives/    |'
        echo -e "$BLUE" '|                                                |'
        echo -e "$BLUE" '-------------------------------------------------' "$NORMAL"
	echo
}

## FONCTION MAIN
## DAY
if [ "$1" == "days" ]
then
	head
	stop_services
	echo
	echo '########################################################################################'
	echo	
	archive_apache "$1"
	echo
        echo '########################################################################################'
        echo
	archive_tomcat "$1"
	echo
	echo '########################################################################################'
	echo	
	delete_archive "$1"
	echo
	echo '########################################################################################'
	echo
	check_exist_archive "$1"
	echo
	echo '########################################################################################'
	echo
	start_services
	echo
	echo '########################################################################################'
	echo
	check_file_error "$1"
	end
## WEEK
elif [ "$1" == "weeks" ]; then
	head
	archive_apache "$1"
	echo
	echo '########################################################################################'
	echo
	archive_tomcat "$1"
	echo
	echo '########################################################################################'
	echo
	delete_archive "$1"
	echo
	echo '########################################################################################'
	echo
	check_exist_archive "$1"
        echo
        echo '########################################################################################'
        echo
	check_file_error "$1"
	end
elif [ "$1" == "--help" ]; then
	echo ''
	echo '#########################################'
        echo '# SCRIPT BACKUP LOGS APACHE 2 & TOMCATS #'
        echo '# BACKUP DAY ONLY                       #'
        echo '#########################################'
	echo ''
        echo '#########################################################################################################'
	echo '# FIRST LAUNCH'
        echo '#########################################################################################################'
	echo ''
        echo '- Install APACHE2'
        echo '- Install TOMCAT8'
	echo ''
        echo '- recover script archive :'
        echo '- unzip the archive /opt :'
        echo '	/opt/backup.sh'
        echo '	/opt/log/'
	echo '	/opt/tmp'
        echo '	/opt/tmp/backup/'
        echo '	/opt/tmp/backup/apache/'
        echo '	/opt/tmp/backup/tomcat/'
        echo ''
        echo '- Setting up the environment (Commande SHELL):'
        echo '	mkdir /var/www/html/archives'
        echo '	mkdir /var/www/html/archives/days/apache2'
        echo '	mkdir /var/www/html/archives/days/tomcat'
        echo '	mkdir /var/www/html/archives/weeks/tomcat'
        echo '	mkdir /var/www/html/archives/weeks/apache2'
        echo '	chown -R www-data:www-data /var/www/html/archives/'
	echo ''
        echo '- Scheduled :'
        echo 'vi /etc/crontab'
        echo 'Add the lines :'
        echo '        # daily backup 00h30 everyday'
        echo '        0  30  *  *  *  root  /bin/bash /opt/backup.sh days >> /opt/log/backup.log'
        echo '        # Weekly backup 1h00 every Sunday'
        echo '        0  1   *  *  7  root  /bin/bash /opt/backup.sh weeks >> /opt/log/backup.log'
	echo
        echo '- Protect access to backup with an htaccess :'
        echo '        /var/www/html/archives/.htaccess'
        echo '        /var/www/html/archives/.htpasswd'
	echo ''
        echo '--------------------------------------------------------------'
        echo '|                                                            |'
        echo '|  Defaut                                                    |'
        echo '|  url :           http://localhost/archives                 |'
        echo '|  user :          .htaccess                                 |'
        echo '|  password :      .htaccess                                 |'
        echo '|                                                            |'
        echo '--------------------------------------------------------------'
	echo ''
## OTHER
else
	echo
        echo -e "$BLUE" '---------------------------------------------------------'
        echo -e "$BLUE" '|                                                       |'
        echo -e "$NORMAL" '|  Please specify if backup is  daily or weekly :       |'
        echo -e "$BLUE" '|                                                       |'
        echo -e "$BLUE" '|           bash '$dirscript'/backup.sh days                    |'
        echo -e "$BLUE" '|                      or                               |'
        echo -e "$BLUE" '|           bash '$dirscript'/backup.sh weeks                   |'
        echo -e "$BLUE" '|                                                       |'
        echo -e "$RED" '|    COMMAND HELP : bash '$dirscript'/backup.sh --help          |'
        echo -e "$BLUE" '|                                                       |'
        echo -e "$BLUE" '---------------------------------------------------------' "$NORMAL"
	echo
fi
exit 0
