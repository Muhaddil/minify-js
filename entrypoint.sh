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

    if [ "$INPUT_OVERWRITE" != "true" ] && [ -f "$output_path" ] && [ "$file" -ot "$output_path" ]; then
        echo "Skipping $file (up to date)"
        return
    fi

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

    if terser "$input" -o "$output" --compress --mangle; then
        return 0
    else
        echo "JS minification failed"

        if [ "$input" != "$output" ]; then
            echo "Copying raw file"
            cp "$input" "$output"
        else
            echo "Input and output are the same file, skipping copy"
        fi
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

# Requiere instalar GNU parallel
find "$dir" -type f \( -iname "*.js" -o -iname "*.css" -o -iname "*.html" \) ! -iname "*.min.*" \
  | parallel --jobs $(nproc) minify_file {}
