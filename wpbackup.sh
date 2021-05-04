#!/bin/bash

# my backups will use these filenames.
NOW=$(date +"%Y-%m-%d-%H%M")
db_backup_name="wp-db-backup-$NOW.sql.gz"
wpfiles_backup_name="wp-files-backup-$NOW.tar.gz"
WWW_TRANSFORM='s,^var/www/wordpress,wordpress,'

# path to my backup folder.
backup_folder_path="/home/theseus/wp_backup"

# path to my WordPress website
wp_folder="/var/www/wordpress"

# database connection info.
db_name="WordPress"
db_username="theseus"
db_password="theseus"

# log
log_file_name="/var/log/wpbackuplog.txt"
sudo touch $log_file_name;
sudo chmod 766 $log_file_name;
echo "Script exécuté le" $NOW

# backup MYSQL database, gzip it and send to backup folder.
mysqldump --opt -u$db_username  -p$db_password $db_name | gzip > $backup_folder_path/$db_backup_name 2>> $log_file_name

# create a tarball of the wordpress files, gzip it and send to backup folder.
tar -czf $backup_folder_path/$wpfiles_backup_name --transform $WWW_TRANSFORM $wp_folder 2>> $log_file_name

# delete all but 2 recent wordpress database back-ups (files having .sql.gz extension) in backup folder.
find $backup_folder_path -maxdepth 1 -name "*.sql.gz" -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm

# delete all but 2 recent wordpress files back-ups (files having .tar.gz extension) in backup folder.
find $backup_folder_path -maxdepth 1 -name "*.tar.gz" -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm

# Copy to ftp server with secure connection
cd /home/theseus/wp_backup
sftp wpsftp@srv-sftp-01 << EOF
cd wpbackup
pwd
put *.*
exit
EOF

# rotation of backups to avoid an accumulation of backup files
ssh -t theseus@srv-sftp-01 "
cd /home/wpsftp/wpbackup
find -maxdepth 1 -name '*.sql.gz' -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm
find -maxdepth 1 -name '*.tar.gz' -type f | xargs -x ls -t | awk 'NR>2' | xargs -L1 rm
"

# Task Scheduling: WordPress Backups with Crontab
# TO DO