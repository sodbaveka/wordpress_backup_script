#!/bin/bash

# Bash script to automate the restoration of a wordpress website

# Copyright: (c) 2021, Mickaël Duchet <sodbaveka@gmail.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)


# Debug mode
#set -x

# Variables
NOW=$(date +"%Y-%m-%d-%H%M")
destination_folder_path="/home/theseus/wpbackup"
source_folder_path="/home/wpsftp/wpbackup"
user_login="theseus"
ftp_server="srv-sftp-01"
log_file="/home/$user_login/wprestore.log"

# MySQL Settings
mysqlpassword="theseus"
mysql_db="WordPress"
mysql_user="theseus"
mysql_password="theseus"

# Log file
touch "$log_file" && echo "log file created"
echo "#######################################################################################################################" >> $log_file 2>&1
echo "Début d'exécution du script le" $NOW >> $log_file 2>&1
echo "***********************************************************************************************************************" >> $log_file 2>&1

echo "Début d'exécution du script le" $NOW

# Creating the backup folder
mkdir $destination_folder_path >> $log_file 2>&1

# Retrieving the names of the files to copy
ssh  -i /home/"$user_login"/.ssh/id_rsa $user_login@$ftp_server << EOF
cd /home/wpsftp/wpbackup
find -maxdepth 1 -name "*.sql.gz" -type f | xargs -x ls -tr | awk "NR>1" | xargs -L1 basename > .temp_file.tmp
find -maxdepth 1 -name "*.tar.gz" -type f | xargs -x ls -tr | awk "NR>1" | xargs -L1 basename >> .temp_file.tmp
EOF

cd $destination_folder_path
scp -i /home/"$user_login"/.ssh/id_rsa $user_login@$ftp_server:"$source_folder_path"/.temp_file.tmp .temp_file.tmp >> $log_file 2>&1 && echo "list of files to download copied"

# Downloading files from ftp server with secure connection
while read ligne
do 		
	sftp  -i /home/"$user_login"/.ssh/id_rsa $user_login@$ftp_server:"$source_folder_path"/"$ligne"
done < .temp_file.tmp 2>&1 && echo "All downloads executed" 

# # Restoring wordpress database
read db_backup_name < <(cat .temp_file.tmp | sed -n '1 p') >> $log_file 2>&1
gunzip -f $db_backup_name >> $log_file 2>&1 && echo "$db_backup_name décompressé" 
read db_backup_name < <(find -maxdepth 1 -name "*.sql" -type f | xargs -L1 basename) >> $log_file 2>&1
mysql --user="$mysql_user" --password="$mysql_password" "$mysql_db" < "$db_backup_name" >> $log_file 2>&1 && echo "database restored" 
rm $db_backup_name >> $log_file 2>&1

# Restoring wordpress files & deleting backup files
read files_backup_name < <(cat .temp_file.tmp | sed -n '2 p') >> $log_file 2>&1
tar -xzf $files_backup_name >> $log_file 2>&1 && echo "$files_backup_name décompressé"
rm $files_backup_name >> $log_file 2>&1
cp -rf wordpress /var/www/sodbaveka/ >> $log_file 2>&1 && echo "website restored" 
rm -fr wordpress >> $log_file 2>&1
rm .temp_file.tmp >> $log_file 2>&1

# Log message
echo "***********************************************************************************************************************" >> $log_file 2>&1
echo "Fin d'exécution du script le" $NOW >> $log_file 2>&1
echo "#######################################################################################################################" >> $log_file 2>&1