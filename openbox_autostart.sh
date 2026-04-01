#!/bin/bash
# Este script lo ejecuta OpenBox al arrancar, ANTES de que aparezca cualquier ventana

# Fondo negro sólido (elimina cualquier fondo de escritorio)
xsetroot -solid "#1a1a1a" &

# Compositor mínimo para rendering correcto (opcional, mejora el rendimiento)
# picom --no-fading-openclose &

# Esperar que el display esté listo
sleep 1

# Lanzar QGIS
qgis &
QGIS_PID=$!

# Esperar que QGIS tenga ventana activa y maximizarla
for i in $(seq 1 20); do
    sleep 1
    # Buscar la ventana de QGIS y maximizarla
    WID=$(xdotool search --name "QGIS" 2>/dev/null | head -1)
    if [ -n "$WID" ]; then
        xdotool windowactivate --sync "$WID"
        xdotool windowsize --sync "$WID" %100 %100   # Pantalla completa
        wmctrl -ir "$WID" -b add,maximized_vert,maximized_horz
        break
    fi
done
