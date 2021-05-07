#!/bin/bash

# Variables
NOW=$(date +"%Y-%m-%d-%H%M")
destination_folder_path="/home/theseus/wpbackup"
source_folder_path="/home/wpsftp/wpbackup"
user_login="theseus"
ftp_server="srv-sftp-01"

# MySQL Settings
mysqlpassword="theseus"
mysql_db="WordPress"
mysql_user="theseus"
mysql_password="theseus"

# Creating the backup folder
mkdir $destination_folder_path 2> /dev/null

# Retrieving the names of the files to copy
ssh  -i ~/.ssh/id_ecdsa $user_login@$ftp_server '
cd /home/wpsftp/wpbackup
find -maxdepth 1 -name "*.sql.gz" -type f | xargs -x ls -tr | awk "NR>1" | xargs -L1 basename > .temp_file.tmp
find -maxdepth 1 -name "*.tar.gz" -type f | xargs -x ls -tr | awk "NR>1" | xargs -L1 basename >> .temp_file.tmp
'

cd $destination_folder_path
scp  -i ~/.ssh/id_ecdsa $user_login@$ftp_server:"$source_folder_path"/.temp_file.tmp .temp_file.tmp && echo "list of files to download copied"

# Downloading files from ftp server with secure connection
while read ligne
do 		
	sftp  -i ~/.ssh/id_ecdsa $user_login@$ftp_server:"$source_folder_path"/"$ligne"
done < .temp_file.tmp && echo "All downloads executed"

# # Restoring wordpress database
read db_backup_name < <(cat .temp_file.tmp | sed -n '1 p')
gunzip -f $db_backup_name && echo "$db_backup_name décompressé"
read db_backup_name < <(find -maxdepth 1 -name "*.sql" -type f | xargs -L1 basename)
mysql --user="$mysql_user" --password="$mysql_password" "$mysql_db" < "$db_backup_name" && echo "database restored"
rm $db_backup_name

# Restoring wordpress files & deleting backup files
read files_backup_name < <(cat .temp_file.tmp | sed -n '2 p')
tar -xzf $files_backup_name && echo "$files_backup_name décompressé"
rm $files_backup_name
cp -rf wordpress /var/www/sodbaveka/ && echo "website restored"
rm -fr wordpress
rm .temp_file.tmp





