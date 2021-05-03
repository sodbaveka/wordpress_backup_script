#!/bin/bash

# ssh -t $1@$2 '
# testfunction()
# {
# 	sudo touch ~/test02.txt && echo "Sauvegarde du fichier de configuration effectuée";
# }

# addstudent()
# {
#         sudo groupadd students 2>> /var/log/newscriptlog.txt;
# 	student="student-$id1-$id2";
# 	sudo useradd --create-home --groups students --shell /bin/bash $student 2>> /var/log/newscriptlog.txt && password='password' && sudo echo -e "$student:$password\n$student:$password" | sudo chpasswd && echo "Nouvel utilisateur $student créé";
# }

# addsoftwares()
# {
# 	sudo apt-get update;
# 	sudo apt-get install -y -qq vlc libreoffice sudo smbclient cifs-utils;
# }

# mountdata()
# {
# 	sudo mkdir -p /mnt/sambaShared && echo "Répertoire /mnt/sambaShared créé";
# 	sudo chown invite:invite /mnt/sambaShared;
# 	sudo chmod -R 777 /mnt/sambaShared;
# 	sudo mount -t cifs -o rw,guest //192.168.0.2/shared /mnt/sambaShared && echo "Partage effectué";
# }

# sudo touch /var/log/wpbackuplog.txt;
# sudo chmod 766 /var/log/wpbackuplog.txt;
# testfunction;

# '
touch /var/log/wpbackuplog.txt;
chmod 766 /var/log/wpbackuplog.txt;
echo "test ok"