# A simple PostgreSQL backup agent
## Description

Dockerized cron job to backup PostgreSQL database or multiple databases on different hosts. Based on Alpine docker image, so the image is about 11 Mb. The script can be also used without docker or docker compose. However, my recommendation is to run docker container on your backup host to provide a kind of isolation. 

Blog post is [here](https://rlevchenko.com/2022/11/05/simple-postgresql-backup-agent/).

The script or "agent" does the following:

- Reads content of /config/passfile to get pg_dump connection parameters
- Creates arrays for each connection parameter (hostnames -> array1 and so on)
- Verifies if the backup can be done by executing a dry run
- If a dry run is ok, produces backup archive and compress it with gzip
- Cleans up the storage folder. Files older than 30 days are deleted
- Redirects all cron job statuses to stdout
- Keeps backup files under ./psql/backups/{hostname}/{dbname}/ on your host

Current limitations: 

- no encryption for specific databases (in to-do list)
- no handling of wildcars in passfile (in to-do list)

## Content

- Dockerfile - describes docker image
- docker-compose.yml - docker compose file to build and run agent service
- /config/cronfile - cron job schedule settings
- /config/passfile - PostgreSQL .pgpass actually
- /config/psql_backup.sh - the script itself

## Steps to run the agent

- check out the passfile and provide your own connection paramaters 
- verify the cron job settings in the /config/cronfile (twice a day, at 8:30 and 20:30 UTC by default)
- edit dockerfile/docker-compose.yml or script itself if necessary 
- run *docker compose build* 
- run *docker compose up -d*
- check out the stoud of the container to get the job's status

## Result

![Agent Output](https://rlevchenko.files.wordpress.com/2022/11/image_2022-11-05_125314308.png)
