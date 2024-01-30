# postgres-backup-local

Backup PostgresSQL to the local filesystem, based on [schickling/postgres-backup-s3](https://hub.docker.com/r/schickling/postgres-backup-s3/).

# postgres-backup

Backup PostgresSQL based on [schickling/postgres-backup-s3](https://hub.docker.com/r/schickling/postgres-backup-s3/).

## Usage

Docker:

```sh
$ docker run -e POSTGRES_DATABASE=dbname -e POSTGRES_USER=user -e POSTGRES_PASSWORD=password -e POSTGRES_HOST=localhost harrykodden/postgres-backup
```

Docker Compose:

```yaml
postgres:
  image: postgres
  environment:
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password

backup:
  image: harrykodden/postgres-backup
  depends_on:
    - postgres
  links:
    - postgres
  environment:
    SCHEDULE: "@daily"
    POSTGRES_BACKUP_ALL: "false"
    POSTGRES_HOST: host
    POSTGRES_DATABASE: dbname
    POSTGRES_USER: user
    POSTGRES_PASSWORD: password
    POSTGRES_EXTRA_OPTS: "--schema=public --blobs"
```

### Automatic Periodic Backups

You can additionally set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.

More information about the scheduling can be found [here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

### Backup File Name / Path

Backups will be stored in directory **/backups**, you can make a volume mount to this location to make the backup persistant to the location you desire.\

### Backup All Databases

You can backup all available databases by setting `POSTGRES_BACKUP_ALL="true"`.
