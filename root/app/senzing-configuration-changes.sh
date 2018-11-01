#!/usr/bin/env bash
# Make changes to files based on Environment Variables.

VERSION=1.0.0

# A file used to determine if/when this program has previously run.

SENTINAL_FILE=/opt/senzing/docker-runs.log

# Return codes

OK=0
NOT_OK=1

# Short-circuit for certain commandline options.

if [ "$1" == "--version" ]; then
  echo "senzing-configuration-changes.sh version ${VERSION}"
  exit ${OK}
fi

# Make modifications based on SENZING_DATABASE_URL value.

if [ -z "${SENZING_DATABASE_URL}" ]; then
  echo "Using internal database"
else

  # Parse the SENZING_DATABASE_URL.

  PROTOCOL="$(echo ${SENZING_DATABASE_URL} | sed -e's,^\(.*://\).*,\1,g')"
  DRIVER="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f1)"
  UPPERCASE_DRIVER=$(echo "${DRIVER}" | tr '[:lower:]' '[:upper:]')
  USERNAME="$(echo ${SENZING_DATABASE_URL} | cut -d '/' -f3 | cut -d ':' -f1)"
  PASSWORD="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f3 | cut -d '@' -f1)"
  HOST="$(echo ${SENZING_DATABASE_URL} | cut -d '@' -f2 | cut -d ':' -f1)"
  PORT="$(echo ${SENZING_DATABASE_URL} | cut -d ':' -f4 | cut -d '/' -f1)"
  SCHEMA="$(echo ${SENZING_DATABASE_URL} | cut -d '/' -f4)"

  # Construct Senzing version of database URL.

  NEW_SENZING_DATABASE_URL="db2://${USERNAME}:${PASSWORD}@${SCHEMA}"

  # Modify files in docker's Union File System.

  echo "" >> /etc/odbcinst.ini  # Create a file if it is not there.
  sed -i.$(date +%s) \
    -e "\$a[${UPPERCASE_DRIVER}]\nDescription = Db2 ODBC Driver\nDriver = /opt/IBM/db2/clidriver/lib/libdb2o.so\nFileUsage = 1\ndontdlclose = 1\n" \
    /etc/odbcinst.ini

  sed -i.$(date +%s) \
    -e "s/{HOST}/${HOST}/" \
    -e "s/{PORT}/${PORT}/" \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    /etc/odbc.ini

  sed -i.$(date +%s) \
    -e "s/{HOST}/${HOST}/" \
    -e "s/{PORT}/${PORT}/" \
    -e "s/{SCHEMA}/${SCHEMA}/" \
    /opt/IBM/db2/clidriver/cfg/db2dsdriver.cfg

  # Modify files in mounted volume, if needed.  The "sentinal file" is created after first run.

  if [ ! -f ${SENTINAL_FILE} ]; then

    sed -i.$(date +%s) \
      -e "s|G2Connection=sqlite3://na:na@/opt/senzing/g2/sqldb/G2C.db|G2Connection=${NEW_SENZING_DATABASE_URL}|" \
      /opt/senzing/g2/python/G2Project.ini

    sed -i.$(date +%s) \
      -e "s|CONNECTION=sqlite3://na:na@/opt/senzing/g2/sqldb/G2C.db|CONNECTION=${NEW_SENZING_DATABASE_URL}|" \
      /opt/senzing/g2/python/G2Module.ini

  fi
fi

# Append to a "sentinal file" to indicate when this script has been run.
# The sentinal file is used to identify the first run from subsequent runs for "first-time" processing.

echo "$(date)" >> ${SENTINAL_FILE}

# Run the command specified by the parameters.

$@
