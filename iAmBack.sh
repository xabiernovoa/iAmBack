#!/bin/bash
set -euo pipefail

# Obtener ruta base GVFS
GVFS_PATH="/run/user/$(id -u)/gvfs"

# Verificar si se proporcionó un archivo como argumento
archivo_rutas="${1:-}"
if [ -z "$archivo_rutas" ]; then
    echo "Debe proporcionar un archivo de rutas. Uso: $0 archivo_con_rutas.txt"
    exit 1
fi

# Verificar si el archivo de entrada existe
if [ ! -f "$archivo_rutas" ]; then
    echo "El archivo '$archivo_rutas' no existe."
    exit 1
fi

# Verificar si GVFS está montado
if [ ! -d "$GVFS_PATH" ]; then
    echo "No se encontró GVFS montado en: $GVFS_PATH"
    exit 1
fi

# Listar dispositivos montados
entries=("$GVFS_PATH"/*)
if [ ${#entries[@]} -eq 0 ]; then
    echo "No hay dispositivos montados en $GVFS_PATH"
    exit 0
fi

PS3=$'\e[1;36mElige el dispositivo origen: \e[0m'
echo "Dispositivos montados:"
select entry in "${entries[@]}"; do
    if [ -n "${entry:-}" ]; then
        echo "Seleccionaste: $entry"
        break
    else
        echo "Opción inválida."
    fi
done

# Detectar carpetas que empiezan por IAM-
shopt -s nullglob
carpetaGuardar=(IAM-*/)
shopt -u nullglob

# Añadir opción para crear una nueva carpeta
opciones=("${carpetaGuardar[@]}" "Crear nueva carpeta")

PS3=$'\e[1;36mElige la carpeta destino: \e[0m'
select destino in "${opciones[@]}"; do
    if [ -z "${destino:-}" ]; then
        echo "Opción inválida."
    elif [ "$destino" == "Crear nueva carpeta" ]; then
        read -rp $'\e[32mIntroduce el nombre de la nueva carpeta (sin "IAM-"): \e[0m' nombreCarpeta
        # Sanitizar nombre: solo letras, números, guiones y guiones bajos
        nombreCarpeta=$(echo "$nombreCarpeta" | tr -cd '[:alnum:]_-')
        if [ -z "$nombreCarpeta" ]; then
            echo "Nombre inválido."
            exit 1
        fi
        destino="IAM-$nombreCarpeta"
        if ! mkdir -p "$destino"; then
            echo "Error al crear la carpeta destino: $destino"
            exit 1
        fi
        echo "Carpeta creada: $destino"
        break
    else
        echo "Seleccionaste la carpeta: $destino"
        break
    fi
done

# Leer cada ruta del archivo
while IFS= read -r ruta || [ -n "$ruta" ]; do
    # Saltar líneas vacías
    [[ -z "$ruta" ]] && continue

    origen="$entry/$ruta"
    destino_final="$destino$(basename "$ruta")"

    if [ -d "$origen" ]; then
        echo "Sincronizando: $origen → $destino_final"
        rsync -av --delete --info=progress2 "$origen" "$destino/"
    else
        echo "Ruta inválida o no es directorio: $origen"
    fi
done < "$archivo_rutas"

echo "✅ Copia finalizada en: $destino"
