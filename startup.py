import os
from qgis.core import QgsProject, QgsVectorLayer, QgsDataSourceUri
from qgis.utils import iface
from PyQt5.QtCore import QTimer

def load_layers():
    try:
        # 🔑 Variables de entorno
        host     = os.environ.get("DB_HOST", "")
        port     = os.environ.get("DB_PORT", "5432")
        database = os.environ.get("DB_NAME", "")
        user     = os.environ.get("DB_USER", "")
        password = os.environ.get("DB_PASSWORD", "")

        log_path = "/tmp/qgis_startup.log"
        with open(log_path, "a") as f:
            f.write("🚀 Iniciando carga de capas\n")

        # 🌐 Conexión a la capa red_ftth
        uri = QgsDataSourceUri()
        uri.setConnection(host, port, database, user, password)
        uri.setDataSource("public", "red_ftth", "geom")  # schema, tabla, columna geom

        layer = QgsVectorLayer(uri.uri(False), "Red FTTH", "postgres")
        if not layer.isValid():
            with open(log_path, "a") as f:
                f.write("❌ Falló carga de red_ftth\n")
        else:
            QgsProject.instance().addMapLayer(layer)
            with open(log_path, "a") as f:
                f.write("✅ Capa red_ftth cargada\n")

        # 🔄 Refrescar canvas
        iface.mapCanvas().refresh()
        iface.mapCanvas().zoomToFullExtent()

    except Exception as e:
        with open("/tmp/qgis_startup.log", "a") as f:
            f.write(f"💥 ERROR: {e}\n")

# ⏱️ Esperar a que QGIS esté listo
QTimer.singleShot(8000, load_layers)
