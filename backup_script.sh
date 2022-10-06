#!bin/bash



#################################################################
#																#
#			HOME DIRECTORY BACKUP AND RESTORE SCRIPT			#
#			    	by Tom Horton - 6/10/22				        # 
#																#
#################################################################
#	This script will backup a specified users home directory	#
#	as tar.gz format. it will also delete and restore home		#
#	directory from backup. backups are located in the users		#
#	home folder at /home/backups, and are timestamped. backups	#
#	folder is not included in backup/delete/restore operations.	#
#	Script must be run by system admin and requires admin 		#
#	admin permissions, but does not contain any SUDO commands.	#
#################################################################



###					###
#	HELPER FUNCTIONS  #
###					###



#compress home folder as tar.gz and move to /home/backups
#create Backups directory if it doesnt exist
create_backup () {

#Generate timestamp
local time="$(date +"%Y-%m-%d--%H-%M-%S")"
echo "timestamp: $time"
sleep 1.5

#generate filename
local filename="$user-BACKUP-$time.tar.gz"
echo "filename: $filename"
sleep 1.5

#create backup dir
if [ ! -d "/home/$user/Backups" ]; then 
	echo "backup directory not found!"
	echo "creating backup directory..."
	sleep 1.5
	mkdir /home/$user/Backups
fi

#compress
echo "beginning compression..."
sleep 2.5
tar czvf /home/$user/Backups/$filename --exclude=Backups /home/$user
echo "DONE"
sleep 5
}



#remove all data in home directory then restore backup
#DOES NOT DELETE /home/backups FOLDER
#DOES NOT DELETE ANYTHING if no backup folder or backup files are present
restore_backup () {

while [ $option = "100" ]
do
	clear
	
	#Check for backup folder
	if [ -d "/home/$user/Backups" ]; then
	
		#check that /user/backups contains a backup file
		backups_available=$(ls /home/$user/Backups | grep -c "BACKUP")
		if [ $backups_available -ge 1 ]; then
			echo "============================"
			echo "    BACKUPS AVALIABLE"
			echo "----------------------------"
			ls /home/$user/Backups
			echo "============================"
			read -p "Enter a backup to restore: " restore
			
			#find selected backup
			echo "finding backup..."
			sleep 1.5
			local filename=$( ls /home/$user/Backups | grep $restore )	
			if [ -n "$filename" ]; then
			
				#delete current home folder
				echo "deleting current home folder contents"
				sleep 2.5
				find /home/$user -mindepth 1 -not -regex "/home/$user/Backups.*" -delete
				
				#restore backup
				echo "decompressing and restoring backup"
				sleep 2
				tar xvzf /home/$user/Backups/$filename -C /
					
				echo "DONE"
				sleep 5
				option="null"
			else
				echo "NO BACKUP FILE \"$restore_timestamp\" FOUND! Try again"
				sleep 5
			fi
		else
			echo "user $user has no backups available!"
			sleep 5
			option="null"
		fi	
	else
		echo "NO BACKUP FOLDER FOUND! OPERATION ABORTED"
		sleep 5
		option="null"
	fi
done		
}



###					###
# 	MAIN SCRIPT BODY  #
###					###



option="null"
while [ $option != "5" ]
do			
	
	#MAIN MENU
	clear
	echo "============================"
	echo "   automated script menu"
	echo "============================"
	echo "[1] Backup user home folder"
	echo "[2] Restore user home folder"
	echo "[5] Quit"
	echo "============================"
	read -p "select an option (1-5): " option
	
	
	#CREATE BACKUP
	if [ $option = "1" ]; then
		while [ $option = "1" ]
		do
			clear
			echo "============================"
			echo "       CREATE BACKUP"
			echo "============================"
			read -p "Enter a username to create a backup: " user
		
		
			#Check if user exists
			user_formatted="^$user:"
			exists=$(grep -c $user_formatted /etc/passwd)
			if [ $exists -eq 1 ]; then
				clear
				option="null"
				echo "Starting Backup..."
				sleep 1.5
				
				#Run create backup func
				create_backup
				
			elif [ $exists -eq 0 ]; then
				echo "user $user does not exist, try again"
				sleep 5
			else
				echo "error. try again."
				sleep 5
			fi
		done
		
			
	#RESTORE BACKUP
	elif [ $option = "2" ]; then
		while [ $option = "2" ]
		do
			clear
			echo "============================"
			echo "      RESTORE BACKUP"
			echo "============================"
			read -p "Enter a username to restore their backup: " user
		
		
			#Check if user exists
			user_formatted="^$user:"
			exists=$(grep -c $user_formatted /etc/passwd)
			if [ $exists -eq 1 ]; then
				option="100"
				
				#run restore backup func
				restore_backup
							
			elif [ $exists -eq 0 ]; then
				echo "user $user does not exist, try again"
				sleep 5
			else
				echo "error. try again."
				sleep 5
			fi
		done
	
	
	#EXIT SCRIPT
	elif [ $option = "5" ]; then
		echo "goodbye"
		sleep 1
	
	else
		clear
		echo "not a valid option!"
		sleep 4
	fi
done


