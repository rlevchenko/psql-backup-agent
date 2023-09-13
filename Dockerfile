#-----------------------------------------------------------
# Dockerfile | rlevchenko.com
# PROVIDED WITHOUT WARRANTY OF ANY KIND
#-----------------------------------------------------------

FROM alpine:3.16.2
LABEL AUTHOR="Roman Levchenko"
LABEL WEBSITE="rlevchenko.com"
RUN mkdir /etc/periodic/custom \
    && mkdir -p /backup/config \ 
    && touch /var/log/cron.log \
    && apk --no-cache add \
    postgresql14-client=14.9-r0 \
    bash=5.1.16-r2
COPY /config/cronfile /etc/crontabs/root
COPY /config/psql_backup.sh /etc/periodic/custom/backup
COPY ["/config/psql_backup.sh","/config/passfile","/backup/config/"]
RUN chmod 755 /etc/periodic/custom/backup \
    && chmod 0600 /backup/config/passfile
CMD ["-f","-l","8", "-L", "/dev/stdout"]
ENTRYPOINT ["crond"]