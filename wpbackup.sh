#!/bin/bash

# Bash script to automate the backup of a wordpress website

# Copyright: (c) 2021, Mickaël Duchet <sodbaveka@gmail.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)


# Debug mode
#set -x 

# Variables.
NOW=$(date +"%Y-%m-%d-%H%M")
db_backup_name="wp-db-backup-$NOW.sql.gz"
wpfiles_backup_name="wp-files-backup-$NOW.tar.gz"
WWW_TRANSFORM='s,^var/www/sodbaveka/wordpress,wordpress,'
user_login="theseus"
ftp_server="srv-sftp-01"
log_file="/home/$user_login/wpbackup.log"

# Path to my backup folder.
backup_folder_path="/home/theseus/wp_backup"
inc_backup_folder_dest="/home/theseus/inc_wp_backup"

# Path to my WordPress website
wp_folder="/var/www/sodbaveka/wordpress"

# Database connection info.
db_name="WordPress"
db_username="theseus"
db_password="theseus"

# Log file
touch "$log_file" && echo "log file created"
echo "#######################################################################################################################" > $log_file 2>&1
echo "Début d'exécution du script le" $NOW >> $log_file 2>&1
echo "***********************************************************************************************************************" >> $log_file 2>&1

echo "Début d'exécution du script le" $NOW

mkdir "$backup_folder_path" >> $log_file 2>&1

# Backup MYSQL database, gzip it and send to backup folder.
mysqldump --opt -u$db_username  -p$db_password $db_name | gzip > $backup_folder_path/$db_backup_name && echo "dump mysql OK" 

# Create a tarball of the wordpress files, gzip it and send to backup folder.
tar -czf $backup_folder_path/$wpfiles_backup_name --transform $WWW_TRANSFORM $wp_folder >> $log_file 2>&1 && echo "tar archive OK"

# Delete all but 2 recent wordpress database back-ups (files having .sql.gz extension) in backup folder.
find $backup_folder_path -maxdepth 1 -name "*.sql.gz" -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm >> $log_file 2>&1

# Delete all but 2 recent wordpress files back-ups (files having .tar.gz extension) in backup folder.
find $backup_folder_path -maxdepth 1 -name "*.tar.gz" -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm >> $log_file 2>&1

# Full copy to ftp server with secure connection
cd /home/theseus/wp_backup
sftp  -i /home/"$user_login"/.ssh/id_rsa $user_login@$ftp_server << EOF
cd /home/wpsftp/wpbackup
pwd
put *.*
EOF

# An incremental backup of wordpress files...just for fun ;-)
rsync -az --stats -e ssh -i /home/"$user_login"/.ssh/id_rsa $wp_folder $user_login@$ftp_server:$inc_backup_folder_dest >> $log_file 2>&1
status=$?
echo '***'
echo "rsync return (0 if success; other if error) : " $status  >> $log_file 2>&1

# Rotation of backups to avoid an accumulation of backup files
ssh -i /home/"$user_login"/.ssh/id_rsa $user_login@$ftp_server << EOF
cd /home/wpsftp/wpbackup
find /home/wpsftp/wpbackup -maxdepth 1 -name '*.sql.gz' -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm 2>> /dev/null
find /home/wpsftp/wpbackup -maxdepth 1 -name '*.tar.gz' -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm 2>> /dev/null
EOF

# Log message
echo "***********************************************************************************************************************" >> $log_file 2>&1
echo "Fin d'exécution du script le" $NOW >> $log_file 2>&1
echo "#######################################################################################################################" >> $log_file 2>&1
