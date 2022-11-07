# A simple PostgreSQL backup agent
## Description

Dockerized cron job to backup PostgreSQL database or multiple databases on different hosts. Based on Alpine docker image, so the image is less than 11 Mb. The script can be also used without docker and docker compose or as a base for your own dockerized cron jobs. My general recommendation is to run docker container on your backup host to enable a kind of isolation from the management partition. 

The script or "agent" does the following:

- Reads content of /config/passfile to get pg_dump connection parameters
- Creates arrays for each connection parameter (hostnames -> array1 and so on)
- Verifies if the backup can be done by executing a dry run for each db
- If the dry run is completed and plain format set, produces plain-text sql script and compresses it with gzip
- If the dry run succeeds and custom format set, outputs a custom backup archive (more flexible and by default)
- Cleans up the storage folder. Backup archives older than 30 days are deleted
- Redirects all cron job statuses to stdout
- Keeps backup files under ./psql/backups/{hostname}/{dbname}/ on your host
- Default settings: twice a day at 8:30 and 20:30 UTC; custom format; clean backups older than 30 days

Current limitations: 

- no encryption for specific databases (in to-do list)
- no handling of wildcars in passfile (in to-do list)

Blog post is [here](https://rlevchenko.com/2022/11/05/simple-postgresql-backup-agent/).
## Content

- *Dockerfile* - describes docker image
- *docker-compose.yml* - docker compose file to build and run agent service
- */config/cronfile* - cron job schedule settings
- */config/passfile* - PostgreSQL .pgpass actually
- */config/psql_backup.sh* - the script itself

## Steps to run the agent

- check out the */config/passfile* and provide your own connection parameters 
- verify the cron job settings in the */config/cronfile* 
- change *make_backup* function argument to set format output (plain/custom)
- set *cleaner* function argument at the bottom of the script if necessary 
- edit dockerfile/docker-compose.yml if necessary
- run *docker compose build* 
- run *docker compose up -d*
- check out the stoud of the container to get the job's status
- TO RESTORE: use *psql* (if plain set) or *pg_restore* command (if custom format set)


## Result

![Agent Output](https://rlevchenko.files.wordpress.com/2022/11/image_2022-11-05_125314308.png)
