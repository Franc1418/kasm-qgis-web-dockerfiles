#!/bin/bash
# Hook de Kasm: se ejecuta DESPUÉS de que VNC/KasmVNC está listo
# pero ANTES de que intente arrancar xfce4-session

set -e

# Matar cualquier proceso XFCE que haya sobrevivido
pkill -f xfce4-session  2>/dev/null || true
pkill -f xfce4-panel    2>/dev/null || true
pkill -f xfdesktop      2>/dev/null || true
pkill -f xfwm4          2>/dev/null || true

echo "[KASM-CUSTOM] XFCE eliminado, iniciando OpenBox + QGIS..."

# OpenBox lee automáticamente /etc/xdg/openbox/autostart
# donde está configurado el lanzamiento de QGIS
exec openbox-session