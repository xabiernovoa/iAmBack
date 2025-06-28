# iAmBack

Este script Bash permite copiar automáticamente carpetas específicas desde dispositivos montados mediante GVFS (como cámaras, teléfonos Android o discos de red) hacia carpetas locales organizadas, con opción de crear nuevas carpetas de destino.

## 📦 Características

- Detecta automáticamente dispositivos montados en GVFS.
- Permite elegir interactivamente el dispositivo de origen.
- Copia carpetas especificadas en un archivo de texto usando `rsync`, con progreso y sincronización.

## ⚙️ Requisitos

- Bash (recomendado: 4.x+)
- `rsync`
- GNOME Virtual File System (GVFS), común en entornos como GNOME, Nautilus o Caja.

## 📂 Estructura de uso

```bash
./syncgvfs.sh archivo_con_rutas.txt
```
archivo_con_rutas.txt: Archivo de texto con una ruta por línea relativa al dispositivo GVFS montado. Ejemplo:

DCIM/Camera/
Pictures/
