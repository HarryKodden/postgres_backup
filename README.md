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

### Environment Variables

Most variables are the same as in the [official postgres image](https://hub.docker.com/_/postgres/).

| env variable | description |
|--|--|
| BACKUP_DIR | Directory to save the backup at. Defaults to `/backups`. |
| BACKUP_KEEP_DAYS | Number of daily backups to keep before removal. Defaults to `7`. |
| BACKUP_KEEP_WEEKS | Number of weekly backups to keep before removal. Defaults to `4`. |
| BACKUP_KEEP_MONTHS | Number of monthly backups to keep before removal. Defaults to `6`. |
| BACKUP_KEEP_MINS | Number of minutes for `last` folder backups to keep before removal. Defaults to `1440`. |
| POSTGRES_DB | Comma or space separated list of postgres databases to backup. Required. |
| POSTGRES_EXTRA_OPTS | Additional [options](https://www.postgresql.org/docs/12/app-pgdump.html#PG-DUMP-OPTIONS) for `pg_dump` (or `pg_dumpall` [options](https://www.postgresql.org/docs/12/app-pg-dumpall.html#id-1.9.4.13.6) if POSTGRES_CLUSTER is set). Defaults to `-Z6`. |
| POSTGRES_HOST | Postgres connection parameter; postgres host to connect to. Required. |
| POSTGRES_PASSWORD | Postgres connection parameter; postgres password to connect with. Required. |
| POSTGRES_PORT | Postgres connection parameter; postgres port to connect to. Defaults to `5432`. |
| POSTGRES_USER | Postgres connection parameter; postgres user to connect with. Required. |
| SCHEDULE | [Cron-schedule](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules) specifying the interval between postgres backups. Defaults to `@daily`. |


### How the backups folder works?

First a new backup is created in the `last` folder with the full time.

Once this backup finish succefully then, it is hard linked (instead of coping to avoid use more space) to the rest of the folders (daily, weekly and monthly). This step replaces the old backups for that category storing always only the latest for each category (so the monthly backup for a month is always storing the latest for that month and not the first).

So the backup folder are structured as follows:

* `BACKUP_DIR/last/DB-YYYYMMDD-HHmmss.sql.gz`: all the backups are stored separatly in this folder.
* `BACKUP_DIR/daily/DB-YYYYMMDD.sql.gz`: always store (hard link) the **latest** backup of that day.
* `BACKUP_DIR/weekly/DB-YYYYww.sql.gz`: always store (hard link) the **latest** backup of that week (the last day of the week will be Sunday as it uses ISO week numbers).
* `BACKUP_DIR/monthly/DB-YYYYMM.sql.gz`: always store (hard link) the **latest** backup of that month (normally the ~31st).

And the following symlinks are also updated after each successfull backup for simlicity:

```
BACKUP_DIR/last/DB-latest.sql.gz -> BACKUP_DIR/last/DB-YYYYMMDD-HHmmss.sql.gz
BACKUP_DIR/daily/DB-latest.sql.gz -> BACKUP_DIR/daily/DB-YYYYMMDD.sql.gz
BACKUP_DIR/weekly/DB-latest.sql.gz -> BACKUP_DIR/weekly/DB-YYYYww.sql.gz
BACKUP_DIR/monthly/DB-latest.sql.gz -> BACKUP_DIR/monthly/DB-YYYYMM.sql.gz
```

For **cleaning** the script removes the files for each category only if the new backup has been successfull.
To do so it is using the following independent variables:

* BACKUP_KEEP_MINS: will remove files from the `last` folder that are older than its value in minutes after a new successfull backup without affecting the rest of the backups (because they are hard links).
* BACKUP_KEEP_DAYS: will remove files from the `daily` folder that are older than its value in days after a new successfull backup.
* BACKUP_KEEP_WEEKS: will remove files from the `weekly` folder that are older than its value in weeks after a new successfull backup (remember that it starts counting from the end of each week not the beggining).
* BACKUP_KEEP_MONTHS: will remove files from the `monthly` folder that are older than its value in months (of 31 days) after a new successfull backup (remember that it starts counting from the end of each month not the beggining).