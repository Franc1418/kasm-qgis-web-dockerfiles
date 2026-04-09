FROM kasmweb/core-ubuntu-jammy:1.15.0

USER root

ENV DEBIAN_FRONTEND=noninteractive

# 1. Limpiar XFCE
RUN apt-get purge -y \
      xfce4-panel xfdesktop4 xfce4-session xfwm4 xfce4-settings \
    && apt-get autoremove -y \
    && apt-get clean

# 2. Openbox + deps gráficas IMPORTANTES
RUN apt-get update && apt-get install -y --no-install-recommends \
    openbox obconf xdotool wmctrl \
    x11-xserver-utils \
    xauth \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

# 3. Repo oficial QGIS (BIEN armado)
RUN apt-get update && apt-get install -y \
    gnupg wget ca-certificates software-properties-common \
    && mkdir -p /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/qgis-archive-keyring.gpg https://download.qgis.org/downloads/qgis-archive-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://qgis.org/ubuntu jammy main" > /etc/apt/sources.list.d/qgis.list \
    && apt-get update

# 4. Instalar QGIS (FORZAMOS ERROR SI FALLA)
RUN apt-get install -y qgis qgis-plugin-grass \
    || (echo "❌ ERROR: QGIS no se instaló" && exit 1)

# 5. Verificación explícita (CLAVE)
RUN which qgis || (echo "❌ QGIS no está en PATH" && exit 1)

# 6. psycopg2
RUN apt-get install -y python3-psycopg2 \
    && rm -rf /var/lib/apt/lists/*
# 7. Variables Kasm
ENV KASM_SVC_WM="openbox"
ENV KASM_SVC_PANEL=0
ENV KASM_SVC_BACKGROUND=0
ENV KASM_SVC_AUDIO=0
ENV SINGLE_APPLICATION=1

# 8. Openbox config
RUN mkdir -p /etc/xdg/openbox
COPY rc.xml /etc/xdg/openbox/rc.xml
COPY openbox_autostart.sh /etc/xdg/openbox/autostart
RUN chmod +x /etc/xdg/openbox/autostart

# 9. Startup Kasm
COPY custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

# 10. Perfil QGIS
RUN mkdir -p /home/kasm-user/.local/share/QGIS/QGIS3/profiles/default/python
COPY startup.py /home/kasm-user/.local/share/QGIS/QGIS3/profiles/default/python/startup.py
RUN chown -R 1000:1000 /home/kasm-user/.local

USER 1000
