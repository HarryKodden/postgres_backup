#! /bin/sh

set -eo pipefail

#Initialize dirs
mkdir -p "${BACKUP_DIR}"

if [ "${POSTGRES_DATABASE}" = "**None**" -a "${POSTGRES_BACKUP_ALL}" != "true" ]; then
  echo "You need to set the POSTGRES_DATABASE environment variable."
  exit 1
fi

if [ "${POSTGRES_HOST}" = "**None**" ]; then
    echo "You need to set the POSTGRES_HOST environment variable."
    exit 1
fi

if [ "${POSTGRES_USER}" = "**None**" ]; then
  echo "You need to set the POSTGRES_USER environment variable."
  exit 1
fi

if [ "${POSTGRES_PASSWORD}" = "**None**" ]; then
  echo "You need to set the POSTGRES_PASSWORD environment variable or link to a container named POSTGRES."
  exit 1
fi

POSTGRES_HOST_OPTS="-h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER $POSTGRES_EXTRA_OPTS"
export PGPASSWORD=$POSTGRES_PASSWORD

if [ "${POSTGRES_BACKUP_ALL}" == "true" ]; then
  DEST_FILE=${BACKUP_DIR}/all_$(date +"%Y-%m-%dT%H:%M:%SZ").${BACKUP_SUFFIX}
  
  echo "Creating dump of all databases from ${POSTGRES_HOST}..."
  pg_dumpall ${POSTGRES_HOST_OPTS}  | gzip > ${DEST_FILE}

  echo "SQL full backup created: ${DEST_FILE}"
else
  for DB in ${POSTGRES_DATABASE}
  do
    DEST_FILE=${BACKUP_DIR}/${DB}_$(date +"%Y-%m-%dT%H:%M:%SZ").${BACKUP_SUFFIX}

    echo "Creating dump of ${DB} database from ${POSTGRES_HOST}..."
    pg_dump ${POSTGRES_HOST_OPTS} ${DB} | gzip > ${DEST_FILE}
    
    echo "Database ${DB} backup created: ${DEST_FILE}"
  done
fi