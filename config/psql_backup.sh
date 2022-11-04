#! /bin/bash

# array with db names
# declare -a dbArray=(devdb qadb stagingdb proddb)

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

arrLength=${#dbArray[@]}


function create_dirs()
{
	for (( i=0; i<arrLength; i++ )); 
	do
		if ! [[ -d $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}" ]]; then
				echo -e "\n[INFO] Making a backup directory $BACKUP_DIR${hnArray[$i]}/${dbArray[$i]}"
				mkdir -p $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"
				else 
				echo -e "\n[INFO] Directory $BACKUP_DIR${hnArray[$i]}/${dbArray[$i]} exists. No need to create one"
		fi
	done
}

function make_backup()
{
for (( i=0; i<arrLength; i++ ));
	do
		echo -e "\n[INFO] Doing a backup of the database ${dbArray[$i]} "
		set -o pipefail -e
			if ! pg_dump -Fp -w -U "${userArray[$i]}" -h "${hnArray[$i]}" -p "${portArray[$i]}" -d "${dbArray[$i]}" | gzip > $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"/"$TIMESTAMP".sql.gz.temp; then
				echo "::::[ERROR] Failed to produce backup database ${dbArray[$i]}" 1>&2
			else
				mv $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"/"$TIMESTAMP".sql.gz.temp $BACKUP_DIR"${hnArray[$i]}"/"${dbArray[$i]}"/"$TIMESTAMP".sql.gz
                echo -e "\n::::[INFO] Backup for database ${dbArray[$i]} has been completed!"
			fi
		set +o pipefail +e
	done
}

function cleaner()
{
set -o pipefail -e
	if [[ -n $(find /backup/storage/ -name "*.sql.gz" -type f -mtime +30) ]]; then
		echo -e "\n[INFO] There are backup files older than 30 days. Cleaning up the following files:"
		find /backup/storage/ -name "*.sql.gz" -print -type f -mtime +30 -exec rm {} \;
	else 
		echo -e "\n[INFO] There are no backup files older than 30 days. \nHave a nice day!"
	fi
set +o pipefail +e
}

create_dirs
make_backup
cleaner


