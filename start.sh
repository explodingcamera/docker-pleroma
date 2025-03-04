#!/bin/sh

PUID=${PUID:-1000}
PGID=${PGID:-1000}

groupmod -o -g "$PGID" pleroma
usermod -o -u "$PUID" pleroma

set -e

echo "
-------------------------------------
Pleroma Docker by explodingcamera
-------------------------------------
-------------------------------------
User:        $(whoami)    
User uid:    $(id -u pleroma)
User gid:    $(id -g pleroma)
-------------------------------------
"

if [ "$(stat -c %U:%G /app)" != "pleroma:pleroma" ]; then
    chown -R pleroma:pleroma /app
fi

if [ "$(stat -c %U:%G /data)" != "pleroma:pleroma" ]; then
    chown -R pleroma:pleroma /data
fi

echo "-- Waiting for database..."
while ! pg_isready -U ${DB_USER:-pleroma} -d postgres://${DB_HOST:-db}:${DB_PORT:-5432}/${DB_NAME:-pleroma} -t 1; do
    sleep 1s
done

echo "-- Running migrations..."
su-exec pleroma mix ecto.migrate

echo "-- Starting server..."
su-exec pleroma mix phx.server
