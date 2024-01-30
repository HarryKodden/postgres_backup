#! /bin/sh

set -eo pipefail

if [ "${SCHEDULE}" = "**None**" ]; then
  sh backup.sh
else
  echo -e "SHELL=/bin/sh\n${SCHEDULE} /bin/sh /backup.sh" > /etc/crontabs/root
  exec go-crond /etc/crontabs/root
fi