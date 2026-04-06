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

# --- LANZAMIENTO DE QGIS ---
if [ -n "$DB_PROJECT_NAME" ]; then
    # Definimos el esquema (por defecto public si no se envía nada)
    DB_SCHEMA="${DB_SCHEMA:-public}"
    
    # Reemplazamos espacios por %20 en el nombre del proyecto por si acaso
    PROJECT_ENCODED="${DB_PROJECT_NAME// /%20}"
    
    # Armamos la URI de conexión. Al no pasar usuario/pass, QGIS los saca del .ini
    PROJECT_URI="postgresql://?host=$DB_HOST&port=$DB_PORT&dbname=$DB_NAME&sslmode=disable&schema=$DB_SCHEMA&project=$PROJECT_ENCODED"
    
    # Lanzamos QGIS cargando el proyecto
    qgis --project "$PROJECT_URI" &
else
    # Lanzamiento normal si no se especifica proyecto
    qgis &
fi

# El bucle de wmctrl para maximizar se mantiene igual abajo...