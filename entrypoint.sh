#!/bin/bash

minify_file(){
    local file="$1"
    local extension="${file##*.}"
    local filename="${file##*/}"
    filename="${filename%.*}"
    local dir="${file%/*}"
    local output_dir="${INPUT_OUTPUT:-$dir}"
    local output_path="$output_dir/${filename}.min.${extension}"

    [ "$INPUT_OVERWRITE" == "true" ] && output_path="$file"

    mkdir -p "$output_dir"

    # Skip if already exists and overwrite not requested
    [ "$INPUT_OVERWRITE" != "true" ] && [ -f "$output_path" ] && return

    case "${extension,,}" in
        "js")   minify_js "$file" "$output_path" ;;
        "css")  minify_css "$file" "$output_path" ;;
        "html") minify_html "$file" "$output_path" ;;
        *) echo "Skipping unknown extension: $file" ;;
    esac

    echo "Minified $file > $output_path"
}

minify_js(){
    local input="$1"
    local output="$2"
    tmp=$(mktemp)
    if minify "$input" > "$tmp" && [ -s "$tmp" ]; then
        mv "$tmp" "$output"
    else
        echo "JS minification failed, copying raw file"
        cp "$input" "$output"
        rm -f "$tmp"
    fi
}

minify_css(){
    local input="$1"
    local output="$2"
    npx postcss "$input" --use cssnano --no-map > "$output"
}

minify_html(){
    local input="$1"
    local output="$2"
    html-minifier-terser --collapse-whitespace --conservative-collapse --remove-comments --minify-css true --minify-js true "$input" > "$output"
}

dir="${INPUT_DIRECTORY:-.}"

export -f minify_file minify_js minify_css minify_html
export INPUT_OUTPUT INPUT_OVERWRITE

find "$dir" -type f \( -iname "*.html" -o -iname "*.js" -o -iname "*.css" \) ! -iname "*.min.*" \
    | xargs -P "$(nproc)" -I {} bash -c 'minify_file "$@"' _ {}
