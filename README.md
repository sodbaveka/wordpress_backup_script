### Table of Contents
***
1. [General Info](#general-info)
2. [Technologies](#technologies)
3. [Installation](#installation)
4. [License](#License)
5. [Ressources](#Ressources)

### General Info
***
Hello World!

My name is Mickaël alias sodbaveka.
I created this repository as a lab to discover git, gitHub, Bash, Python and Ansible.

My project as a learner is to create bash scripts to automate the backup and restoration of a wordpress website.

The backup script takes care of :
- Creating the Files Archive and the MySQL Backup
- Cleaning Up & Compressing
- Uploading Backup Files to ftp server with secure connexion
- Uploading an incremental backup of wordpress files...useless...just for fun ;-)
- Cleaning up backups to avoid a build-up of backup files
(Do not forget to generate a key in RSA format to communicate between the web server and the ftp server)

The restore script takes care of :
- Creating the backup folder
- Retrieving the names of the files to copy
- Downloading files from ftp server with secure connection
- Restoring wordpress database
- Restoring wordpress files
(Do not forget to generate a key in RSA format to communicate between the web server and the ftp server)

Please feel free to message me if you have any questions.

Bye ;-)

### Technologies
***
A list of technologies used within the project :
* Linux Debian 10.8

### Installation
***
* Download :
```
$  git clone https://github.com/sodbaveka/wordpress_backup_script.git
```

* Launch :
```
$ cd ../path/to/the/file
$ ./wpbackup.sh
$ ./wprestore.sh
```

### License
***
* Copyright: (c) 2021, Mickaël Duchet <sodbaveka@gmail.com>
* GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

### Ressources
***
* 'bash and ssh for dummies’ :-p 
