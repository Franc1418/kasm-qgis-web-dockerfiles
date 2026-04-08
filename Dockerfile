FROM kasmweb/core-ubuntu-jammy:1.15.0

USER root

# 1. Purgar XFCE
RUN apt-get purge -y \
      xfce4-panel xfdesktop4 xfce4-session xfwm4 xfce4-settings \
    && apt-get autoremove -y && apt-get clean

# 2. OpenBox + utilidades
RUN apt-get update && apt-get install -y \
      openbox obconf xdotool wmctrl \
    && apt-get clean

# 3. QGIS oficial
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

# 4. psycopg2 para conexión PostgreSQL desde Python
RUN apt-get install -y python3-psycopg2 && apt-get clean

# 5. Variables de entorno
ENV KASM_SVC_WM="openbox"
ENV KASM_SVC_PANEL=0
ENV KASM_SVC_BACKGROUND=0
ENV KASM_SVC_AUDIO=0
ENV SINGLE_APPLICATION=1

# 6. OpenBox
RUN mkdir -p /etc/xdg/openbox
COPY rc.xml /etc/xdg/openbox/rc.xml
COPY openbox_autostart.sh /etc/xdg/openbox/autostart
RUN chmod +x /etc/xdg/openbox/autostart

# 7. Startup de Kasm
COPY custom_startup.sh /dockerstartup/custom_startup.sh
RUN chmod +x /dockerstartup/custom_startup.sh

# 8. Perfil de QGIS con startup.py
RUN mkdir -p /home/kasm-user/.local/share/QGIS/QGIS3/profiles/default/python
COPY startup.py /home/kasm-user/.local/share/QGIS/QGIS3/profiles/default/python/startup.py
RUN chown -R 1000:1000 /home/kasm-user/.local

USER 1000
