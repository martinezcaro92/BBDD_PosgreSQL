\
#!/bin/bash
# 01-init.sh - Create application DB and user on first run
set -euo pipefail

echo ">> Waiting for Postgres to accept connections..."
# simple wait loop for service readiness
for i in {1..30}; do
  if pg_isready -U "${POSTGRES_USER}" > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

create_db_if_missing() {
  DB_NAME="$1"
  echo ">> Ensuring database \"$DB_NAME\" exists..."
  DB_EXISTS=$(psql -U "${POSTGRES_USER}" -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'")
  if [[ "${DB_EXISTS}" != "1" ]]; then
    psql -U "${POSTGRES_USER}" -v ON_ERROR_STOP=1 -c "CREATE DATABASE \"${DB_NAME}\";"
  fi
}

create_role_if_missing() {
  ROLE_NAME="$1"
  ROLE_PASS="$2"
  echo ">> Ensuring role \"$ROLE_NAME\" exists..."
  ROLE_EXISTS=$(psql -U "${POSTGRES_USER}" -tAc "SELECT 1 FROM pg_roles WHERE rolname='${ROLE_NAME}'")
  if [[ "${ROLE_EXISTS}" != "1" ]]; then
    psql -U "${POSTGRES_USER}" -v ON_ERROR_STOP=1 -c "CREATE ROLE \"${ROLE_NAME}\" LOGIN PASSWORD '${ROLE_PASS}';"
  fi
}

APP_DB="${APP_DB:-app_db}"
APP_USER="${APP_USER:-app_user}"
APP_PASSWORD="${APP_PASSWORD:-app_password}"

create_db_if_missing "${APP_DB}"
create_role_if_missing "${APP_USER}" "${APP_PASSWORD}"

echo ">> Granting privileges and setting ownership..."
psql -U "${POSTGRES_USER}" -v ON_ERROR_STOP=1 -c "ALTER DATABASE \"${APP_DB}\" OWNER TO \"${APP_USER}\";"
psql -U "${POSTGRES_USER}" -d "${APP_DB}" -v ON_ERROR_STOP=1 -c "GRANT ALL ON SCHEMA public TO \"${APP_USER}\";"

echo ">> Creating probe table..."
psql -U "${POSTGRES_USER}" -d "${APP_DB}" -v ON_ERROR_STOP=1 <<'EOSQL'
CREATE TABLE IF NOT EXISTS public._probe (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO public._probe DEFAULT VALUES;
EOSQL

echo ">> Initialization complete."
