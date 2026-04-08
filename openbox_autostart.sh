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
        # 1. Inyectamos las credenciales de conexión
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

    # 2. NUEVO: Inyectamos el proyecto como "Proyecto Reciente" anclado
    if [ -n "$DB_PROJECT_NAME" ]; then
        DB_SCHEMA="${DB_SCHEMA:-public}"
        PROJECT_ENCODED="${DB_PROJECT_NAME// /%20}"
        
        # Evitamos inyectarlo múltiples veces si el script corriera de nuevo
        if ! grep -q "$PROJECT_ENCODED" "$QGIS_INI" 2>/dev/null; then
            cat <<EOT >> "$QGIS_INI"

[UI]
UI\\recentProjects\\1\\path=postgresql://?host=$DB_HOST&port=$DB_PORT&dbname=$DB_NAME&user=$DB_USER&password=$DB_PASSWORD&sslmode=disable&schema=$DB_SCHEMA&project=$PROJECT_ENCODED
UI\\recentProjects\\1\\title=$DB_PROJECT_NAME
UI\\recentProjects\\1\\pin=true
EOT
        fi
    fi
fi
# ----------------------------------------------

sleep 1

# --- LANZAMIENTO DE QGIS ---
# Lanzamos QGIS de forma normal siempre. Al abrir, mostrará la pantalla de bienvenida 
# con el proyecto reciente ya cargado y anclado.
qgis &

# El bucle de wmctrl para maximizar se mantiene igual
for i in $(seq 1 40); do
    sleep 3
    # Mantenemos el grep -v "splash" por si demora en cargar la ventana principal
    WID=$(wmctrl -l | grep -i "qgis" | grep -v "splash" | awk '{print $1}' | head -1)
    if [ -n "$WID" ]; then
        wmctrl -ir "$WID" -b add,maximized_vert,maximized_horz
        echo "QGIS maximizado en intento $i"
        break
    fi
done