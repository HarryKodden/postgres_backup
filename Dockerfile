FROM webdevops/go-crond:master-alpine

ENV POSTGRES_DATABASE **None**
ENV POSTGRES_BACKUP_ALL **None**
ENV POSTGRES_HOST **None**
ENV POSTGRES_PORT 5432
ENV POSTGRES_USER **None**
ENV POSTGRES_PASSWORD **None**
ENV POSTGRES_EXTRA_OPTS ''
ENV SCHEDULE **None**

ADD run.sh run.sh
ADD backup.sh backup.sh

VOLUME /backups

ENTRYPOINT []
CMD ["sh", "run.sh"]