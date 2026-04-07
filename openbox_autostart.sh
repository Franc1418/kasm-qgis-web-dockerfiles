#!/bin/bash

xsetroot -solid "#1a1a1a" &

# --- Configuración de conexión en QGIS3.ini ---
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
EOT
    fi
fi
# -----------------------------------------------

sleep 1

# Abrir QGIS con el proyecto almacenado en PostgreSQL
# sslmode=disable es requerido por QGIS en la URI
QGIS_PROJECT="postgresql://?host=${DB_HOST}&port=${DB_PORT}&dbname=${DB_NAME}&user=${DB_USER}&password=${DB_PASSWORD}&sslmode=disable&schema=projects&project=red_ftth"

echo "[AUTOSTART] Lanzando QGIS con proyecto: $QGIS_PROJECT" > /tmp/qgis_startup.log

qgis --project "$QGIS_PROJECT" > /tmp/qgis.log 2>&1 &

for i in $(seq 1 40); do
    sleep 3
    WID=$(wmctrl -l | grep -i "qgis" | grep -v "splash" | awk '{print $1}' | head -1)
    if [ -n "$WID" ]; then
        wmctrl -ir "$WID" -b add,maximized_vert,maximized_horz
        echo "[AUTOSTART] QGIS maximizado en intento $i" >> /tmp/qgis_startup.log
        break
    fi
done