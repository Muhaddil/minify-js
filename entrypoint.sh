#!/bin/bash

# Minificador de archivos JS, CSS y HTML
# Uso:
#   INPUT_DIRECTORY=src INPUT_OUTPUT=dist INPUT_OVERWRITE=true DRY_RUN=true ./entrypoint.sh
# Variables de entorno:
#   INPUT_DIRECTORY   Directorio a buscar archivos (por defecto: .)
#   INPUT_OUTPUT      Directorio de salida (por defecto: carpeta del archivo)
#   INPUT_OVERWRITE   true para sobrescribir archivos originales
#   DRY_RUN           true para solo mostrar acciones sin modificar archivos

set -euo pipefail
IFS=$'\n\t'

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SUCCESS_FILE=$(mktemp)
FAIL_FILE=$(mktemp)
declare -i SUCCESS_COUNT=0
declare -i FAIL_COUNT=0

cleanup() {
    rm -f "$SUCCESS_FILE" "$FAIL_FILE"
}
trap cleanup EXIT

check_dependencies() {
    local missing=0
    for cmd in minify postcss sponge html-minifier-terser; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}Falta la dependencia: $cmd${NC}" >&2
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        echo -e "${RED}Instala las dependencias requeridas y vuelve a intentarlo.${NC}" >&2
        exit 1
    fi
}

minify_js() {
    local input="$1"
    local output="$2"
    local tmp_file=$(mktemp)
    local error_log=$(mktemp)
    local status=0

    minify "$input" > "$tmp_file" 2> "$error_log" || status=$?

    if [ $status -eq 0 ] && [ -s "$tmp_file" ]; then
        mv "$tmp_file" "$output"
        rm -f "$error_log"
        return 0
    else
        echo -e "${YELLOW}Error detallado:${NC}" >&2
        cat "$error_log" >&2
        cp "$input" "$output"
        rm -f "$tmp_file" "$error_log"
        return 1
    fi
}

minify_css() {
    local input="$1"
    local output="$2"
    local error_log=$(mktemp)
    local status=0

    postcss "$input" --use cssnano --no-map 2> "$error_log" | sponge "$output" || status=$?

    if [ $status -eq 0 ]; then
        rm -f "$error_log"
        return 0
    else
        echo -e "${YELLOW}Error detallado:${NC}" >&2
        cat "$error_log" >&2
        cp "$input" "$output"
        rm -f "$error_log"
        return 1
    fi
}

minify_html() {
    local input="$1"
    local output="$2"
    local error_log=$(mktemp)
    local status=0

    html-minifier-terser \
        --collapse-whitespace \
        --conservative-collapse \
        --remove-comments \
        --minify-css true \
        --minify-js true \
        "$input" 2> "$error_log" | sponge "$output" || status=$?

    if [ $status -eq 0 ]; then
        rm -f "$error_log"
        return 0
    else
        echo -e "${YELLOW}Error detallado:${NC}" >&2
        cat "$error_log" >&2
        cp "$input" "$output"
        rm -f "$error_log"
        return 1
    fi
}

minify_file() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    local extension="${filename##*.}"
    local name="${filename%.*}"
    local output_dir="${INPUT_OUTPUT:-${filepath%/*}}"
    local output_path="${output_dir}/${name}.min.${extension,,}"
    local minify_status=0

    mkdir -p "$output_dir"

    if [ "${INPUT_OVERWRITE:-false}" = "true" ]; then
        output_path="$filepath"
    elif [ -f "$output_path" ]; then
        rm -f "$output_path"
    fi

    if [ "${DRY_RUN:-false}" = "true" ]; then
        echo -e "${BLUE}[DRY RUN]${NC} Minificaría: $filepath → $output_path"
        return 0
    fi

    echo -e "Procesando: $filepath" >&2

    case "${extension,,}" in
        css)
            minify_css "$filepath" "$output_path" || minify_status=1
            ;;
        js)
            minify_js "$filepath" "$output_path" || minify_status=1
            ;;
        html)
            minify_html "$filepath" "$output_path" || minify_status=1
            ;;
        *)
            echo -e "${YELLOW}Omitiendo: Extensión no soportada '$extension'${NC}" >&2
            return 1
            ;;
    esac

    if [ $minify_status -eq 0 ]; then
        echo -e "${GREEN}✔ Minificado correctamente: $filepath → $output_path${NC}" >&2
        echo "$filepath" >> "$SUCCESS_FILE"
        return 0
    else
        echo -e "${RED}✘ Error minificando: $filepath (se mantuvo original)${NC}" >&2
        echo "$filepath" >> "$FAIL_FILE"
        return 1
    fi
}

print_summary() {
    echo -e "\n${BLUE}===== RESUMEN DE MINIFICACIÓN =====${NC}"
    echo -e "${GREEN}Archivos minificados correctamente: ${SUCCESS_COUNT}${NC}"

    if [ $FAIL_COUNT -gt 0 ]; then
        echo -e "${RED}Archivos con errores: ${FAIL_COUNT}${NC}"
        while IFS= read -r line; do
            echo -e "  ${RED}•${NC} $line"
        done < "$FAIL_FILE"
    else
        echo -e "${GREEN}Todos los archivos fueron procesados exitosamente${NC}"
    fi

    if [ -s "$SUCCESS_FILE" ]; then
        echo -e "\n${GREEN}Lista de archivos minificados:${NC}"
        while IFS= read -r line; do
            echo -e "  ${GREEN}•${NC} $line"
        done < "$SUCCESS_FILE"
    fi
}

main() {
    check_dependencies
    local search_dir="${INPUT_DIRECTORY:-.}"
    mapfile -t files < <(find "$search_dir" -type f \( -iname '*.html' -o -iname '*.js' -o -iname '*.css' \) | grep -v ".min.")

    if [ "${#files[@]}" -eq 0 ]; then
        echo -e "${YELLOW}No se encontraron archivos para minificar.${NC}" >&2
        exit 0
    fi

    if command -v parallel >/dev/null 2>&1; then
        export -f minify_file minify_js minify_css minify_html
        export INPUT_OVERWRITE INPUT_OUTPUT DRY_RUN
        export RED GREEN YELLOW BLUE NC SUCCESS_FILE FAIL_FILE
        printf "%s\n" "${files[@]}" | parallel minify_file
    else
        for file in "${files[@]}"; do
            minify_file "$file" || true
        done
    fi

    SUCCESS_COUNT=$(wc -l < "$SUCCESS_FILE" 2>/dev/null | tr -d ' ' || echo 0)
    FAIL_COUNT=$(wc -l < "$FAIL_FILE" 2>/dev/null | tr -d ' ' || echo 0)

    print_summary

    if [ "$FAIL_COUNT" -gt 0 ]; then
        exit 1
    fi
}

main