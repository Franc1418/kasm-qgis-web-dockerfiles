#!/bin/bash

# Fondo negro
xsetroot -solid "#1a1a1a" &

# --- INYECCIÓN DINÁMICA DE LA BASE DE DATOS ---
QGIS_DIR="/home/kasm-user/.local/share/QGIS/QGIS3/profiles/default/QGIS"
QGIS_INI="$QGIS_DIR/QGIS3.ini"

mkdir -p "$QGIS_DIR"

if [ -n "$DB_HOST" ]; then
    CONN_NAME="${DB_CONN_NAME:-BaseDeDatos}"
    DB_PORT="${DB_PORT:-5432}"

    if ! grep -q "$CONN_NAME" "$QGIS_INI" 2>/dev/null; then
        cat <<EOT >> "$QGIS_INI"

[PostgreSQL]
connections\\$CONN_NAME\\database=$DB_NAME
connections\\$CONN_NAME\\host=$DB_HOST
connections\\$CONN_NAME\\port=$DB_PORT
connections\\$CONN_NAME\\username=$DB_USER
connections\\$CONN_NAME\\password=$DB_PASSWORD
connections\\$CONN_NAME\\savePassword=true
connections\\$CONN_NAME\\saveUsername=true
connections\\$CONN_NAME\\allowGeometrylessTables=true
connections\\$CONN_NAME\\projectsInDatabase=true
connections\\$CONN_NAME\\onlyLineage=false
connections\\$CONN_NAME\\onlyLookInLayerRegistries=false
connections\\$CONN_NAME\\dontResolveType=false
connections\\$CONN_NAME\\estimatedMetadata=false
connections\\$CONN_NAME\\layerMetadata=false
connections\\$CONN_NAME\\pga_overviews=false
connections\\$CONN_NAME\\publicSchemaOnly=false

[Postgres]
onlyLookInLayerRegistries=false
EOT
    fi
fi
# ----------------------------------------------

sleep 1
qgis &

for i in $(seq 1 40); do
    sleep 3
    WID=$(wmctrl -l | grep -i "qgis" | grep -v "splash" | awk '{print $1}' | head -1)
    if [ -n "$WID" ]; then
        wmctrl -ir "$WID" -b add,maximized_vert,maximized_horz
        break
    fi
done