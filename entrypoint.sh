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

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

check_dependencies() {
    local missing=0
    for cmd in minify npx postcss cssnano sponge html-minifier-terser; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo -e "${RED}Falta la dependencia: $cmd${NC}"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        echo -e "${RED}Instala las dependencias requeridas y vuelve a intentarlo.${NC}"
        exit 1
    fi
}

minify_file() {
    local filepath="$1"
    local filename=$(basename "$filepath")
    local extension="${filename##*.}"
    local name="${filename%.*}"
    local output_dir="${INPUT_OUTPUT:-${filepath%/*}}"
    local output_path="${output_dir}/${name}.min.${extension,,}"

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

    case "${extension,,}" in
        css)
            minify_css "$filepath" "$output_path"
            ;;
        js)
            minify_js "$filepath" "$output_path"
            ;;
        html)
            minify_html "$filepath" "$output_path"
            ;;
        *)
            echo -e "${YELLOW}Omitiendo: Extensión no soportada '$extension'${NC}" >&2
            return 1
            ;;
    esac

    echo -e "${GREEN}✔ Minificado: $filepath → $output_path${NC}" >&2
}

minify_js() {
    local input="$1"
    local output="$2"
    local tmp_file=$(mktemp)

    if minify "$input" > "$tmp_file" && [ -s "$tmp_file" ]; then
        mv "$tmp_file" "$output"
        echo -e "${GREEN}✔ Minified JS: $input → $output${NC}" >&2
    else
        echo -e "${YELLOW}⚠ Falló minificación JS para '$input'. Copiando original.${NC}" >&2
        cp "$input" "$output"
        rm -f "$tmp_file"
    fi
}

minify_css() {
    local input="$1"
    local output="$2"
    if npx postcss "$input" --use cssnano --no-map | sponge "$output"; then
        echo -e "${GREEN}✔ Minified CSS: $input → $output${NC}" >&2
    else
        echo -e "${YELLOW}⚠ Falló minificación CSS para '$input'. Copiando original.${NC}" >&2
        cp "$input" "$output"
    fi
}

minify_html() {
    local input="$1"
    local output="$2"
    if html-minifier-terser \
        --collapse-whitespace \
        --conservative-collapse \
        --remove-comments \
        --minify-css true \
        --minify-js true \
        "$input" | sponge "$output"; then
        echo -e "${GREEN}✔ Minified HTML: $input → $output${NC}" >&2
    else
        echo -e "${YELLOW}⚠ Falló minificación HTML para '$input'. Copiando original.${NC}" >&2
        cp "$input" "$output"
    fi
}

main() {
    check_dependencies
    local search_dir="${INPUT_DIRECTORY:-.}"
    local files=( $(find "$search_dir" -type f \( -iname '*.html' -o -iname '*.js' -o -iname '*.css' \) | grep -v ".min.") )
    if [ "${#files[@]}" -eq 0 ]; then
        echo -e "${YELLOW}No se encontraron archivos para minificar.${NC}"
        exit 0
    fi
    if command -v parallel >/dev/null 2>&1; then
        printf "%s\n" "${files[@]}" | parallel minify_file
    else
        for file in "${files[@]}"; do
            minify_file "$file"
        done
    fi
}
