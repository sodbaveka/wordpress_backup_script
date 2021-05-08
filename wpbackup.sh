#!/bin/bash

# Debug mode
#set -x 

# my backups will use these filenames.
NOW=$(date +"%Y-%m-%d-%H%M")
db_backup_name="wp-db-backup-$NOW.sql.gz"
wpfiles_backup_name="wp-files-backup-$NOW.tar.gz"
WWW_TRANSFORM='s,^var/www/sodbaveka/wordpress,wordpress,'
user_login="theseus"
ftp_server="srv-sftp-01"
log_file="/home/$user_login/wpbackup.log"

# path to my backup folder.
backup_folder_path="/home/theseus/wp_backup"

# path to my WordPress website
wp_folder="/var/www/sodbaveka/wordpress"

# database connection info.
db_name="WordPress"
db_username="theseus"
db_password="theseus"

# Log file
touch "$log_file" && echo "log file created"
echo "#######################################################################################################################" >> $log_file 2>&1
echo "Début d'exécution du script le" $NOW >> $log_file 2>&1
echo "***********************************************************************************************************************" >> $log_file 2>&1

echo "Début d'exécution du script le" $NOW

mkdir "$backup_folder_path" >> $log_file 2>&1

# backup MYSQL database, gzip it and send to backup folder.
mysqldump --opt -u$db_username  -p$db_password $db_name | gzip > $backup_folder_path/$db_backup_name && echo "dump mysql OK" 

# create a tarball of the wordpress files, gzip it and send to backup folder.
tar -czf $backup_folder_path/$wpfiles_backup_name --transform $WWW_TRANSFORM $wp_folder >> $log_file 2>&1 && echo "tar archive OK"

# delete all but 2 recent wordpress database back-ups (files having .sql.gz extension) in backup folder.
find $backup_folder_path -maxdepth 1 -name "*.sql.gz" -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm >> $log_file 2>&1

# delete all but 2 recent wordpress files back-ups (files having .tar.gz extension) in backup folder.
find $backup_folder_path -maxdepth 1 -name "*.tar.gz" -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm >> $log_file 2>&1

# Copy to ftp server with secure connection
cd /home/theseus/wp_backup
sftp  -i /home/"$user_login"/.ssh/id_rsa $user_login@$ftp_server << EOF
cd /home/wpsftp/wpbackup
pwd
put *.*
EOF

# rotation of backups to avoid an accumulation of backup files
ssh -i /home/"$user_login"/.ssh/id_rsa $user_login@$ftp_server << EOF
cd /home/wpsftp/wpbackup
find /home/wpsftp/wpbackup -maxdepth 1 -name '*.sql.gz' -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm 2>> /dev/null
find /home/wpsftp/wpbackup -maxdepth 1 -name '*.tar.gz' -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm 2>> /dev/null
EOF

# Log message
echo "***********************************************************************************************************************" >> $log_file 2>&1
echo "Fin d'exécution du script le" $NOW >> $log_file 2>&1
echo "#######################################################################################################################" >> $log_file 2>&1
