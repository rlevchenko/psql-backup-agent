#! /bin/bash

#-----------------------------------------------------------
# VERSION 1.0 | rlevchenko.com
# PROVIDED WITHOUT WARRANTY OF ANY KIND
#-----------------------------------------------------------

# set pgpassfile env variable
export PGPASSFILE="/backup/config/passfile"

#pg_dump param values

HOSTNAME=$(cut -d':' -f1 < $PGPASSFILE)
PORT=$(cut -d':' -f2 < $PGPASSFILE)
DBNAME=$(cut -d':' -f3 < $PGPASSFILE)
USERNAME=$(cut -d':' -f4 < $PGPASSFILE)
BACKUP_DIR="/backup/storage/"

# backup naming
TIMESTAMP=backup_$(date +%H)_$(date +"%d-%m-%Y")

# Creating arrays for each conn. property
readarray -t hnArray  < <(printf '%s' "$HOSTNAME")
readarray -t portArray < <(printf '%s' "$PORT")
readarray -t dbArray < <(printf '%s' "$DBNAME")
readarray -t userArray < <(printf '%s' "$USERNAME")

# Get one of the array length
arrLength=${#dbArray[@]}

# Let's beautify
function setcolors {
		OFF="\\e[1;0m"
        BOLD="\\e[1;1m"
        GREEN="${BOLD}\\e[1;32m"
        RED="${BOLD}\\e[1;31m"
}

# We need dirs to store backups
function create_dirs()
{
	for (( i=0; i<arrLength; i++ )); 
	do
		if ! [[ -d $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}" ]]; then
				echo -e "\n${GREEN}[INFO]${OFF} ${BOLD}Making a backup directory $BACKUP_DIR${hnArray[$i]}/${dbArray[$i]}${OFF}"
				mkdir -p $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"
				else 
				echo -e "\n${GREEN}[INFO]${OFF} ${BOLD}Directory $BACKUP_DIR${hnArray[$i]}/${dbArray[$i]} exists. No need to create one${OFF}"
		fi
	done
}

# Backup job
function make_backup()
{
for (( i=0; i<arrLength; i++ ));
	do
		echo -e "\n${GREEN}[INFO]${OFF} ${BOLD}Doing a backup of the database ${dbArray[$i]}${OFF} "
		set -o pipefail -e
			if ! pg_dump -Fp -w -U "${userArray[$i]}" -h "${hnArray[$i]}" -p "${portArray[$i]}" -d "${dbArray[$i]}" | gzip > $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"/"$TIMESTAMP".sql.gz.temp; then
				echo -e "${RED}::::[ERROR]${OFF} ${BOLD}Failed to produce backup database ${dbArray[$i]}${OFF}" 1>&2
				rm -f $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"/"$TIMESTAMP".sql.gz.temp
			else
				mv $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"/"$TIMESTAMP".sql.gz.temp $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"/"$TIMESTAMP".sql.gz
                echo -e "\n${GREEN}::::[INFO]${OFF} ${BOLD}Backup for database ${dbArray[$i]} has been completed!${OFF}"
			fi
		set +o pipefail +e
	done
}

# Clean old backup files
function cleaner()
{
set -o pipefail -e
	if [[ -n $(find /backup/storage/ -name "*.sql.gz" -type f -mtime +"$1") ]]; then
		echo -e "\n${GREEN}[INFO]${OFF} ${BOLD}There are backup files older than $1 days. Cleaning up the following files:${OFF}"
		find /backup/storage/ -name "*.sql.gz" -print -type f -mtime +"$1" -exec rm {} \;
	else 
		echo -e "\n${GREEN}[INFO]${OFF} ${BOLD}There are no backup files older than $1 days. \nHave a nice day!${OFF}"
	fi
set +o pipefail +e
}

setcolors
create_dirs
make_backup
cleaner "30" # if modified >30 days, do a clean


