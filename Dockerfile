FROM kasmweb/core-ubuntu-jammy:1.15.0

USER root

# --- 1. Purgar XFCE completamente ---
RUN apt-get purge -y \
      xfce4-panel \
      xfdesktop4 \
      xfce4-session \
      xfwm4 \
      xfce4-settings \
    && apt-get autoremove -y \
    && apt-get clean

# --- 2. Instalar OpenBox como WM mínimo + utilidades ---
RUN apt-get update && apt-get install -y \
      openbox \
      obconf \
      xdotool \
      wmctrl \
    && apt-get clean

# --- 3. Instalar QGIS desde repositorio oficial ---
RUN apt-get install -y gnupg software-properties-common wget \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/qgis-archive-keyring.gpg \
       https://download.qgis.org/downloads/qgis-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] \
       https://qgis.org/ubuntu jammy main" \
       > /etc/apt/sources.list.d/qgis.list \
    && apt-get update \
    && apt-get install -y qgis qgis-plugin-grass \
    && apt-get clean

# --- 4. Variables de entorno críticas ---
ENV KASM_SVC_WM="openbox"
ENV KASM_SVC_PANEL=0
ENV KASM_SVC_BACKGROUND=0
ENV KASM_SVC_AUDIO=0
ENV SINGLE_APPLICATION=1
ENV MAXIMIZE_APP=1

# --- 5. Configuración de OpenBox (sin decoraciones de ventana para QGIS) ---
RUN mkdir -p /etc/xdg/openbox
COPY openbox_autostart.sh /etc/xdg/openbox/autostart
RUN chmod +x /etc/xdg/openbox/autostart

# --- 6. Script de startup personalizado ---
# IMPORTANTE: Este es el hook correcto en Kasm 1.15+
COPY custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

# --- 7. Fondo negro para evitar que se vea el desktop ---
RUN echo '#!/bin/bash\nxsetroot -solid black' \
    > /dockerstartup/background.sh \
    && chmod +x /dockerstartup/background.sh

USER 1000
